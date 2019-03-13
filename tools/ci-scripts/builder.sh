#!/bin/bash
export KOKORO_GITHUB_DIR=${KOKORO_ROOT}/src/github
source ${KOKORO_GFILE_DIR}/common.sh

cd ${KOKORO_GITHUB_DIR}/golang-docker/runtime-builder

./build.sh ${PROJECT_ID} ${GO_VERSION}
