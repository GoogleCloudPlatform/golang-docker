#!/bin/bash

set -euo pipefail

# Set GOPATH to a temporary directory for downloading external dependencies.
export GOPATH="$(mktemp -d /tmp/gopath.XXX)"

echo "Cleaning up dependencies..."
cd $(dirname $0)
rm -rf src/app/vendor

echo "Fetching dependencies..."
cd src/app
vendor_dir="$(pwd -P)/vendor"
mkdir "${vendor_dir}"
set +e; go get -d -tags appenginevm
deps=$(go list -f '{{ join .Deps "\n" }}' -tags appenginevm)

echo "Copying dependencies..."
for pkg in ${deps}
do
    d="${GOPATH}/src/${pkg}"
    # Copy external dependencies to vendor_dir.
    if [[ -d "${d}" ]]; then
        mkdir -p "${vendor_dir}/${pkg}"
        set +e; cp -v "${GOPATH}/src/${pkg}"/*.go "${vendor_dir}/${pkg}/"
    fi
done

echo "Copying license files..."
cd "${GOPATH}/src"
# Assume all license files are named "LICENSE" since we import Google packages
# only. If this is not the case in the future, we should change this logic.
for license in $(find . -name LICENSE)
do
    set +e; cp -v "${license}" "${vendor_dir}/${license}"
done

rm -rf "${GOPATH}"
cd "${vendor_dir}"
# Remove test files.
find . -name \*_test.go -delete
