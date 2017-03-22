#!/bin/bash

# Copyright 2017 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Build script to build the Go runtime builder image.
# Required arguments:
#   project - GCP project ID for image name.
#   go_version - Go SDK version to bundle into image.
#   debian_tag - Debian tag for application base image.

usage() { echo "Usage: $0 <project> <go_version> <debian_tag>"; exit 1; }

set -e

if [ "$#" -ne 3 ]; then
  usage
fi

export PROJECT_ID="$1"
export GO_VERSION="$2"
export DEBIAN_TAG="$3"
export BUILD_TAG="${GO_VERSION}"-$(date +%Y%m%d_%H%M)

echo "Building builder image with PROJECT_ID=${PROJECT_ID}, BUILD_TAG=${BUILD_TAG}, DEBIAN_TAG=${DEBIAN_TAG}"

gcloud beta container builds submit \
  --substitutions "_PROJECT_ID=${PROJECT_ID},_GO_VERSION=${GO_VERSION},_BUILD_TAG=${BUILD_TAG},_DEBIAN_TAG=${DEBIAN_TAG}" \
  --config=cloudbuild.yaml .
