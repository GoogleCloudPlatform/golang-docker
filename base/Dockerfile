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

# Dockerfile that runs a App Engine flexible environment Go application.
FROM gcr.io/google-appengine/debian8

RUN apt-get update \
    && apt-get install -y \
       curl \
       --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

ENV GO_VERSION 1.8

RUN curl -sSL https://storage.googleapis.com/golang/go$GO_VERSION.linux-amd64.tar.gz -o /tmp/go.tar.gz && \
    CHECKSUM=53ab94104ee3923e228a2cb2116e5e462ad3ebaeea06ff04463479d7f12d27ca && \
    echo "${CHECKSUM}  /tmp/go.tar.gz" | sha256sum -c - && \
    tar -C /usr/local -vxzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz

ENV PATH /go/bin:/usr/local/go/bin:$PATH
ENV GOPATH /go:/go/src/app/_gopath

RUN mkdir -p /go/src/app /go/bin && chmod -R 777 /go

COPY third_party/go-wrapper/go-wrapper /usr/local/bin/go-wrapper
RUN chmod 755 /usr/local/bin/go-wrapper

RUN ln -s /go/src/app /app
WORKDIR /go/src/app

RUN curl -sSL https://storage.googleapis.com/cloud-debugger/compute-go/go-cloud-debug -o /usr/local/bin/go-cloud-debug && \
    chmod 755 /usr/local/bin/go-cloud-debug

LABEL go_version=$GO_VERSION

CMD ["go-wrapper", "run"]

