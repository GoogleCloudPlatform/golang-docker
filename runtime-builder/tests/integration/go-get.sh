#!/bin/bash

set -euo pipefail

export GOPATH="/tmp/$(mktemp -d gopath.XXX)"
cd $(dirname $0)
new_gopath=$(pwd -P)

echo "Cleaning up dependencies..."
find src/ -maxdepth 1 -mindepth 1 ! -name 'app'  -type d | xargs rm -rf

echo "Fetching dependencies..."
cd src/app
go get -v -d -tags appenginevm
deps=$(go list -f '{{ join .Deps "\n" }}' -tags appenginevm)

echo "Copying dependencies..."
for pkg in ${deps}
do
    d="${GOPATH}/src/${pkg}"
    # copy non-std dependencies to the new gopath
    if [[ -d "${d}" ]]; then
        mkdir -p "${new_gopath}/src/${pkg}"
        set +e; cp -v "${GOPATH}/src/${pkg}"/* "${new_gopath}/src/${pkg}/"
    fi
done

rm -rf "${GOPATH}"
cd "${new_gopath}"
find . -name .git -type d | xargs rm -rf
