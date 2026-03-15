#!/bin/bash

set -euo pipefail

RENDERED_PATH=${1:?Usage: scripts/publish.sh <rendered-path>}

: "${GITHUB_TOKEN:?GITHUB_TOKEN must be set}"
: "${GITHUB_REPOSITORY:?GITHUB_REPOSITORY must be set}"
: "${GITHUB_ACTOR:?GITHUB_ACTOR must be set}"

if [[ ! -d "${RENDERED_PATH}" ]]; then
    echo "Rendered path '${RENDERED_PATH}' does not exist or is not a directory."
    exit 1
fi

REPO="https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"

for BRANCH in $(ls $RENDERED_PATH); do
    echo "Publishing $BRANCH..."

    pushd ${RENDERED_PATH}/${BRANCH}

    git init
    if git ls-remote --heads ${REPO} ${BRANCH} | grep ${BRANCH} >/dev/null; then
        git remote add origin ${REPO}
        git checkout -b ${BRANCH}
    else
        git remote add origin ${REPO} -t ${BRANCH}
        git checkout -B ${BRANCH}
    fi

    # commit the latest version of generated files
    git add .
    git config user.name "${GITHUB_ACTOR}"
    git config user.email "${GITHUB_ACTOR}@users.noreply.github.com"
    git commit -m "Sync cos-configuration"
    git push origin ${BRANCH}:${BRANCH} --force

    popd
done
