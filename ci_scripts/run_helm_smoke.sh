#!/usr/bin/env bash
# Copyright © 2026 Ping Identity Corporation

#
# Ping Identity DevOps - CI scripts
#
# Run smoke tests against product images
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
    -p, --product
        The name of the product for which to build a docker image
    --fast-fail
        verbose docker build not using docker buildkit
    --image-tag-override {tag}
        Override the image-tags with this single tag.  Good for testing against a released
        version (i.e. sprint of 2105)

    --namespace {namespace-name}
        Run all smoke tests inside this existing namespace.
        The namespace must already exist and will not be created or deleted.

    --helm-test {test-path}
        Override the smoke test file/dir passed to run_helm_tests.sh.
        Defaults to helm-tests/smoke-tests/<product>. Useful for parallel-run
        suites (e.g. helm-tests/smoke-tests/<product>/<product>-bruno-smoke.yaml)
        where the directory contains both the newman and bruno yaml variants.

    --help
        Display general usage information
END_USAGE
    exit 99
}

listContainsValue() {
    test -z "${1}" && exit 2
    test -z "${2}" && exit 3
    _list="${1}"
    _value="${2}"
    echo "${_list}" | grep -qw "${_value}"
    return ${?}
}

if test -z "${CI_COMMIT_REF_NAME}"; then
    CI_PROJECT_DIR="$(
        cd "$(dirname "${0}")/.." || exit 97
        pwd
    )"
    test -z "${CI_PROJECT_DIR}" && echo "Invalid call to dirname ${0}" && exit 97

    LOCAL_NAMESPACE=$(kubens --current)
    NS_OPT="--namespace ${LOCAL_NAMESPACE}"
else
    unset NS_OPT
fi

while test -n "${1}"; do
    case "${1}" in
        -p | --product)
            test -z "${2}" && usage "You must provide a product to build if you specify the ${1} option"
            shift
            product="${1}"
            ;;
        --image-tag-override)
            test -z "${2}" && usage "You must specify an image-tag-override ${1} option (i.e. 2105)"
            shift
            _image_tag_override="${1}"
            ;;
        --namespace)
            test -z "${2}" && usage "You must provide a namespace with the ${1} option"
            shift
            NS_OPT="--namespace ${1}"
            ;;
        --helm-test)
            test -z "${2}" && usage "You must provide a test path with the ${1} option"
            shift
            _helm_test_override="${1}"
            ;;
        --help)
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

returnCode=""

test -z "${product}" && usage "Providing a product is required"
! test -d "${CI_PROJECT_DIR}/helm-tests/smoke-tests/${product}/" && echo "${product} has no smoke tests" && exit 98

if test -n "${IS_LOCAL_BUILD}"; then
    set -a
    # shellcheck disable=SC1090
    . ~/.pingidentity/config
    set +a
fi

_tmpDir=$(mktemp -d)

################################################################################
# _kill_pid
################################################################################
_kill_pid() {

    ppid="${1}"
    cpids=$(pgrep -P "${ppid}" | xargs)
    for cpid in $cpids; do
        _kill_pid "$cpid"
    done
    echo "killing ${ppid}"
    kill "${ppid}" 2> /dev/null
}

################################################################################
# _final
################################################################################
_final() {

    for pid in "${_pids[@]}"; do
        # returnCode=1
        _kill_pid "${pid}"
    done

    cat "${_resultsFile}"
    rm "${_resultsFile}"
    rm -rf "${_tmpDir}"
    _totalStop=$(date '+%s')
    _totalDuration=$((_totalStop - _totalStart))
    echo "Total duration: ${_totalDuration}s"
    test -n "${returnCode}" && exit "$returnCode"

    # no test were run, this is likely an issue
    exit 1
}

