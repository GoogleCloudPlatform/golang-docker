# google/appengine-go

[`google/appengine-go`](https://index.docker.io/u/google/appengine-go) is a [docker](https://docker.io) base image for easily running App Engine [golang](http://golang.org) application.

It is based on [`google/golang`](https://index.docker.io/u/google/golang) base image.

## Usage

- Create a Dockerfile in your App Engine application directory with the following content:

        FROM google/appengine-go
        ADD . /app
        RUN /app/_ah/build.sh

- Use the Cloud SDK to build and run your application

        gcloud app run .

## Notes

The image assumes that your application:

- listens on port `8080`

When the Cloud SDK builds your Docker container image, it automatically injects the dependencies of your application into the build context, and builds them with your application binary.
