#!/usr/bin/env bash
# Copyright © 2026 Ping Identity Corporation

# Run from the checked-out workspace (no clone; CI_PROJECT_DIR is provided
# at workflow level in helm-tests.yml; fallback covers local runs).
cd "${CI_PROJECT_DIR:-$(cd "$(dirname "${0}")/.." && pwd)}" || exit
helm lint charts/ping-devops || exit
