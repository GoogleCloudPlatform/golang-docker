golang-docker
=============

[![Build Status](https://travis-ci.org/GoogleCloudPlatform/golang-docker.svg?branch=master)](https://travis-ci.org/GoogleCloudPlatform/golang-docker)

This repository contains the sources for the following [docker](https://docker.io) base images:
- [`gcr.io/google_appengine/golang`](/base)

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
