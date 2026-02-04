#!/usr/bin/env bash
# Copyright © 2026 Ping Identity Corporation

set -x
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

curl_output=/tmp/curlout
github_api_base="https://api.github.com/repos/${GITHUB_OWNER}/helm-charts"
git clone "https://${GITLAB_USER}:${GITLAB_TOKEN}@${INTERNAL_GITLAB_URL}/devops-program/helm-charts"
cd helm-charts || exit

function check_for_draft_release() {
    sem_version=$(grep "version" charts/ping-devops/Chart.yaml | awk '{print $2}')
    expected_tag="ping-devops-${sem_version}"

    if test "${CI_COMMIT_TAG}" != "${expected_tag}"; then
        echo "Gitlab tag \"${CI_COMMIT_TAG}\" does not match expected tag \"${expected_tag}\" for release"
        exit 1
    fi

    echo "Checking that draft release ${expected_tag} exists and is ready to be published..."

    # Verify that the draft release is set up with the right tag
    curl -s \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer ${GITHUB_TOKEN}" \
        "${github_api_base}/releases" > "${curl_output}"
    release_id=$(jq -r '.[] | select(.tag_name=="'"${expected_tag}"'" and .draft==true) | .id' "${curl_output}")

    if test -z "${release_id}"; then
        echo "Expected draft release not found for tag \"${expected_tag}\""
        cat /tmp/curlout
        exit 1
    fi

    # Verify that the draft release has the correct Helm package attached
    curl -s \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer ${GITHUB_TOKEN}" \
        "${github_api_base}/releases/${release_id}" > "${curl_output}"
    release_package=$(jq -r '.assets | .[] | select(.name=="'"${expected_tag}.tgz"'") | .name' "${curl_output}")

    if test -z "${release_package}"; then
        echo "Draft release does not have required Helm package \"${expected_tag}.tgz\" attached"
        cat /tmp/curlout
        exit 1
    fi

    # Verify that the tag for the release exists on GitHub
    curl -s \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer ${GITHUB_TOKEN}" \
        "${github_api_base}/git/matching-refs/tags/${expected_tag}" > "${curl_output}"
    found_tag=$(jq -r '.[] | .ref' "${curl_output}")

    if test -z "${found_tag}"; then
        echo "The expected tag \"${expected_tag}\" does not exist on the GitHub repository"
        cat /tmp/curlout
        exit 1
    fi
}

function publish_release() {
    echo "Publishing the draft release on GitHub for ${expected_tag}..."

    curl_result=$(curl -s -o /tmp/curlout -w "%{http_code}" -X PATCH -H "Accept: application/vnd.github+json" -H "Authorization: Bearer ${GITHUB_TOKEN}" "${github_api_base}/releases/${release_id}" -d '{"draft":false}')

    if test "${curl_result}" != 200; then
        echo "Failed to publish draft release. HTTP result code ${curl_result}"
        cat /tmp/curlout
        exit 1
    fi
}

function notify_slack() {
    # Post to the Helm slack channel via a webhook
    curl -X POST "${SLACK_WEBHOOK}"
}

check_for_draft_release
publish_release
notify_slack

set +x
