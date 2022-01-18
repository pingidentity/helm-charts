#!/usr/bin/env bash

git clone -b "$CI_COMMIT_BRANCH" "https://${GITLAB_USER}:${GITLAB_TOKEN}@${INTERNAL_GITLAB_URL}/devops-program/helm-charts"
cd helm-charts || exit
git config user.email "devops_program@pingidentity.com"
git config user.name "devops_program"

helm lint charts/ping-devops
