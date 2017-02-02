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

# go-build.sh runs Go build in the workspace.
# usage: go-build.sh RUN_IMAGE WORKSPACE GOPATH

runimage="$1"
workspace="$2"
export GOPATH="$3"

cd "$workspace"
goDir="$(go list -e -f '{{.ImportComment}}' 2>/dev/null || true)"

if [ "$goDir" ]; then
	goDirPath="$GOPATH/src/$goDir"
	mkdir -p "$(dirname "$goDirPath")"
	ln -sfv "$workspace" "$goDirPath"
else
	mkdir -p "$GOPATH"
	ln -sfv "$workspace" "$GOPATH/src"
fi

go get -d
go build -o app

cat > Dockerfile <<EOF 
FROM $runimage
COPY app /go/bin/app
ENTRYPOINT ["/go/bin/app"]
EOF
