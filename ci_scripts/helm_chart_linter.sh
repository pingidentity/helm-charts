#!/usr/bin/env bash
# Copyright © 2026 Ping Identity Corporation

if test -n "$CI_COMMIT_BRANCH"; then
    git clone -b "$CI_COMMIT_BRANCH" "https://${GITLAB_USER}:${GITLAB_TOKEN}@${INTERNAL_GITLAB_URL}/devops-program/helm-charts"
else
    git clone "https://${GITLAB_USER}:${GITLAB_TOKEN}@${INTERNAL_GITLAB_URL}/devops-program/helm-charts"
fi

cd helm-charts || exit
helm lint charts/ping-devops || exit
