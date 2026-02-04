#!/usr/bin/env bash
# Copyright © 2026 Ping Identity Corporation

#
# Ping Identity DevOps - CI scripts
#
# Run yaml unit tests with helm template.
#
# NOTE: To run individual tests locally, you can run the test_helm_template.py script directly.
#

# Run each test file found in the template-tests directory
set -e
find ./helm-tests/template-tests -type f -print0 | while IFS= read -r -d '' _file; do
    _testFilename=$(basename "${_file}")
    _extension=${_testFilename##*.}
    if test "${_testFilename}" != ".gitlab-ci.yml" && (test "${_extension}" = "yaml" || test "${_extension}" = "yml"); then
        ./ci_scripts/test_helm_template.py test --test-file "${_file}"
    fi
done
set +e
