# google/golang-runtime

[`google/golang-runtime`](https://index.docker.io/u/google/golang-runtime) is a [docker](https://docker.io) base image for easily building containers for standard [golang](http://golang.org) applications.

It can automatically bundle a golang application with its dependencies and set the default entrypoint with no additional Dockerfile instructions.

It is based on [`google/golang`](https://index.docker.io/u/google/golang) base image.

## Usage

- Create a Dockerfile in your golang application directory with the following content:

        FROM google/golang-runtime

- Build your container image by running the following command in your application directory:

        docker build -t app .

## Sample

See the [sources](/hello) for [`google/golang-hello`](https://index.docker.io/u/google/golang) based on this image.

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

When building your application docker image, `ONBUILD` triggers fetch the dependencies of your application using `go get` if not present in the `gopath` subdirectory.
