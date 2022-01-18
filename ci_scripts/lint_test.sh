#!/usr/bin/env bash

git clone git@gitlab.corp.pingidentity.com:devops-program/helm-charts.git
cd helm-charts || exit
ct lint --validate-maintainers=false