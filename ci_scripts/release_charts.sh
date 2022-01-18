#!/usr/bin/env bash
#
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

git clone -b "$CI_COMMIT_BRANCH" "https://${GITLAB_USER}:${GITLAB_TOKEN}@${INTERNAL_GITLAB_URL}/devops-program/helm-charts"
cd helm-charts || exit

# allow overwriting cr binary
CR="docker run -v ${CHARTS_HOME}:/cr quay.io/helmpack/chart-releaser:v${CR_VERSION} cr"
REPO="https://${GITLAB_USER}:${GITLAB_TOKEN}@${INTERNAL_GITLAB_URL}/devops-program/helm-charts"

function ensure_dir() {
    local dir=$1
    if [[ -d ${dir} ]]; then
        rm -rf ${dir}
    fi
    mkdir -p ${dir}
}

function find_changed_charts() {
    local charts_dir=$1
    echo $(git diff --find-renames --name-only "$latest_tag_rev" -- ${charts_dir} | cut -d '/' -f 2 | uniq)
}

function package_chart() {
    local chart=$1
    echo "Packaging chart '$chart'..."
    helm package ${CHARTS_HOME}/charts/$chart --destination ${CHARTS_PKGS}
}

function upload_packages() {
    ${CR} upload --git-repo ${REPO} -t ${GITHUB_TOKEN} --package-path /cr/.chart-packages
}

function update_chart_index() {
    ${CR} index -r ${REPO} -t "${GITHUB_TOKEN}" -c ${CHARTS_REPO} --index-path /cr/.chart-index --package-path /cr/.chart-packages
}

function git_setup() {
    git config user.email "devops_program@pingidentity.com"
    git config user.name "devops_program"
}

function publish_charts() {
    git_setup
    #change this to the real repo
    git clone "https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/wesleymccollam/helm-charts-test.git"
    cd helm-charts
    git checkout -b ${RELEASE_VERSION} || exit
    cp --force ${CHARTS_INDEX}/index.yaml docs/index.yaml
    git add docs/index.yaml
    git commit --message="Release ${RELEASE_VERSION}" --signoff
    if [[ "x${PUBLISH_CHARTS}" == "xtrue" ]]; then
        git push --set-upstream origin
    else
        git push --dry-run --set-upstream origin helm-charts
    fi
}

# install cr
# hack::ensure_cr
docker pull quay.io/helmpack/chart-releaser:v${CR_VERSION}

latest_tag=$(git::find_latest_tag)
echo "Latest tag: $latest_tag"

latest_tag_rev=$(git::get_revision "$latest_tag")
echo "$latest_tag_rev $latest_tag (latest tag)"

head_rev=$(git::get_revision HEAD)
echo "$head_rev HEAD"

for chart in $(find_changed_charts charts); do
    package_chart ${chart}
done

upload_packages
update_chart_index
publish_charts
