#!/usr/bin/env bash
#
# Ping Identity DevOps - CI scripts
#
# Check for any unmerged changes
#
test "${VERBOSE}" = "true" && set -x

#gimme jq
JQ=/usr/bin/jq
curl -sL https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 > $JQ && chmod +x $JQ
ls -la $JQ

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

_unmerged=$(grep -Rl '<<<<<<<' "${CI_PROJECT_DIR}" | grep -v "${0}")

test -z "${_unmerged}" && exit 0

echo "Found unmerged changes..."
echo "${_unmerged}"
exit 1
