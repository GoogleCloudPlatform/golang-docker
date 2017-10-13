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

# go-build.sh builds the Go application in the current work directory and
# generates a Dockerfile in that same directory.

set -e

workspace="$(pwd -P)"

if [[ -z "${GO_VERSION}" || -z "${BASE_DIGEST}" || -z "${BUILD_TAG}" ]]; then
    echo "Missing env variable(s): GO_VERSION='${GO_VERSION}', BASE_DIGEST='${BASE_DIGEST}', BUILD_TAG='${BUILD_TAG}'."
    exit 1
fi

export PATH=/usr/local/go/bin:"${PATH}"
export GOPATH="${workspace}"/_gopath

# $workspace contains files and directories in original app.yaml directory. It
# consists of the main package files as well as application resource files.
# If there are dependency packages, $workspace will also contain _gopath
# directory containing these with the proper GOPATH structure.


# If there is _gopath/main-package-path file, reconstruct the main path relative
# to GOPATH/src by moving files over.
mainpath=""
if [[ -f "${GOPATH}/main-package-path" ]]; then
  mainpkg=$(cat "${GOPATH}/main-package-path")
  if [[ "$mainpkg" != "" ]]; then
    mainpath="${GOPATH}/src/${mainpkg}"
    mkdir -p "${mainpath}"
    for f in $(find . -mindepth 1 -maxdepth 1 ! -name "$(basename $GOPATH)")
    do
      rm -rf ${mainpath}/${f}
      mv ${f} ${mainpath}/${f}
    done
  fi
fi

# If not, construct a temporary staging directory.  This is to avoid naming
# collisions in ${workspace}.
if [[ "$mainpath" = "" ]]; then
  mainpath=$(mktemp -d staging.XXXX)
  find . -mindepth 1 -maxdepth 1 ! -name "${mainpath}" ! -name "$(basename $GOPATH)" -exec mv {} "${mainpath}"/ \;
fi

# Create a bin/ directory containing all the binaries needed in the final image.
mkdir bin

# Run the build.
cd "${mainpath}"
go build -o "${workspace}"/bin/app -tags appenginevm

# Move application files into app subdirectory.
cd "${workspace}"
mv "${mainpath}" "${workspace}"/app

# Generate application Dockerfile.
cat > Dockerfile <<EOF
FROM gcr.io/distroless/base@${BASE_DIGEST}

LABEL build_tag="${BUILD_TAG}"
LABEL go_version="${GO_VERSION}"

COPY bin/ /usr/local/bin/
COPY app/ /app/

WORKDIR /app
ENTRYPOINT ["/usr/local/bin/app"]
EOF
