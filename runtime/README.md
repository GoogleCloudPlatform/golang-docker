# google/golang-runtime

[`google/golang-runtime`](https://index.docker.io/u/google/golang-runtime) is a [docker](https://docker.io) base image for easily running [golang](http://golang.org) application.

It is based on [`google/golang`](https://index.docker.io/u/google/golang) base image.

## Usage

- Create a Dockerfile in your golang application directory with the following content:

        FROM google/golang-runtime

- Run the following command in your application directory:

        docker build -t my/app .

## Notes

The image assumes that your application:

- has a `main` package
- listens on port `8080`
- may have a `gopath` subdirectory containing a `GOPATH` with internal packages dependencies, eg:

        gopath/
        gopath/src/internal
        gopath/src/internal/internal.go
        gopath/src/corp
        gopath/src/corp/corp.go

When building your application docker image, dependencies of your application are automatically fetched using `go get` if not present in the `gopath` subdirectory.
