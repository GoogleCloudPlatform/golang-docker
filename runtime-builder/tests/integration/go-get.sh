#!/bin/bash

set -e

cd $(dirname $0)
new_gopath=$(pwd -P)

echo "Cleaning up dependencies..."
find src/ -maxdepth 1 -mindepth 1 ! -name 'app'  -type d | xargs rm -rf
cd src/app
deps=$(go list -f '{{ join .Deps "\n" }}' -tags appenginevm)

echo "Fetching dependencies..."
go get -u -v -d -tags appenginevm

echo "Copying dependencies..."
if [[ "$(uname -s)" == "Darwin" ]]; then
    for pkg in ${deps}
    do
        d="${GOPATH}/src/${pkg}"
        # copy non-std dependencies to the new gopath
        if [[ -d "${d}" ]]; then
            ditto -v "${d}" "${new_gopath}/src/${pkg}"
        fi
    done
elif [[ "$(uname -s)" == "Linux" ]]; then
    cd "${GOPATH}"/src
    for pkg in ${deps}
    do
        # copy non-std dependencies to the new gopath
        if [[ -d "${pkg}" ]]; then
            cp -Rv --parents "${pkg}" "${new_gopath}"/src
        fi
    done
fi

cd "${new_gopath}"
find . -name .git -type d | xargs rm -rf
