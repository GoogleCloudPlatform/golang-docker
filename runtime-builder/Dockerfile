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
#   debian_tag - DEBIAN tag for use when generating application Dockerfile.
# When this builder image is executed, it expects the application source files
# to be mounted at /workspace.

FROM gcr.io/google_appengine/debian8

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

ARG go_version
ARG debian_tag
ENV GO_VERSION ${go_version}
ENV DEBIAN_TAG ${debian_tag}

RUN curl -sSL https://storage.googleapis.com/golang/go${GO_VERSION}.linux-amd64.tar.gz -o /tmp/go.tar.gz && \
    curl -sSL https://storage.googleapis.com/golang/go${GO_VERSION}.linux-amd64.tar.gz.sha256 -o /tmp/go.tar.gz.sha256 && \
    echo "$(cat /tmp/go.tar.gz.sha256)  /tmp/go.tar.gz" | sha256sum -c - && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz /tmp/go.tar.gz.sha256

COPY go-build.sh /usr/local/bin/
COPY go-run.sh /usr/local/bin/

RUN curl -sSL https://storage.googleapis.com/cloud-debugger/compute-go/go-cloud-debug -o /usr/local/bin/go-cloud-debug && \
    chmod 755 /usr/local/bin/go-cloud-debug

ENTRYPOINT ["go-build.sh"]
CMD ["/workspace"]
