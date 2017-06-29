#!/bin/bash

cd $(dirname $0)
export GOPATH=$(pwd -P)
go get -d -tags appenginevm app 
find . -name .git -type d | xargs rm -rf {} \;