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

usage() { echo "Usage: $0 GO_VERSION [DEBIAN_TAG]"; exit 1; }

set -e

export GO_VERSION="$1"
export BUILD_TAG="$GO_VERSION"-`date +%Y-%m-%d_%H_%M`

if [ -z "$GO_VERSION" -o "$#" -gt 2 ]; then
  usage
fi

if [ "$#" -eq 2 ]; then
  export DEBIAN_TAG="$2"
else
  export DEBIAN_TAG="latest"
fi

envsubst '${GO_VERSION},${BUILD_TAG},${DEBIAN_TAG}' < cloudbuild.yaml.in > cloudbuild.yaml
gcloud beta container builds submit --config=cloudbuild.yaml .
