# gcr.io/google-appengine/golang

`gcr.io/google-appengine/golang` is a [docker](https://docker.io) base image
that bundles the latest version of [Go](http://golang.org) installed from
[golang.org](http://golang.org/doc/install/).

It serves as a base for Go apps running on Google App Engine
[Managed VMs](https://cloud.google.com/appengine/docs/go/managed-vms/).

## Using Go 1.4

To use Go 1.4, edit the app.yaml file and remove the "runtime: go" line then
provide your own Dockerfile in the same directory as the app.yaml file, like this:

        FROM golang:1.4-onbuild
        COPY . /go/src/app
        RUN go-wrapper install -tags appenginevm

## Usage

- Create a Dockerfile in your Go application directory with the following content:

        FROM gcr.io/google-appengine/golang

        COPY . /go/src/app
        RUN go-wrapper install -tags appenginevm

- Run the following command in your application directory:

        docker build -t my/app .
