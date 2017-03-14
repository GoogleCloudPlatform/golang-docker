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
# usage: go-build.sh RUN_IMAGE WORKSPACE

set -e

workspace="$1"
cd "$workspace"
go build -o app -tags appenginevm

mv /usr/local/bin/* .

cat > Dockerfile <<EOF
FROM gcr.io/google_appengine/debian8

RUN apt-get update \
    && apt-get install -y \
       curl \
       --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

ENV PATH /go/bin:/usr/local/go/bin:$PATH

RUN mkdir -p /go/src/app /go/bin && chmod -R 777 /go

COPY go-run.sh /usr/local/bin/go-run
RUN chmod 755 /usr/local/bin/go-run

COPY go-cloud-debug-agent /usr/local/bin/go-cloud-debug
RUN chmod 755 /usr/local/bin/go-cloud-debug

COPY . /app
WORKDIR /app
ENTRYPOINT ["go-run", "/app/app"]
EOF
