#!/bin/bash
export KOKORO_GITHUB_DIR=${KOKORO_ROOT}/src/github

# Help debug auth used by the pipelines.
gcloud auth list

source ${KOKORO_GFILE_DIR}/kokoro/common.sh

cd ${KOKORO_GITHUB_DIR}/golang-docker/runtime-builder

./build.sh ${PROJECT_ID} ${GO_VERSION}
