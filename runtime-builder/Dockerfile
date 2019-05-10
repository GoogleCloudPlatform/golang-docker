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

# Dockerfile for building a Go application and generating the corresponding
# application Dockerfile for it.  It expects the following build-args:
#   go_version - Go SDK version to be bundled in this image.
#   base_digest - distroless/base digest for use when generating application Dockerfile.
#   build_tag - Docker label added into generated application image to identify builder.
# When this builder image is executed, it expects the application source files
# to be mounted at the current work directory.

FROM gcr.io/gcp-runtimes/ubuntu_16_0_4:latest

ARG go_version
ARG base_digest
ARG build_tag
ENV GO_VERSION ${go_version}
ENV BASE_DIGEST ${base_digest}
ENV BUILD_TAG ${build_tag}

RUN apt-get update -yq && apt-get upgrade -yq

# Copy checksum for use in validation.
COPY checksums/go${GO_VERSION}.sha256 /tmp/

# Download SDK and validate.
ADD https://storage.googleapis.com/golang/go${GO_VERSION}.linux-amd64.tar.gz /tmp/go.tar.gz
RUN echo "$(cat /tmp/go${GO_VERSION}.sha256)  /tmp/go.tar.gz" | sha256sum -c - && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz /tmp/go${GO_VERSION}.sha256

COPY go-build.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/go-build.sh

ENTRYPOINT ["go-build.sh"]
