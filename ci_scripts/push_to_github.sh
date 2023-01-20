#!/usr/bin/env bash
#
# Ping Identity DevOps - CI scripts
#
# Push docker build changes to github
#
test "${VERBOSE}" = "true" && set -x

if test -z "${CI_COMMIT_REF_NAME}"; then
    CI_PROJECT_DIR="$(
        cd "$(dirname "${0}")/.." || exit 97
        pwd
    )"
    test -z "${CI_PROJECT_DIR}" && echo "Invalid call to dirname ${0}" && exit 97
fi
CI_SCRIPTS_DIR="${CI_PROJECT_DIR:-.}/ci_scripts"
# shellcheck source=./ci_tools.lib.sh
. "${CI_SCRIPTS_DIR}/ci_tools.lib.sh"

rm -rf ~/tmp/build
mkdir -p ~/tmp/build && cd ~/tmp/build || exit 9
mkdir -p ~/.ssh || exit 9

echo "Writing GitHub host key"
echo "${GITHUB_HOST_KEY}" >> ~/.ssh/known_hosts

echo "Writing deploy token and SSH config"
echo "${GITHUB_DEPLOY_TOKEN}" > ~/.ssh/github_deploy_token || exit 9
chmod 600 ~/.ssh/github_deploy_token

echo "" >> ~/.ssh/config
echo "Host github.com-helm-charts" >> ~/.ssh/config
echo "    Hostname github.com" >> ~/.ssh/config
echo "    IdentityFile ~/.ssh/github_deploy_token" >> ~/.ssh/config
echo "" >> ~/.ssh/config

git clone "https://${GITLAB_USER}:${GITLAB_TOKEN}@${INTERNAL_GITLAB_URL}/devops-program/helm-charts"
cd helm-charts || exit 97

echo "Pushing to GitHub"
git remote add gh_location "git@github.com-helm-charts:${GITHUB_TARGET_REPO}.git"

if test -n "$CI_COMMIT_TAG"; then
    git push --force gh_location "$CI_COMMIT_TAG"
fi

git push --force gh_location master
