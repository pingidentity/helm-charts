#!/usr/bin/env bash
# Copyright © 2026 Ping Identity Corporation

#
# Ping Identity DevOps - CI scripts
#
# Runs a set of tests specified by the --helm-test {test-name} option.
# This script will typically be called by run_helm_smoke.sh and run_helm_integration.sh.
#
test -n "${VERBOSE}" && set -x

###############################################################################
# Usage printing function
###############################################################################
usage() {
    echo "${*}"
    cat << END_USAGE
Usage: ${0} {options}
    where {options} include:

    --helm-test {test-name}
        The name of the helm test to run.
        If single helm values yaml file, then that that file will be used
        If directory with testFramework values yaml file(s), then all those will
        be run as separate tests.

        Available tests include (from ${_helm_tests_dir}):
$(cd "${_helm_tests_dir}" && find ./* -type d -maxdepth 2 | grep "\/" | sed 's/^/          /')

    --helm-chart {helm-chart-name}
        The name of the local helm chart to use.
        Note: Must be local, and will not download from helm.pingidentity.com

    --namespace {namespace-name}
        The name of the namespace to use.  Used primarily for local testing
        Note: The namespace must be available and it will not be deleted

    --namespace-suffix {namespace-suffix}
        Namespace suffix to be appended to namespace

    --helm-file-values {helm-values-yaml}
        Additional helm values files to be added to helm-test.
        Multiple helm values files can be added.

    --post-renderer {script}
        Post-renderer script to emit extra resources to apply after install.

    --verbose
        Turn up the volume

    --keep-namespace-on-exit
        Keep the namespace on exit

    -h|--help
        Display general usage information
END_USAGE
    exit 99
}

#
# Determine if we are local or part of a CI/CD Pipeline
#
if test -z "${CI_COMMIT_REF_NAME}"; then
    CI_PROJECT_DIR="$(
        cd "$(dirname "${0}")/.." || exit 97
        pwd
    )"
    test -z "${CI_PROJECT_DIR}" && echo "Invalid call to dirname ${0}" && exit 97

    CI_PIPELINE_ID="local"
    CI_JOB_ID=$(date '+%Y%m%d%H%M%S')
fi

_helm_tests_dir="${CI_PROJECT_DIR}/helm-tests"
_post_renderer_script=""
declare -a _external_resource_files
_helmTests=""

while test -n "${1}"; do
    case "${1}" in
        --helm-test)
            _test_to_run=""
            _dir_to_run=""
            test -z "${2}" && usage "You must specify a test if you specify the ${1} option"
            shift
            # Try relative path off current directory
            test -f "$(pwd)"/"${1}" && _test_to_run="$(pwd)"/"${1}"
            # Try path off _helm_tests_dir directory
            test -z "${_test_to_run}" && test -f "${_helm_tests_dir}"/"${1}" && _test_to_run="${_helm_tests_dir}"/"${1}"
            # Try absolute path
            test -z "${_test_to_run}" && test -f "${1}" && _test_to_run="${1}"

            # if we still don't have a test, let's look at directories
            if test -z "${_test_to_run}"; then
                test -d "$(pwd)"/"${1}" && _dir_to_run="$(pwd)"/"${1}"
                test -z "${_dir_to_run}" && test -d "${_helm_tests_dir}"/"${1}" && _dir_to_run="${_helm_tests_dir}"/"${1}"
                test -z "${_dir_to_run}" && test -d "${1}" && _dir_to_run="${1}"

                if test -n "${_dir_to_run}"; then
                    for _test_candidate in "${_dir_to_run}"/*.y*ml; do
                        grep "^testFramework:" "${_test_candidate}" 2> /dev/null > /dev/null

                        if test $? -eq 0; then
                            _test_to_run="${_test_to_run} ${_test_candidate}"
                        fi
                    done
                fi
            fi

            test -z "${_test_to_run}" && usage "Unable to find a file/directory for helm-test '${1}'"

            _helmTests="${_helmTests} ${_test_to_run}"
            ;;
        --helm-chart)
            test -z "${2}" && usage "You must specify a helm chart to deploy to if you specify the ${1} option"
            shift
            HELM_CHART_NAME="${1}"
            ;;
        --helm-file-values)
            test -z "${2}" && usage "You must specify a helm values yaml file if you specify the ${1} option"
            shift
            _addl_helm_file_values="${_addl_helm_file_values} -f ${1}"
            ;;
        --helm-set-values)
            test -z "${2}" && usage "You must specify a helm set values (name=value) if you specify the ${1} option"
            shift
            _addl_helm_set_values="${_addl_helm_set_values} --set ${1}"
            ;;
        --post-renderer)
            test -z "${2}" && usage "You must specify a post-renderer script if you specify the ${1} option"
            shift
            _post_renderer_script="$(cd "$(dirname "${1}")" && pwd)/$(basename "${1}")"
            ;;
        --namespace)
            test -z "${2}" && usage "You must specify a namespace to deploy to if you specify the ${1} option"
            shift
            _namespace_to_use="${1}"
            ;;
        --namespace-suffix)
            test -z "${2}" && usage "You must specify a namespace-suffix to use if you specify the ${1} option"
            shift
            _namespace_suffix="${1}"
            ;;
        --verbose)
            VERBOSE=true
            ;;
        --keep-namespace-on-exit)
            HELM_KEEP_ON_EXIT=true
            ;;
        -h | --help)
            usage
            ;;
        *)
            echo "Unrecognized option"
            usage
            ;;
    esac
    shift
done

CI_SCRIPTS_DIR="${CI_PROJECT_DIR:-.}/ci_scripts"
# shellcheck source=./ci_tools.lib.sh
. "${CI_SCRIPTS_DIR}/ci_tools.lib.sh"

test -z "${PING_IDENTITY_DEVOPS_USER}" && usage "Env Variable PING_IDENTITY_DEVOPS_USER is required"
test -z "${PING_IDENTITY_DEVOPS_KEY}" && usage "Env Variable PING_IDENTITY_DEVOPS_KEY is required"

_tmpDir=$(mktemp -d)

################################################################################
# _final
################################################################################
_final() {
    #
    # If the _exitCode isn't set, then the test never finished and was probably
    # interrupted, so we will set it to 1 (i.e. error)
    #
    test -z "${_exitCode}" && _exitCode=1

    #
    # Find out if there is a release running that we need to cleanup
    #
    helm ls --filter "${_helmRelease}" "${NS_OPT[@]}" | grep "^${_helmRelease}" > /dev/null 2> /dev/null

    if test $? -eq 0; then
        #
        # If there was an error, we will print out details about the various k8s resources
        #
        if test ${_exitCode} -gt 0; then
            banner "Error (${_exitCode}) - Resources before CleanUp"
            kubectl get cm,pod,service,pvc,events "${NS_OPT[@]}"
        fi

        #
        # Uninstall the helm release
        #
        banner "CleanUp: Uninstalling Release"
        helm uninstall "${_helmRelease}" "${NS_OPT[@]}"
    fi

    if test ${#_external_resource_files[@]} -gt 0; then
        banner "CleanUp: Deleting external resources"
        for _external_manifest in "${_external_resource_files[@]}"; do
            test -f "${_external_manifest}" && kubectl delete -n "${NS}" -f "${_external_manifest}" --ignore-not-found
        done
    fi

    if test -z "${_namespace_to_use}"; then
        if test -z "${HELM_KEEP_ON_EXIT}"; then
            banner "CleanUp: Deleting namespace ${NS}"
            kubectl delete namespace "${NS}" --wait=true
        else
            echo_red "Warning: Keeping artifacts created (i.e. pvcs, configmaps, secrets)"
        fi
    else
        #
        # Shared pool namespace: delete THIS suite's leftover non-release
        # resources (kubectl-created configmaps/secrets; the helm release and
        # its hook pods were removed by the uninstall above). Select on the
        # release label — run-id is shared by all parallel suites of the
        # pipeline, so selecting on it here would delete a concurrent
        # suite's helm release storage secrets (run 43448047735).
        #
        kubectl delete configmap,secret -l "ppds.pingidentity.com/release=${_helmRelease}" "${NS_OPT[@]}" \
            --ignore-not-found=true 2> /dev/null > /dev/null || true
        echo_red "Warning: Keeping artifacts created (i.e. pvcs, configmaps, secrets)"
    fi

    #
    # Cat the final resultsFile
    #
    cat "${_resultsFile}"

    #
    # Calculate the total duration of the test and output that
    #
    _totalStop=$(date '+%s')
    _totalDuration=$((_totalStop - _totalStart))
    echo "Total duration: ${_totalDuration}s"

    rm -rf "${_tmpDir}"

    #
    # Finally exit with the _exitCode
    exit "${_exitCode}"
}

trap _final EXIT

################################################################################
# Build Bruno Environment Variables from existing config maps ending in argument
# passed
#
# Example:
#   getBrunoEnvJson "-env-vars"
################################################################################
getBrunoEnvJson() {
    _search="${1}"
    _comma=""

    #
    # Get the list of candidate ConfigMap Names based on the search
    #
    _candidateCMs=$(kubectl get configmap "${NS_OPT[@]}" -o json | jq -r ".items[] | select(.metadata.name | test(\"$_search\")) | .metadata.name")

    #
    # Start the json with basic info
    #
    echo "{
        \"name\": \"helm-testing\",
        \"variables\": ["

    #
    # For each candidate ConfigMap
    # Get the Name/Value pairs in the data element and create a
    # bruno environment key/value/enabled json
    for _candidateCM in ${_candidateCMs}; do
        _nvPairs=$(kubectl get configmap "${_candidateCM}" "${NS_OPT[@]}" -o json | jq -r '.data')

        for _key in $(jq -r 'keys | .[]' <<< "${_nvPairs}"); do
            echo "${_comma}"
            jq -n '{name:$name,value:$value,enabled:$enabled,type:$type}' \
                --arg name "${_key}" \
                --arg value "$(jq -r ".$_key" <<< "${_nvPairs}")" \
                --arg enabled "true" \
                --arg type "text"

            _comma=","
        done
    done

    #
    # End the Json
    #
    echo "]}"
}

################################################################################
# Create a tarball of a bruno collection directory and upload it as a single
# ConfigMap asset (ConfigMaps are single-file; the bruno collection is a dir).
# Collections live in helm-tests/bruno/{smoke,integration}/<test-dir-name>/ (the
# slug matches the test directory name). Graceful no-op when the slug dir
# doesn't exist (toolkit/curl-only suites).
#
# Example:
#   createBrunoCollectionConfigMap <helmRelease> <testDirName>
################################################################################
createBrunoCollectionConfigMap() {
    _helmRelease="${1}"
    _testDirName="${2}"

    for _brunoSlugDir in "${_helm_tests_dir}/bruno/${_testDirName}" \
        "${_helm_tests_dir}/bruno/smoke/${_testDirName}" \
        "${_helm_tests_dir}/bruno/integration/${_testDirName}"; do
        if test -d "${_brunoSlugDir}"; then
            break
        fi
    done

    test -d "${_brunoSlugDir}" || return 0

    _brunoTarName="${_helmRelease}-bruno-collection.tar.gz"
    _brunoTarFile="${_tmpDir}/bruno-collection.tar.gz"

    # COPYFILE_DISABLE: macOS tar otherwise embeds AppleDouble ._* resource-fork
    # files for xattr'd files, which the bruno CLI tries to parse as requests.
    COPYFILE_DISABLE=1 tar --exclude='./.claude' --exclude='./.git' --exclude='./node_modules' --no-xattrs -czf "${_brunoTarFile}" -C "${_brunoSlugDir}" . 2> /dev/null

    kubectl delete configmap "${_brunoTarName}" "${NS_OPT[@]}" 2> /dev/null > /dev/null
    kubectl create configmap "${_brunoTarName}" "${NS_OPT[@]}" --from-file="file=${_brunoTarFile}"
    _kubectlLabel "${_brunoTarName}" configmap
}

################################################################################
# processContainerResults "container | initContainer"
################################################################################
processContainerResults() {
    _contType="${1}"
    _testPodName="${_helmRelease}-${TEST_SUFFIX}"

    for _icName in $(kubectl get pods "${_testPodName}" "${NS_OPT[@]}" -o json | jq -r ".status.${_contType}Statuses[] | .name"); do
        banner "Logs: ${_icName}"
        _icStatus=$(kubectl get pods "${_testPodName}" "${NS_OPT[@]}" -o json | jq -r ".status.${_contType}Statuses[] | select(.name | test(\"${_icName}\"))")

        _icExit=$(jq -r .state.terminated.exitCode <<< "${_icStatus}")
        _icReason=$(jq -r .state.terminated.reason <<< "${_icStatus}")

        if test "${_icExit}" == "0"; then
            _result="PASS"
            _icStart=$(jq -r .state.terminated.startedAt <<< "${_icStatus}")
            _icFinish=$(jq -r .state.terminated.finishedAt <<< "${_icStatus}")

            # Because date on MacOSX and Unix are different
            if test "$(uname -s)" == "Darwin"; then
                _icStart=$(date -j -f "%Y-%m-%dT%TZ" "${_icStart}" "+%s")
                _icFinish=$(date -j -f "%Y-%m-%dT%TZ" "${_icFinish}" "+%s")
            else
                _icStart=$(date -d "${_icStart}" +%s)
                _icFinish=$(date -d "${_icFinish}" +%s)
            fi

            _duration=$((_icFinish - _icStart))
        else
            banner "Describe details for test"
            kubectl describe pods "${_testPodName}" "${NS_OPT[@]}"
            _result="FAIL"
            _duration="-"
            test "${_icReason}" == "null" && _icReason="-"
        fi

        if test "${_contType}" == "initContainer"; then
            kubectl logs "${_testPodName}" "${NS_OPT[@]}" -c "${_icName}" 2> /dev/null
        fi

        append_status "${_resultsFile}" "${_result}" "${_reportPattern}" "  ${_icName}" "${_duration}" "${_icReason}"
    done
}

################################################################################
# printContainerLogs
################################################################################
printContainerLogs() {
    find "${_podLogsDir}" -type f -print0 | while IFS= read -r -d '' file; do
        _podFilename=$(basename "${file}")
        banner "Pod logs for ${_podFilename}:"
        cat "${file}"
    done
}

#
# Reporting Formatting
#
_totalStart=$(date '+%s')
_resultsFile="${_tmpDir}/$$.results"
_headerPattern=' %-58s| %10s| %10s\n'
_reportPattern='%-57s| %10s| %10s'
# shellcheck disable=SC2059
printf "${_headerPattern}" "TEST" "DURATION" "RESULT" > "${_resultsFile}"

_exitCode=

# TEST_PREFIX used as prefix for Namespace, ReleaseName and generated configmaps
export TEST_PREFIX="dbt-"
# TEST_PREFIX used as prefix for Helm Test name
export TEST_SUFFIX="testframework"

#
# Ownership labels. Pools are shared namespaces (they cannot be created by
# CI), and multiple suites run concurrently in one pool (parallel matrix
# jobs of the same pipeline). Two labels on every resource:
#
#   ppds.pingidentity.com/release — the helm release name, unique per suite.
#     All LIVE deletes select on this: pre-install sweep, end-of-run
#     cleanup, and the workflow job-end cleanup step. Selecting on run-id
#     here would let one suite's cleanup delete a concurrent suite's helm
#     release storage secrets (helm --labels stamps them too), which is
#     exactly what killed run 43448047735 ("Error: release: not found" on
#     all 22 jobs).
#
#   ppds.pingidentity.com/run-id — pipeline identity (CI_RUN_ID, exported by
#     the GitHub workflow; GitLab falls back to gitlab-${CI_PIPELINE_ID};
#     local runs get a per-invocation value). Used ONLY by the stale sweep
#     (resources of a dead run whose newest object is >2h old).
#
# kubectl create has no --labels flag (verified v1.36), so resources are
# labeled after creation via `kubectl label --overwrite`.
#
if test -z "${CI_RUN_ID}"; then
    if test -n "${CI_PIPELINE_ID}"; then
        CI_RUN_ID="gitlab-${CI_PIPELINE_ID}"
    else
        CI_RUN_ID="local-$(date +%s)-$$"
    fi
    export CI_RUN_ID
fi
_RUN_ID_LABEL="ppds.pingidentity.com/run-id"
_RUN_LABEL="${_RUN_ID_LABEL}=${CI_RUN_ID}"

# Label a kubectl-created resource with both ownership labels. kubectl
# create has no --labels flag, so this runs after each create. The release
# label is only set when known (callers inside the per-test loop pass it);
# the end-of-run cleanup selects on it, so a created-without-release-label
# resource would survive that cleanup — acceptable for run-level assets
# (devops-secret, aws-ecr-registry) that outlive a single suite.
_kubectlLabel() {
    _resName="${1}"
    _resKind="${2}"
    _labelArgs=(--overwrite "${_RUN_LABEL}")
    if test -n "${_currentRelease:-}"; then
        _labelArgs+=("ppds.pingidentity.com/release=${_currentRelease}")
    fi
    kubectl label "${_resKind}" "${_resName}" "${_labelArgs[@]}" "${NS_OPT[@]}" > /dev/null 2>&1 || true
}

#
# Determine the NAMESPACE to use
#
if test -n "${_namespace_to_use}"; then
    NS=$(toLower "${_namespace_to_use}")
    export NS

    kubectl get ns "${NS}" 2> /dev/null > /dev/null

    if test $? -ne 0; then
        echo_red "ERROR: Unable to use namespace provided."
        exit
    fi
else
    export NAMESPACE_PREFIX="${NAMESPACE_PREFIX:-$TEST_PREFIX}"

    # Truncate the commit ref to prevent hitting the character limit of 63 for Kubernetes namespaces
    # Truncate the commit ref instead of the final namespace so that we don't lose the namespace suffix
    _commitRefTruncated=$(echo ${CI_COMMIT_REF_SLUG:-$USER} | cut -c1-35)
    NS=$(toLower "${NAMESPACE_PREFIX}${_commitRefTruncated}-${CI_PIPELINE_ID}-${CI_JOB_ID}${_namespace_suffix}")
    export NS

    #
    # Create the namespace
    #
    banner "Creating namespace '${NS}'"

    kubectl create namespace "${NS}"

    if test $? -ne 0; then
        echo_red "Error: Unable to create a namespace.  Most likely a permission problem problem "
        exit
    fi
fi
export NS_OPT=(--namespace "${NS}")

#
# If we are in a pipeline, we will need to create a docker-registry secret
# with access to the pipeline repo (typically an AWS ECR)
#
test -n "${PIPELINE_BUILD_REGISTRY}" && _createPipelineRepoAccess "${NS}"

#
# Setup Helm
#
if test -z "${HELM_CHART_NAME}"; then
    export HELM_REPO_URL="${HELM_REPO_URL:-https://helm.pingidentity.com}"
    export HELM_REPO_NAME="${HELM_REPO_NAME:-pingidentity}"
    export HELM_CHART_NAME="${HELM_CHART_NAME:-$HELM_REPO_NAME/ping-devops}"
    export HELM_CHART_VERSION="${HELM_CHART_VERSION:-latest}"
fi

banner "
               Helm Details

         helm version: $(helm version)
        helm repo url: ${HELM_REPO_URL}
            helm repo: ${HELM_REPO_NAME}

           helm chart: ${HELM_CHART_NAME}
   helm chart version: ${HELM_CHART_VERSION}
"

if test -n "${HELM_REPO_URL}"; then
    helm repo add "${HELM_REPO_NAME}" "${HELM_REPO_URL}"

    if test $? -ne 0; then
        echo_red "ERROR: Unable to add helm repo ${HELM_REPO_URL}."
        exit
    fi

    helm search repo "${HELM_REPO_NAME}"
else
    if test ! -d "${HELM_CHART_NAME}"; then
        echo_red "ERROR: Unable to find local helm chart '${HELM_CHART_NAME}'"
        exit
    else
        echo "Using local helm-charts."
    fi
fi

test -n "${VERBOSE}" && kubectl get namespaces
test -n "${VERBOSE}" && banner "Describing nodes"
test -n "${VERBOSE}" && kubectl describe nodes

#
# Create the devops-secret ConfigMap
#
_devopsSecretName="devops-secret"

#
# Sweep leftover resources before installing:
#   1. This suite's release: a cancelled/failed earlier attempt of this same
#      suite skips its cleanup step, leaving product pods (e.g. a crashed PA
#      StatefulSet) that consume node CPU/memory.
#   2. Stale runs: any run-id whose newest object is older than 2h, from a
#      run whose cleanup never ran and that will never come back for it.
# Never touch other suites' or other runs' resources — parallel matrix
# suites of the same pipeline and concurrent pipelines both share the pool.
# Runs once per script invocation, before any helm install. The release name
# is not known yet at this point (the sweep predates the per-test loop), so
# the own-release sweep inside the loop (just before helm install) covers
# case 1; this namespace-level pass only handles case 2.
#
banner "Pre-install sweep of stale workloads in ${NS}"
_staleRunIds=$(kubectl get pod,sts,deploy,replicaset,statefulset,pvc,configmap,secret "${NS_OPT[@]}" \
    -l "${_RUN_ID_LABEL}" -o go-template='{{range .items}}{{index .metadata.labels "ppds.pingidentity.com/run-id"}}{{"\n"}}{{end}}' 2> /dev/null | sort -u)
for _staleRunId in ${_staleRunIds}; do
    test "${_staleRunId}" = "${CI_RUN_ID}" && continue
    _newest=$(kubectl get pod,sts,deploy,replicaset,statefulset,pvc,configmap,secret "${NS_OPT[@]}" \
        -l "${_RUN_ID_LABEL}=${_staleRunId}" -o json 2> /dev/null |
        jq -r '[.items[].metadata.creationTimestamp] | max // empty')
    test -z "${_newest}" && continue
    # Because date on MacOSX and Unix are different
    if test "$(uname -s)" == "Darwin"; then
        _newestEpoch=$(date -j -f "%Y-%m-%dT%TZ" "${_newest}" "+%s" 2> /dev/null || echo 0)
    else
        _newestEpoch=$(date -d "${_newest}" +%s 2> /dev/null || echo 0)
    fi
    _ageSeconds=$(($(date +%s) - ${_newestEpoch}))
    if test ${_ageSeconds} -gt 7200; then
        banner "Sweeping stale resources of dead run ${_staleRunId} (newest object ${_ageSeconds}s old)"
        kubectl delete pod,sts,deploy,replicaset,statefulset,pvc,configmap,secret \
            -l "${_RUN_ID_LABEL}=${_staleRunId}" "${NS_OPT[@]}" \
            --ignore-not-found=true --wait=false 2> /dev/null > /dev/null || true
    fi
done

banner "Generating Secret ${_devopsSecretName}"
kubectl delete secret "${_devopsSecretName}" "${NS_OPT[@]}" 2> /dev/null > /dev/null
kubectl create secret generic "${_devopsSecretName}" "${NS_OPT[@]}" \
    --from-literal=PING_IDENTITY_DEVOPS_USER="${PING_IDENTITY_DEVOPS_USER}" \
    --from-literal=PING_IDENTITY_DEVOPS_KEY="${PING_IDENTITY_DEVOPS_KEY}" \
    --from-literal=PING_IDENTITY_ACCEPT_EULA="YES"

#
# Global assets to be imported for configmaps
#
_globalAssets="${_helm_tests_dir}/_global"

#
# Perform an install/test for each test
#
for _helmTest in ${_helmTests}; do
    _start=$(date '+%s')

    _helmTestDir="$(dirname "${_helmTest}")"

    _testName="$(basename "${_helmTest}" | sed 's/\.y.*ml$//')"

    _helmRelease="${TEST_PREFIX}${_testName}${_namespace_suffix}"
    _currentRelease="${_helmRelease}"

    #
    # Publish installed release names for the workflow's job-end cleanup
    # step (it selects deletions on the release ownership label). Appended
    # across all suites/invocations in the job workspace.
    #
    if test -n "${RELEASES_FILE:-}"; then
        echo "${_helmRelease}" >> "${RELEASES_FILE}"
    fi

    banner "
                   Installing

              Helm Test:  ${_testName}
              Namespace:  ${NS}
            Values Yaml:  ${_helmTest}

             Chart Name: ${HELM_CHART_NAME}
          Chart Version: ${HELM_CHART_VERSION}
           Release Name: ${_helmRelease}

 Additional File Values: ${_addl_helm_file_values}
  Additional Set Values: ${_addl_helm_set_values}
"

    kubectl label namespace "${NS}" --overwrite \
        test-name="${_testName}"

    test -n "${HELM_CHART_VERSION}" && test "${HELM_CHART_VERSION}" != "latest" && _versionOpt="--version ${HELM_CHART_VERSION}"

    #
    # Substitute any variables (such as $DEP) into the helm test prior to installing
    #
    _substHelmTest="${_tmpDir}/${_helmRelease}"
    # shellcheck disable=SC2016
    envsubst '${DEPS_REGISTRY}' < "${_helmTest}" > "${_substHelmTest}"

    # Word-split is expected behavior for helm variables. Disable shellcheck.
    # shellcheck disable=SC2086
    #
    # Own-release sweep: a cancelled/failed earlier attempt of this suite
    # skips its cleanup, leaving pods/PVCs that block this install (ports,
    # PVC names, node capacity). Select on this release's ownership label —
    # never on run-id, which concurrent suites of this pipeline share.
    #
    banner "Pre-install sweep of leftover workloads from release ${_helmRelease}"
    kubectl delete pod,sts,deploy,replicaset,statefulset,pvc,configmap,secret \
        -l "ppds.pingidentity.com/release=${_helmRelease}" "${NS_OPT[@]}" \
        --ignore-not-found=true --wait=false 2> /dev/null > /dev/null || true

    # Word-split is expected behavior for helm variables. Disable shellcheck.
    # shellcheck disable=SC2086
    helm install "${_helmRelease}" "${HELM_CHART_NAME}" \
        ${_versionOpt} \
        "${NS_OPT[@]}" \
        -f "${_substHelmTest}" \
        ${_addl_helm_file_values} \
        ${_addl_helm_set_values} \
        --set "testFramework.name=${TEST_SUFFIX}" \
        --set "testFramework.enabled=true" \
        --set "testFramework.testConfigMaps.prefix=${TEST_PREFIX}" \
        --set "testFramework.finalStep.image=${DEPS_REGISTRY}busybox" \
        --set "global.externalImage.pingtoolkit.image.repositoryFqn=${DEPS_REGISTRY}pingidentity/pingtoolkit" \
        --set "global.externalImage.pingtoolkit.image.tag=latest" \
        --set "global.addReleaseNameToResource=prepend" \
        --labels "${_RUN_LABEL},ppds.pingidentity.com/release=${_helmRelease}"

    _returnCode=${?}

    if test ${_returnCode} -eq 0 && test -n "${_post_renderer_script}"; then
        _extra_manifest_file="${_tmpDir}/${_helmRelease}-post-renderer.yaml"
        if "${_post_renderer_script}" < /dev/null > "${_extra_manifest_file}"; then
            echo "Applying external resources from ${_post_renderer_script}"
            if kubectl apply -n "${NS}" -f "${_extra_manifest_file}"; then
                _external_resource_files+=("${_extra_manifest_file}")
            else
                echo "Warning: Failed to apply external resources from ${_extra_manifest_file}"
            fi
        else
            echo "Warning: Unable to generate resources via ${_post_renderer_script}"
        fi
    fi

    banner "Helm Release Values Provided"
    helm get values "${_helmRelease}" "${NS_OPT[@]}"

    if test ${_returnCode} -eq 0; then
        #
        # Allow a bit of time to allow for configmaps to be created so we can
        # generate the environment variables in the next step
        #
        sleep 5
        #
        # Generate Bruno Environment ConfigMap. Suites reference
        # generated.bruno-environment.json
        # and <release>-bruno-collection.tar.gz in their testConfigMaps.files.
        #
        _brunoEnvConfigMap="${_helmRelease}-generated.bruno-environment.json"
        _brunoEnvFile="${_tmpDir}/${_brunoEnvConfigMap}"

        # Scope the scrape to THIS release's *-env-vars CMs: pool namespaces
        # can hold two concurrent suites (e.g. a smoke + an integration job of
        # the same dispatch), and a namespace-wide scrape would cross-
        # contaminate same-named variables (e.g. PD_CONSOLE_PRIVATE_HOSTNAME)
        # between releases.
        getBrunoEnvJson "^${_helmRelease}-.*-env-vars$" > "${_brunoEnvFile}"

        kubectl delete configmap "${_brunoEnvConfigMap}" "${NS_OPT[@]}" 2> /dev/null > /dev/null
        kubectl create configmap "${_brunoEnvConfigMap}" "${NS_OPT[@]}" --from-file="file=${_brunoEnvFile}"
        _kubectlLabel "${_brunoEnvConfigMap}" configmap

        # The chart's pinglib.addreleasename helper truncates ConfigMap names to 63
        # chars, which can drop the ".json" suffix on long release names and break
        # the volume mount. Create the truncated name too; it's cheap insurance.
        _brunoEnvConfigMapTrunc="$(echo "${_brunoEnvConfigMap}" | cut -c1-63)"

        kubectl delete configmap "${_brunoEnvConfigMapTrunc}" "${NS_OPT[@]}" 2> /dev/null > /dev/null
        kubectl create configmap "${_brunoEnvConfigMapTrunc}" "${NS_OPT[@]}" --from-file="file=${_brunoEnvFile}"
        _kubectlLabel "${_brunoEnvConfigMapTrunc}" configmap

        #
        # Upload bruno collection tarball as a single ConfigMap asset (no-op when
        # the test dir has no matching helm-tests/bruno slug)
        #
        createBrunoCollectionConfigMap "${_helmRelease}" "$(basename "${_helmTestDir}")"

        #
        # Generate ConfigMaps for all test and global
        #
        banner "Generating test & global ConfigMaps"

        for _asset in "${_helmTestDir}"/* "${_globalAssets}"/*; do
            _assetName=$(basename "${_asset}")

            _assetConfigMapName="${_helmRelease}-${_assetName}"

            kubectl delete configmap "${_assetConfigMapName}" "${NS_OPT[@]}" 2> /dev/null > /dev/null
            kubectl create configmap "${_assetConfigMapName}" "${NS_OPT[@]}" --from-file="file=${_asset}"
            _kubectlLabel "${_assetConfigMapName}" configmap
        done

        #
        # Get all resources before test is started
        banner "Resources available before test"
        kubectl get cm,pod,service,pvc "${NS_OPT[@]}"

        # Start the helm test in the background and capture the PID
        banner "Starting test ${_helmRelease}..."
        helm test "${_helmRelease}" "${NS_OPT[@]}" --timeout 25m &
        _test_pid=${!}

        # Create a directory to save pod logs during the test
        _podLogsDir="${_tmpDir}/test-logs-dir"
        mkdir "${_podLogsDir}"

        # The purpose of this while loop is to
        # 1) Check to see if the helm test has failed, and kill the process earlier than the timeout length
        # 2) Output logs of any terminated states. e.g. Hook failure on startup
        _poll_helm_test=true
        while test "${_poll_helm_test}" = true; do
            echo "Polling pods for terminated states..."

            # Only THIS release's pods. The pool namespace is shared with
            # concurrent suites; their pods legitimately exit non-zero (their
            # own hook/init failures) and must not fail this test.
            podsList=$(kubectl get pods "${NS_OPT[@]}" \
                -l "app.kubernetes.io/instance=${_helmRelease}" -o json | jq -r ".items[].metadata.name")

            # Loop through each pod to check statuses for terminated states.
            for podName in ${podsList}; do
                #Get specific pod status information
                pod_status_json="$(kubectl get pod "${podName}" -o json "${NS_OPT[@]}")"
                #Sometimes the `kubectl get pod` command fails as BAD REQUEST when the pod is in the `PodInitializing` state.
                test ${?} -ne 0 && continue

                # Wait for the pod to be initialized
                jq -er '.status.conditions[] | select(.type == "Initialized") | .status | test("True")' <<< "${pod_status_json}" > /dev/null
                test ${?} -ne 0 && continue

                # Wait for containers to be running
                jq -er '.status.containerStatuses[] | select(.state.running != null)' <<< "${pod_status_json}" > /dev/null
                test ${?} -ne 0 && continue

                # Start tailing logs for the pod if we haven't already
                if ! test -f "${_podLogsDir}/${podName}"; then
                    kubectl logs "${podName}" "${NS_OPT[@]}" -f > "${_podLogsDir}/${podName}" &
                fi

                # A container whose CURRENT state is terminated non-zero is a
                # real failure. lastState.terminated is NOT: it describes a
                # previous crash, and the container may have restarted and be
                # running fine now (e.g. a transient startup crash under
                # parallel-suite load) — killing the helm test for it made a
                # fully-green run fail (feature-branch validation 43450757276,
                # pingdirectory: wait-for/bruno/completion all Passed while
                # the poll loop killed the test over a long-recovered
                # restart).
                terminated_state_json="$(jq -er '.status.containerStatuses[] | select(.state.terminated != null) | .state.terminated' <<< "${pod_status_json}")"
                #If jq returns non-zero exitcode, the output is null or false
                test ${?} -ne 0 && continue

                # Exitcode and reason for termination does not exist in all termination states, so continue if not present
                termination_exitcode="$(jq -er ".exitCode" <<< "${terminated_state_json}")"
                test ${?} -ne 0 && continue

                # If failed terminated container exists, print the logs
                if test "${termination_exitcode}" != 0; then
                    _poll_helm_test=false
                    _pod_terminated_with_failure=true
                fi
            done

            # Check to see if helm test command is still running
            if ! ps -p ${_test_pid} > /dev/null; then
                # The helm test has completed, stop the while loop
                echo "Helm test ${_helmRelease} has completed. Stop polling pods..."
                _poll_helm_test=false
            fi

            # Poll statuses every 5 seconds
            test ${_poll_helm_test} = true && sleep 5
        done

        # If a pod failed via terminated state the while loop has exited early.
        if ps -p ${_test_pid} > /dev/null; then
            # Kill the helm test process as it is still running.
            echo "A pod has terminated with a non-zero exit code. Killing helm test ${_helmRelease}..."
            # _kill_pid lives in run_helm_smoke.sh (the parent), which is a
            # separate process — kill the helm test tree here directly.
            pkill -TERM -P "${_test_pid}" 2> /dev/null
            kill "${_test_pid}" 2> /dev/null
        fi

        #Either the helm test command completed or was killed. Either way, wait captures and returns the exit code of the process.
        wait ${_test_pid}
        _returnCode=${?}

        # Handle the edge case where a failed pod was found, yet the helm test process completed with an exit code of 0 (success)
        # before it could be manually killed. Here we still want to report a failed return code.
        test ${_returnCode} -eq 0 && test ${_pod_terminated_with_failure:-false} = true && _returnCode=1

        test ${_returnCode} -ne 0 && echo_red "Helm Test ${_helmRelease} Failed"
    else
        echo_red "Helm install was unsuccessful (_returnCode=${_returnCode})"

        kubectl get cm,pod,service,pvc "${NS_OPT[@]}"
    fi

    _stop=$(date '+%s')
    _duration=$((_stop - _start))

    if test ${_returnCode} -ne 0; then
        _result="FAIL"
    else
        _result="PASS"
    fi
    append_status "${_resultsFile}" "${_result}" "${_reportPattern}" "${_helmRelease}-${TEST_SUFFIX}" "${_duration}" "${_result}"
    _exitCode=$((_exitCode + _returnCode))

    processContainerResults "initContainer"
    processContainerResults "container"

    if test ${_returnCode} -ne 0; then
        printContainerLogs
    fi
done
