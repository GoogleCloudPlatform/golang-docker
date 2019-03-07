#!/bin/bash
# Common script for all kokoro jobs to set up auth and gcloud
set -ex

#set a variable that SHOULD be set
export KOKORO_GITHUB_DIR=$KOKORO_ROOT/src/github

if [ -z "${BAZEL_VERSION:+set}" ]
then
  BAZEL_VERSION=0.19.2
fi

# Install the given bazel version on linux
function update_bazel_linux {
  BAZEL_FILE="bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh"
  rm -rf ~/bazel
  mkdir ~/bazel

  pushd ~/bazel
  cp $KOKORO_GFILE_DIR/$BAZEL_FILE .
  chmod +x $BAZEL_FILE
  "./$BAZEL_FILE" --user
  rm $BAZEL_FILE
  popd

  PATH="/home/kbuilder/bin:$PATH"
}

# Read the bazel version set from Job Config.
update_bazel_linux
# Running Bazel version to command.
bazel version

# default Cloud SDK version
if [ -z "${GCLOUD_FILE:+set}" ]; then
  GCLOUD_FILE=google-cloud-sdk-232.0.0-linux-x86_64.tar.gz
fi

# $KOKORO_ROOT is hardcoded to /tmpfs by kokoro
cp $KOKORO_GFILE_DIR/$GCLOUD_FILE .

# Hide the output here, it's long.
tar -xzf $GCLOUD_FILE
CUR_DIR=$(pwd)
export PATH=$CUR_DIR/google-cloud-sdk/bin:$PATH

export CLOUDSDK_PROJECT=gcp-runtimes
if [ -n "${DOCKER_NAMESPACE:+set}" ];
then
  export CLOUDSDK_PROJECT=$(echo $DOCKER_NAMESPACE | cut -d'/' -f2)
fi

#export GOOGLE_APPLICATION_CREDENTIALS="$KOKORO_ROOT/src/keystore/72508_kokoro_gcloud_access"
#gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
#gcloud config set project $CLOUDSDK_PROJECT
#gcloud components install beta -q
#gcloud components install alpha -q
#gcloud auth configure-docker -q

# Maybe grab and configure the GCS bazel cacher
if [ -e "$KOKORO_GFILE_DIR"/bazel-cache-gcs ]; then
  echo "Starting the local bazel cache!!"
  sudo cp "$KOKORO_GFILE_DIR"/bazel-cache-gcs /usr/local/bin/
  sudo chmod +x /usr/local/bin/bazel-cache-gcs
  bazel-cache-gcs \
    --bucket=gcp-bazel-cache \
    --verbosity=info &> /tmp/bazel-cache-gcs.log &
  cat << EOF >> "$HOME"/.bazelrc
startup --host_jvm_args=-Dbazel.DigestFunction=SHA1
build --remote_rest_cache=http://localhost:8080/
build --action_env=GOOGLE_APPLICATION_CREDENTIALS
EOF
fi
