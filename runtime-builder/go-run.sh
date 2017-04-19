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

# go-run.sh runs Go binary wrapped with Stackdriver Debugger.
# usage: go-run.sh GO_BIN_PATH

set -e -x

goBin="$1"
shift

if [[ -f "./source-context.json" ]]; then
    service="${GAE_SERVICE:-default}"
    version="${GAE_VERSION:-default}"
    set +e; go-cloud-debug \
        -sourcecontext ./source-context.json \
        -appmodule "${service}" \
        -appversion "${version}" \
        -- "$goBin" "$@"
    exitCode="$?"
    if [[ "$exitCode" -eq 103 ]]; then
        # Fallback to running the binary itself if it fails to get the application default credentials.
        exec "$goBin" "$@"
    else
        exit "$exitCode"
    fi
else
    exec "$goBin" "$@"
fi
