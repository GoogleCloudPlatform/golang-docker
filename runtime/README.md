# google/golang-runtime

[`google/golang-runtime`](https://index.docker.io/u/google/golang-runtime) is a [docker](https://docker.io) base image that makes it easy to dockerize standard [golang](http://golang.org) applications.

It can automatically bundle a golang application with its dependencies and set the default entrypoint to the compiled binary with no additional Dockerfile instructions.

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
- may have a `.godir` file containing the import path for your application if it vendors its dependencies

When building your application docker image, `ONBUILD` triggers fetch non-vendored dependencies of your application using `go get`.
