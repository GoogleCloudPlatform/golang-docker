# Dockerfile extending the generic Go image with application files for a
# single application.
FROM gcr.io/google_appengine/base

RUN apt-get update \
    && apt-get install -y \
       curl gcc git libc6-dev make \
       --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

ENV GO_VERSION 1.5

RUN curl -sSL https://golang.org/dl/go$GO_VERSION.linux-amd64.tar.gz \
    | tar -v -C /usr/local -xz

ENV PATH /go/bin:/usr/local/go/bin:$PATH
ENV GOPATH /go:/go/src/app/_gopath

RUN mkdir -p /go/src/app /go/bin && chmod -R 777 /go

COPY go-wrapper /usr/local/bin/
RUN chmod 755 /usr/local/bin/go-wrapper

RUN ln -s /go/src/app /app
WORKDIR /go/src/app

CMD ["go-wrapper", "run"]
