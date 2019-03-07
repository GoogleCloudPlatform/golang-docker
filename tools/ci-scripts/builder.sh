#!/bin/bash
source ${KOKORO_ROOT}/src/github/golang-docker/tools/ci-scripts/common.sh
cd ${KOKORO_GITHUB_DIR}/golang-docker/runtime-builder

./build.sh ${PROJECT_ID} ${GO_VERSION}
