#!/usr/bin/env bash
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

dir=$(pwd)
cr="docker run -v ${dir}/docs:/cr quay.io/helmpack/chart-releaser:v${CR_VERSION}"
gitlab_repo="https://${GITLAB_USER}:${GITLAB_TOKEN}@${INTERNAL_GITLAB_URL}/devops-program/helm-charts"
github_repo="helm-charts"
helm_repo="https://helm.pingidentity.com/"
chart="charts/ping-devops"

git clone -b "${CI_COMMIT_BRANCH}" "${gitlab_repo}"
cd helm-charts || exit

function package_chart() {
    echo "Packaging chart '${chart}'..."
    helm package "${dir}"/"${chart}" --destination "${dir}"/docs/.chart-packages || exit 1
}

function upload_packages() {
    echo "Uploading chart packages for ${chart}..."
    ${cr} upload -o "${GITHUB_OWNER}" -r "${github_repo}" --token "${GITHUB_TOKEN}" --package-path /cr/.chart-packages || exit 1
}

function update_chart_index() {
    echo "Generating chart index for ${chart}..."
    ${cr} index -o "${GITHUB_OWNER}" -r "${github_repo}" -c "${helm_repo}" --token "${GITHUB_TOKEN}" --index-path /cr/index.yaml --package-path /cr/.chart-packages || exit 1
}

function publish_repo() {
    git status
    git add docs/index.yaml
    release_tag=$(cat "${dir}"/charts/ping-devops/Chart.yaml | grep "version" | awk '{print $2}')
    echo "Release ${release_tag} desired. Checking for conflicts..."
    curl --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "https://${INTERNAL_GITLAB_URL}/api/v4/projects/7116/repository/tags/${release_tag}" > tag.txt || exit
    check_tag=$(cat tag.txt | grep -o "\"404" | head -1 | sed 's/"//g')
    if [[ ${check_tag} == 404 ]]; then
        echo "${release_tag} release tag is available, creating tag..."
        git tag "${release_tag}"
    else
        echo "Release tag ${release_tag} already exists..."
        exit 1
    fi
    git commit --message "Release ${release_tag}"
    git push -o ci-skip "https://${GITLAB_USER}:${GITLAB_TOKEN}@${INTERNAL_GITLAB_URL}/devops-program/helm-charts" HEAD:master
    git push --tags "https://${GITLAB_USER}:${GITLAB_TOKEN}@${INTERNAL_GITLAB_URL}/devops-program/helm-charts" HEAD:master
}

# install cr
docker pull quay.io/helmpack/chart-releaser:v"${CR_VERSION}"

package_chart ${chart}
upload_packages
update_chart_index
publish_repo
