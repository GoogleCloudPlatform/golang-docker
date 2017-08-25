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

# test.sh deploys the test app and run the integration test on it.

usage() { echo "Usage: $0 <project_id> [builder_image_tag]"; exit 1; }

set -e

PROJECT="$1"
if [[ -z "${PROJECT}" ]]; then
    usage
fi

# Use staging tag if builder_image_tag argument is not set since latest build
# will always be tagged with 'staging'.
TAG="${2:-staging}"
STAGING_BUILDER_IMAGE="gcr.io/${PROJECT}/go1-builder:${TAG}"
echo "Builder image: ${STAGING_BUILDER_IMAGE}"

# Make sure gcloud is configured to use the local directory.
use_rb="$(gcloud config get-value app/use_runtime_builders)"
rb_root="$(gcloud config get-value app/runtime_builders_root)"
if [[ "${use_rb}" = "False" || "${rb_root}" != file://* ]]; then
    echo "Wrong gcloud config found for app/use_runtime_builders or app/runtime_builders_root."
    exit 1
fi

# Generate test.yaml from test.yaml.in by substituting STAGING_BUILDER_IMAGE variable.
# test.yaml is referenced in runtimes.yaml as the cloudbuild.yaml file.
sed "s|\${STAGING_BUILDER_IMAGE}|${STAGING_BUILDER_IMAGE}|" test.yaml.in > test.yaml

cd $(dirname $0)
export GOPATH=$(pwd -P)

echo "Deploying test app using config in ${rb_root}/runtimes.yaml"
gcloud beta app deploy -q --project="${PROJECT}" src/app/app.yaml
gcloud container builds submit --project="${PROJECT}" --config=go-test.yaml .
