# gcr.io/google_appengine/golang

`gcr.io/google_appengine/golang` is a [docker](https://docker.io) base image that bundles the latest version of [Go](http://golang.org) installed from [golang.org](http://golang.org/doc/install/).

It serves as a base for Go apps running on Google App Engine [Managed VMs](https://cloud.google.com/appengine/docs/go/managed-vms/).

## Notes

`GO15VENDOREXPERIMENT` is set to `1`

## Usage

- Create a Dockerfile in your Go application directory with the following content:

        FROM gcr.io/google_appengine/golang

        COPY . /go/src/app
        RUN go-wrapper install -tags appenginevm

- Run the following command in your application directory:

        docker build -t my/app .

