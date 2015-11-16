# gcr.io/google_appengine/golang

`gcr.io/google_appengine/golang` is a [docker](https://docker.io) base image
that bundles the latest version of [Go](http://golang.org) installed from
[golang.org](http://golang.org/doc/install/).

It serves as a base for Go apps running on Google App Engine
[Managed VMs](https://cloud.google.com/appengine/docs/go/managed-vms/).

## Notes

### Vendoring

Your application will be built using Go 1.5.1 inside the docker instance without
the experimental vendoring support.  To enable Go 1.5 experimental vendoring
support, set the environment variable like this:

        FROM gcr.io/google_appengine/golang
        ENV GO15VENDOREXPERIMENT 1
        COPY . /go/src/app
        RUN go-wrapper install -tags appenginevm

For Go 1.5 vendoring details, see the documentation for the
[go command](https://golang.org/cmd/go/#hdr-Vendor_Directories)
and the [design document](https://golang.org/s/go15vendor).
As of 2015-08-27, the following Go package management apps support this new flag:
[godep](https://github.com/tools/godep),
[govendor](https://github.com/kardianos/govendor),
and [glide](https://github.com/Masterminds/glide).

### Using Go 1.4

To use Go 1.4, edit the app.yaml file and remove the "runtime: go" line then
provide your own Dockerfile in the same directory as the app.yaml file, like this:

        FROM golang:1.4-onbuild
        COPY . /go/src/app
        RUN go-wrapper install -tags appenginevm

## Usage

- Create a Dockerfile in your Go application directory with the following content:

        FROM gcr.io/google_appengine/golang

        COPY . /go/src/app
        RUN go-wrapper install -tags appenginevm

- Run the following command in your application directory:

        docker build -t my/app .