################################################################################
# _run_helm_test
#
# Parameters
#   _test_name   - Name of the test
################################################################################
_run_helm_test() {
    local _test_number="${1}"
    local _test_name="${2}"
    local _smoke_file="${_tmpDir}/s${_test_number}"

    banner "Running with image  ${FOUNDATION_REGISTRY}/$(basename "${_test_name}")"

    #shellcheck disable=SC2086
    local _cmd="${CI_SCRIPTS_DIR}/run_helm_tests.sh \
        --namespace-suffix -${_test_number} \
        --helm-test ${_test_name} \
        --helm-chart charts/ping-devops/ \
        --helm-set-values global.image.pullPolicy=Always \
        --helm-set-values testFramework.finalStep.image=${DEPS_REGISTRY}busybox \
        ${NS_OPT}"

    if [ "${product}" == "pingaccess" ]; then
        # GitLab provided PA_DEFAULT_PASSWORD as a pipeline variable; GitHub CI
        # has no equivalent secret. The PA smoke suite only probes heartbeat
        # endpoints (no authentication), so any strong value satisfies the
        # image's 83-change-password hook — generate one when unset.
        if test -z "${PA_DEFAULT_PASSWORD:-}"; then
            PA_DEFAULT_PASSWORD="$(openssl rand -hex 16 2>/dev/null || head -c 16 /dev/urandom | xxd -p -c 32)"
        fi
        _cmd="${_cmd} --helm-set-values global.envs.PING_IDENTITY_PASSWORD=${PA_DEFAULT_PASSWORD}"
    fi

    echo "Running: $_cmd"

    local _start
    _start=$(date '+%s')

    echo_green "$_cmd" >> "${_smoke_file}"
    ${_cmd} >> "${_smoke_file}" 2>&1

    local _returnCode=${?}

    local _stop
    _stop=$(date '+%s')
    local _duration=$((_stop - _start))
    if test ${_returnCode} -ne 0; then
        local _result="FAIL"
    else
        local _result="PASS"
    fi

    append_status "${_resultsFile}" "${_result}" "${_reportPattern}" "${product}" "${_version:-none}" "${_shim:-none}" "${_jvm:-none}" "$(basename "${_test_name}")" "${_duration}" "${_result}"

    return "${_returnCode}"
}

trap _final EXIT

# result table header
_resultsFile="/tmp/$$.results"
_headerPattern=' %-25s| %-12s| %-20s| %-10s| %-38s| %10s| %7s\n'
_reportPattern='%-24s| %-12s| %-20s| %-10s| %-38s| %10s| %7s'

test -n "${VERBOSE}" && banner "kubectl describe nodes"
test -n "${VERBOSE}" && kubectl describe nodes

test -n "${VERBOSE}" && banner "kubectl get pods --all-namespaces"
test -n "${VERBOSE}" && kubectl get pods --all-namespaces

# shellcheck disable=SC2059
printf "${_headerPattern}" "PRODUCT" "VERSION" "SHIM" "JVM" "TEST" "DURATION" "RESULT" > ${_resultsFile}
_totalStart=$(date '+%s')
_smoke_cnt=0
_pids=()

#
# Calculating test to be run
#
_test="${_helm_test_override:-${CI_PROJECT_DIR}/helm-tests/smoke-tests/${product}}"
banner "Running smoke test found at: ${_test}"

#If this is a snapshot pipeline, override the image tag to snapshot image tags
test -n "${PING_IDENTITY_SNAPSHOT}" && _image_tag_override="latest-${ARCH}-$(date "+%m%d%Y")"

#
# If a tag is passed, then only run the smoke test for that tag
# otherwise, run for all the tag combinations taking into account
# versions, shims, jvms and architectures
#
if test -n "${_image_tag_override}"; then
    _tag="${_image_tag_override}"
    _smoke_cnt=1
    #
    # Running helm test
    #
    _run_helm_test "${_smoke_cnt}" "${_test}" "${_tag}" &

    _pids+=(["${_smoke_cnt}"]="$!")
else
    _smoke_cnt=1
    #
    # Running helm test
    #
    _run_helm_test "${_smoke_cnt}" "${_test}" &

    _pids+=(["${_smoke_cnt}"]="$!")
    # Throttle a bit so we don't thrash the cluster with traffic
    sleep 2
fi

#
# Inject a slight wait for everything to start up
#
sleep 2

#
# Loop through the background PIDs running, waiting on each one to finish and upon
# completing, cat the ouptut from that smoke test
#
for ((i = "${_smoke_cnt}"; i >= 1; i--)); do
    pid=${_pids[${i}]}

    _returnCode=1
    if [ -z "$pid" ]; then
        echo "No Process ID found for the $i smoke test" # should never happen
    else
        banner "Waiting on ${i} tests to finish..."
        wait "$pid"
        _returnCode=$?

        banner "Output for smoke test #${i}"
        cat "${_tmpDir}/s${i}"
    fi

    # if all tests succeed, will add up to zero in the end
    returnCode=$((returnCode + _returnCode))
done
