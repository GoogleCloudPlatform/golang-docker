#!/bin/bash

set -euo pipefail

# Set GOPATH to a temporary directory for downloading external dependencies.
export GOPATH="$(mktemp -d /tmp/gopath.XXX)"

# Set new_gopath to this directory.
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
    # Copy external dependencies to new_gopath.
    if [[ -d "${d}" ]]; then
        mkdir -p "${new_gopath}/src/${pkg}"
        set +e; cp -v "${GOPATH}/src/${pkg}"/*.go "${new_gopath}/src/${pkg}/"
    fi
done

echo "Copying license files..."
cd "${GOPATH}"
# Assume all license files are named "LICENSE" since we import Google packages
# only. If this is not the case in the future, we should change this logic.
for license in $(find . -name LICENSE)
do
    set +e; cp -v "${license}" "${new_gopath}/${license}"
done

rm -rf "${GOPATH}"
cd "${new_gopath}"
# Remove test files.
find src/ -name \*_test.go -delete
