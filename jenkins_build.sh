#!/bin/bash

# Copyright 2016 Google Inc. All rights reserved.

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

sed -i "s,^\(FROM.*\),\\1:$BASE_TAG," base/Dockerfile

RUNTIME_NAME="golang"

if [ -z "${TAG}" ]; then
  export TAG=`date +%Y-%m-%d_%H_%M`
fi

CANDIDATE_NAME="${TAG}"
echo "CANDIDATE_NAME:${CANDIDATE_NAME}"
export IMAGE="${DOCKER_NAMESPACE}/${RUNTIME_NAME}:${CANDIDATE_NAME}"

envsubst < base/cloudbuild.yaml.in > base/cloudbuild.yaml

gcloud builds submit --config=base/cloudbuild.yaml . -q

if [ "${UPLOAD_TO_STAGING}" = "true" ]; then
  STAGING="${DOCKER_NAMESPACE}/${RUNTIME_NAME}:staging"
  docker tag -f "${IMAGE}" "${STAGING}"
  gcloud docker push "${STAGING}"
fi
