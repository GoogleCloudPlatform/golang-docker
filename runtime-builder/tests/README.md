# Go runtime builder tests

This directory defines tests for the Go runtime builder image.

## Structrue Test
The structure test runs after the image is built. It checks the environment setup and the file existence. Failing the structure test will also fail the whole submission.
See the [structure tests README](https://github.com/GoogleCloudPlatform/runtimes-common/blob/master/structure_tests/README.md)
for information on how to write tests.

## Integration Test
The \/app directory contains an app to perform an end-to-end test on the runtime builder.
It uses the same [integration test framework](https://github.com/GoogleCloudPlatform/runtimes-common/tree/master/integration_tests) designed for the current Go GCP image.

To run the test:
* Build and submit the go1-builder image.
* Config the local config go-\<version>.yaml file to point to the image submitted.
* Run test.sh \<project_id>

### Caveat
Currently there is an issue with the authentication of the test framework.
Affected tests are skipped until the fix made.