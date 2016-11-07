set -e

cd base/
sed -i "s,^\(FROM.*\),\\1:$BASE_TAG," Dockerfile

RUNTIME_NAME="golang"

CANDIDATE_NAME=`date +%Y-%m-%d_%H_%M`
echo "CANDIDATE_NAME:${CANDIDATE_NAME}"
IMAGE_NAME="${DOCKER_NAMESPACE}/${RUNTIME_NAME}:${CANDIDATE_NAME}"

envsubst < base/cloudbuild.yaml.in > base/cloudbuild.yaml

gcloud beta container builds submit . --config=base/cloudbuild.yaml . -q

if [ "${UPLOAD_TO_STAGING}" = "true" ]; then
  STAGING="${DOCKER_NAMESPACE}/${RUNTIME_NAME}:staging"
  docker tag -f "${IMAGE_NAME}" "${STAGING}"
  gcloud docker push "${STAGING}"
fi
