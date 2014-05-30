# google/golang-hello

[`google/golang-hello`](https://index.docker.io/u/google/golang) is a [docker](https://docker.io) image for the [golang](http://golang.org) [net/http](http://golang.org/pkg/net/http/) package hello world application.

It is based on [`google/golang-runtime`](https://index.docker.io/u/google/golang-runtime) base image and listen on port `8080`.

## Usage

- Run the following command

        docker run -p 8080 google/golang-hello
