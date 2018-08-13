# Go runtime builder tests

This directory defines tests for the Go runtime builder image.

## Structure Test
The structure test is invoked in the cloud build steps after the builder image
is built. It checks the environment setup and the existence of specific files
in the image. Failing the structure test will also fail the whole submission.
See the structure tests
[README](https://github.com/GoogleCloudPlatform/runtimes-common/blob/master/structure_tests/README.md)
for information on how to write tests.

## Integration Test
The integration directory contains a test web application for performing an end to end test.
Refer to integration test framework
[README](https://github.com/GoogleCloudPlatform/runtimes-common/tree/master/integration_tests)
for the design and requirements.

The directory serves as a hermetic GOPATH. It includes all the dependencies for
it to be used by the test container. Use the go-get.sh script to update
dependencies if necessary.

The test.sh script executes the end-to-end test with the following steps:
* Generate a test.yaml file for use as the cloudbuild.yaml referenced in runtimes.yaml.
* Deploy the test app.
* Executes the integration test defined in go-test.yaml through Cloud Build.

To perform the test:
* Manually run a Cloud Build of the go1-builder image. Skip this step if
  you already have an existing image in GCR that you want to test.
* Set `gcloud config set app/runtime_builders_root` to the integration
  directory.
* Run test.sh.

Usage:
```
test.sh <project_id> [builder_image_url]
```
* `builder_image_url` is optional. Default value is
  'gcr.io/${project_id}/go1-builder:staging' because the 'staging' tag is
  applied during the build process.

### Caveat
There is an issue with the authentication of the test framework.  The test
robot of the Cloud Build system doesn't have the correct
authentication to read the monitoring metrics or log entries.
Affected tests are skipped until the issue is fixed.
