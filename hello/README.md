# google/golang-hello

[`google/golang-hello`](https://index.docker.io/u/google/golang-hello) is a [docker](https://docker.io) image for a hello world application using ["github.com/gorilla/mux"](http://www.gorillatoolkit.org/pkg/mux).

It is based on [`google/golang-runtime`](https://index.docker.io/u/google/golang-runtime) base image and listen on port `8080`.

It also imports package `internal` from the [`vendor`](vendor) subdirectory and define its import path in [`.godir`](.godir).

## Usage

- Run the following command

        docker run -p 8080 google/golang-hello
