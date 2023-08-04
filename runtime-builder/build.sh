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

set -e

usage() { echo "Usage: $0 <project> <go_version>"; exit 1; }

base_digest()
{
  # The following PR changed the base image from Docker V2 format to OCI format, which no longer works in
  # Flex deployments. So, the current solution is to pin to a gcr.io/distroless/base digest in Docker V2 format.
  # https://github.com/GoogleContainerTools/distroless/pull/1256
  export BASE_DIGEST="sha256:c88e34ed6523503e4f63c62a3384e2c3492c71d8cf4cc9f4bbee2b0349c6ee9a"
}

if [[ "$#" -ne 2 ]]; then
  usage
fi

export PROJECT_ID="$1"
export GO_VERSION="$2"
if [ -n "${TAG}" ]; then
  export BUILD_TAG="${TAG}"
else
  export BUILD_TAG="${GO_VERSION}"-$(date +%Y%m%d_%H%M)
fi

base_digest

echo "Building builder image with PROJECT_ID=${PROJECT_ID}, BUILD_TAG=${BUILD_TAG}, BASE_DIGEST=${BASE_DIGEST}"

gcloud builds submit \
  --project="${PROJECT_ID}" \
  --substitutions "_PROJECT_ID=${PROJECT_ID},_GO_VERSION=${GO_VERSION},_BUILD_TAG=${BUILD_TAG},_BASE_DIGEST=${BASE_DIGEST}" \
  --config=cloudbuild.yaml .

# Tagging the builder with 'staging' for integration test.
gcloud container images add-tag -q "gcr.io/${PROJECT_ID}/go1-builder:${BUILD_TAG}" "gcr.io/${PROJECT_ID}/go1-builder:staging"
