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

pwd=$(pwd)
CR="docker run -v ${pwd}/docs:/cr quay.io/helmpack/chart-releaser:v${CR_VERSION}"
GITLAB_REPO="https://${GITLAB_USER}:${GITLAB_TOKEN}@${INTERNAL_GITLAB_URL}/devops-program/helm-charts"
GITHUB_REPO="helm-charts-test"
HELM_REPO="https://helm.pingidentity.com/"
chart="charts/ping-devops"

git clone -b "${CI_COMMIT_BRANCH}" "${GITLAB_REPO}"
cd helm-charts || exit

function package_chart() {
    echo "Packaging chart '${chart}'..."
    dir="${pwd}/cr"
    if [ -d "${dir}" ]; then
        mkdir cr
    fi
    helm package ${pwd}/${chart} --destination ${pwd}/docs/.chart-packages || exit
}

function upload_packages() {
    ${CR} upload -o ${GITHUB_OWNER} -r helm-charts-test --token ${GITHUB_TOKEN} --package-path /cr/.chart-packages || exit
}

function update_chart_index() {
    ${CR} index -o ${GITHUB_OWNER} -r helm-charts-test -c ${HELM_REPO} --token ${GITHUB_TOKEN} --index-path /cr/index.yaml --package-path /cr/.chart-packages --pr || exit
    git status
}

# function publish_charts() {
#     git remote add gh_location "https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/wesleymccollam/helm-charts-test.git"
#     git config user.email "devops_program@pingidentity.com"
#     git config user.name "devops_program"
#     #change this to the real repo
#     git clone "https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/wesleymccollam/helm-charts-test.git"
#     cd helm-charts-test
#     git checkout -b ${RELEASE_VERSION} || exit
#     yes | cp  ${pwd}/index.yaml docs/index.yaml
#     git add docs/index.yaml
#     git commit -m="Release ${RELEASE_VERSION}" --signoff
#     if test -n "$CI_COMMIT_TAG"; then
#         git push gh_location "$CI_COMMIT_TAG"
#     fi
#     git push gh_location origin master
# }

# install cr
docker pull quay.io/helmpack/chart-releaser:v${CR_VERSION}

package_chart ${chart}
upload_packages
update_chart_index
# publish_charts
