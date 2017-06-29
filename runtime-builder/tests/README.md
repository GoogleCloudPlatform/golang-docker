# Go runtime builder tests

This directory defines tests for the Go runtime builder image.

## Structure Test
The structure test is invoked in the cloud build steps after the builder image is built. It checks the environment setup and the existence of specific files in the image. Failing the structure test will also fail the whole submission.
See the structure tests [README](https://github.com/GoogleCloudPlatform/runtimes-common/blob/master/structure_tests/README.md)
for information on how to write tests.

## Integration Test
The \/integration directory contains a test web application for performing an end to end test.
Refer to integration test framework [README](https://github.com/GoogleCloudPlatform/runtimes-common/tree/master/integration_tests) for the design and requirements. The directory serves as a GOPATH. It also includes all the dependencies for it to be used by the test container. A go-test.yaml is provided as the cloudbuild.yaml for deploying the app and it points to the staging go1-builder image. Every newly built image will have the "staging" tag.

To perform the test:
* Manually run a container build of the go1-builder image. Skip this step if you already have an existing image in GCR that you want to test.
* Set `gcloud config set app/use_runtime_builders true`
* Set `gcloud config set app/runtime_builders_root` to the integration/ directory.
* Run test.sh \<project_id>. This will use the configured go-test.yaml to build and deploy the test app. It will also invoke the test driver to perform the test suite to verify that it is working.

### Caveat
There is an issue with the authentication of the test framework.
The test robot of the cloud container build system doesn't have the correct authentication to read the monitoring metrics or log entries.
Affected tests are skipped until the fix made.