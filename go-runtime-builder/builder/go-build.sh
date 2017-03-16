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
# limitations under the License

# go-build.sh runs Go build in the workspace.
# usage: go-build.sh WORKSPACE

set -e

workspace="$1"
cd "$workspace"
staging=$(mktemp -d staging.XXXX) # contains the source files without dependencies
find . -mindepth 1 -maxdepth 1 ! -name "$staging" ! -name "$(basename $GOPATH)" -exec mv {} "$staging"/ \;

mkdir bin # contains all the bianries we need in the final image
cd "$staging"
go build -o "$workspace"/bin/app -tags appenginevm
cd "$workspace"

mv /usr/local/bin/go-run.sh bin/go-run.sh
mv /usr/local/bin/go-cloud-debug bin/go-cloud-debug
chmod 755 bin/go-cloud-debug

cat > Dockerfile <<EOF
FROM gcr.io/google_appengine/debian8

ENV PATH /go/bin:/usr/local/go/bin:$PATH

COPY bin/ /usr/local/bin/
COPY $staging /app

WORKDIR /app
ENTRYPOINT ["go-run.sh", "/usr/local/bin/app"]
EOF
