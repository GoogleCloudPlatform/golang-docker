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

debian_digest()
{
  local digest="$(gcloud beta container images describe gcr.io/google-appengine/debian8:latest | \
    grep '^Image:' | cut -d'@' -f2 | grep '^sha256:')"

  # The digest consists a prefix "sha256:", the hash string and a trailing newline character.
  if [[ "$(echo ${digest} | wc -c)" -ne 72 ]]; then
    echo "$0: unable to parse digest of debian8 image: ${digest}"
    exit 1
  fi
  export DEBIAN_DIGEST="${digest}"
}

if [[ "$#" -ne 2 ]]; then
  usage
fi

export PROJECT_ID="$1"
export GO_VERSION="$2"
export BUILD_TAG="${GO_VERSION}"-$(date +%Y%m%d_%H%M)

debian_digest

echo "Building builder image with PROJECT_ID=${PROJECT_ID}, BUILD_TAG=${BUILD_TAG}, DEBIAN_DIGEST=${DEBIAN_DIGEST}"

gcloud beta container builds submit \
  --project="${PROJECT_ID}" \
  --substitutions "_PROJECT_ID=${PROJECT_ID},_GO_VERSION=${GO_VERSION},_BUILD_TAG=${BUILD_TAG},_DEBIAN_DIGEST=${DEBIAN_DIGEST}" \
  --config=cloudbuild.yaml .
