#!/bin/bash
# Copyright 2016 Google Inc. All rights reserved.
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

# test.bash builds the image and performs rudimentary checks.

set -e -x

IMG=gcr.io/google_appengine/golang

docker build -t $IMG base/
docker run --rm $IMG go version | grep go1\.6\.3

# Check that GOPATH is in the place expected by google.golang.org/appengine/cmd/aedeploy
docker run --rm $IMG bash -c 'go env | grep "GOPATH.*$PWD/_gopath"'

for case in $(find testdata -mindepth 1 -maxdepth 2 -type d); do
  cp testdata/Dockerfile $case
  # NOTE(cbro): re-use name to minimize number of images.
  docker build -t "${IMG}-test" $case
  docker run --rm "${IMG}-test"
  rm $case/Dockerfile
done
