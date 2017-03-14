golang-docker
=============

[![Build Status](https://travis-ci.org/GoogleCloudPlatform/golang-docker.svg?branch=master)](https://travis-ci.org/GoogleCloudPlatform/golang-docker)

This repository contains the sources for the following [docker](https://docker.io) base images:
- [`gcr.io/google_appengine/golang`](/base)

## Usage On Container Engine

For Container Engine, you'll need to create a Dockerfile based on this image that copies your application code and installs dependencies. For example:

```
FROM gcr.io/google-appengine/golang

COPY . /go/src/app
RUN go-wrapper install
```

This image assumes your application listens on port 8080.
To run an application based on this image inside a Kubernetes pod, you can use a Pod configuration like this:

```yaml
kind: Pod
metadata:
  name: app
  namespace: default
spec:
  containers:
  - image: $IMAGE_NAME
    imagePullPolicy: IfNotPresent
    name: app
    ports:
    - containerPort: 8080
  restartPolicy: Always
```

## Developing and testing

```bash
# Pull image
git clone ssh://git@github.com/GoogleCloudPlatform/golang-docker.git
cd golang-docker

# hack hack hack

# Build
docker build -t golang ./base

# Test
curl https://raw.githubusercontent.com/GoogleCloudPlatform/runtimes-common/master/structure_tests/ext_run.sh > ext_run.sh
bash ext_run.sh -i golang -c test/test_config.yaml
```
