#!/bin/bash

set -euxo pipefail

REPO=$1
RENDERED_PATH=$2

for BRANCH in $(ls $RENDERED_PATH); do
    echo "Publishing $BRANCH..."

    pushd ${RENDERED_PATH}/${BRANCH}

    git init
    if git ls-remote --heads ${REPO} ${BRANCH} | grep ${BRANCH} >/dev/null; then
        git remote add origin ${REPO}
        git checkout -b ${BRANCH}
    else
        git remote add origin ${REPO} -f -t ${BRANCH}
        git checkout -B ${BRANCH}
    fi

    # commit the latest version of generated files
    git add .
    git commit -m "Sync cos-configuration" --author "Managed Solutions Automation <managed-solutions@canonical.com>"
    git push origin ${BRANCH}:${BRANCH} --force

    popd
done

set +x
