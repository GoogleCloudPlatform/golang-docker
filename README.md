golang-docker
=============

[![Build Status](https://travis-ci.org/GoogleCloudPlatform/golang-docker.svg?branch=master)](https://travis-ci.org/GoogleCloudPlatform/golang-docker)

This repository contains sources for the Go App Engine Flex build pipeline.
This build pipeline utilizes [Google Cloud Build](https://cloud.google.com/cloud-build/) to produce the application image.
The `go-1.x.yaml` configuration files are used in the build pipeline.
User can now specify a Go version in app.yaml via `runtime: go1.x`, where `1.x`
can be 1.8, 1.9, etc. The resulting application image uses [gcr.io/distroless/base](https://github.com/GoogleCloudPlatform/distroless/tree/master/base)
as the base image, which contains a minimal Linux, glibc-based system.

The builder image `gcr.io/gcp-runtimes/go1-builder` is tagged with supported Go
major versions for builds to be able to target specific Go version to build
against. Run the following gcloud command to list supported versions --

```shell
$ gcloud container images list-tags gcr.io/gcp-runtimes/go1-builder
```

**Use only the Go major version tags e.g. 1.8, 1.9, instead of the unique
version-datetime tags.**

There are different ways to reuse the `go1-builder` image outside of AppEngine
Flex. Here are a couple of examples.

## Multi-stage Dockerfile

Read up on [how to use Docker's multi-stage
builds](https://docs.docker.com/engine/userguide/eng-image/multistage-build/).

Following is a trivial example of a Dockerfile with multi-stage build using the
`go1-builder` image to bring in the Go SDK. The Go SDK is located under
/usr/local/go of the builder image.

```dockerfile
FROM gcr.io/gcp-runtimes/go1-builder:1.9 as builder

WORKDIR /go/src/app
COPY main.go .

RUN /usr/local/go/bin/go build -o app .

# Application image.
FROM gcr.io/distroless/base:latest

COPY --from=builder /go/src/app/app /usr/local/bin/app

CMD ["/usr/local/bin/app"]
```

## Google Cloud Build

Read up on [Google Cloud Build](https://cloud.google.com/cloud-build/docs/).

You can use one of the `go-1.x.yaml` files for configuration file. The builder
image's `ENTRYPOINT` is the `go-build.sh` script, which expects a certain layout
of the uploaded directory. In particular, it expects --

*   `_gopath/src` directory containing Go source files within package directory
    structure.
*   `_gopath/main-package-path` file containing the import path of the main
    application to be built.
*   top level directory can contain resource files that will be bundled into the
    application image's `/app` directory.

The build script will build the application as referenced in
`_gopath/main-package-path` file and produce an application Dockerfile which the
next step will run a docker build on.

You can customize your own cloudbuild.yaml file with your own Dockerfile.
