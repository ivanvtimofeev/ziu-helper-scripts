#!/bin/bash -x

DOCKER_REGISTRY=${DOCKER_REGISTRY:-"localhost:5000"}

for i in $(docker image list | grep tungsten | awk '{print $1";"$3}'); do
    # echo "next ${i}"

    name=$(echo ${i} | tr ";" " " | awk '{print $1}'| tr "/" " " | awk '{print $2}')
    code=$(echo ${i} | tr ";" " " | awk '{print $2}')

    docker tag $code ${DOCKER_REGISTRY}/${name}:latest
    docker push ${DOCKER_REGISTRY}/${name}:latest

done