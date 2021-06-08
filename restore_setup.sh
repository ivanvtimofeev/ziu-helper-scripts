#!/bin/bash


my_file="$(readlink -e "$0")"
my_dir="$(dirname $my_file)"

export OPERATOR_REPO=${OPERATOR_REPO:-"${my_dir}/../.."}

export CONTRAIL_CONTAINER_TAG="nightly"
export CONTAINER_REGISTRY="tf-nexus.progmaticlab.com:5102"
export CONTRAIL_DEPLOYER_CONTAINER_TAG="nightly"
export DEPLOYER_CONTAINER_REGISTRY="tf-nexus.progmaticlab.com:5102"


$OPERATOR_REPO/contrib/render_manifests.sh
kubectl apply -k $OPERATOR_REPO/deploy/kustomize/contrail/templates/
kubectl apply -k $OPERATOR_REPO/deploy/kustomize/operator/templates/
