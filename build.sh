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

usage() { echo "Usage: ./build.sh target_image_path build_tag"; exit 1; }

set -e

export IMAGE="$1"
export BUILD_TAG="$2"

if [ -z "$IMAGE" -o -z "$BUILD_TAG" ]; then
  usage
fi

envsubst < base/cloudbuild.yaml.in > base/cloudbuild.yaml
gcloud beta container builds submit --config=base/cloudbuild.yaml .

sed -e "s|{{RUN_IMAGE}}|$IMAGE:$BUILD_TAG|" < builder/Dockerfile.in > builder/Dockerfile
envsubst < builder/cloudbuild.yaml.in > builder/cloudbuild.yaml
gcloud beta container builds submit --config=builder/cloudbuild.yaml .
