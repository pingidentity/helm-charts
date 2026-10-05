#!/usr/bin/env sh
# Copyright © 2026 Ping Identity Corporation

set -xe
echo "hello from before script"

pwd
env | sort
echo "${USER}"
type jq
type python
python --version
type aws
aws --version

#Uncomment these lines and update docker-builds-runner image if azure_tools.lib.sh is used in the pipeline. See $PIPELINE_BUILD_REGISTRY_VENDOR.
#type az
#az --version

type docker
# 27-dind starts slower than 18.09 and cold nodes must pull the service
# image first; wait for the daemon instead of failing the first check
docker_info_tries=0
until docker info > /dev/null 2>&1; do
    docker_info_tries=$((docker_info_tries + 1))
    if [ "${docker_info_tries}" -ge 30 ]; then
        echo "Docker daemon not reachable after 60s"
        break
    fi
    sleep 2
done
docker info
type docker-compose
docker-compose version
type envsubst
envsubst --version

#Uncomment these lines and update docker-builds-runner image if google_tools.lib.sh is used in the pipeline. See $PIPELINE_BUILD_REGISTRY_VENDOR.
#type gcloud
#gcloud --version

type git
git --version
type notary
notary version

type kubectl
kubectl version

type helm
helm version
