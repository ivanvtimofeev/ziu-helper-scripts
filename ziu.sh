
#!/bin/bash

set -e
set -x

my_file="$(readlink -e "$0")"
my_dir="$(dirname $my_file)"

function err() {
    local msg=$1
    echo "ERROR: ${msg}"
    exit 1
}

# ZIU from R2011 to master

# TODO Apply local builded operator. Refactor after all done with ZIU
export CONTRAIL_CONTAINER_TAG=${CONTRAIL_CONTAINER_TAG:-"latest"}
export CONTAINER_REGISTRY=${CONTAINER_REGISTRY:-"localhost:5000"}
export CONTRAIL_DEPLOYER_CONTAINER_TAG=${CONTRAIL_DEPLOYER_CONTAINER_TAG:-"latest"}
export DEPLOYER_CONTAINER_REGISTRY=${DEPLOYER_CONTAINER_REGISTRY:-"localhost:5000"}

export WORKSPACE=${WORKSPACE:-HOME}
export OPERATOR_REPO=${OPERATOR_REPO:-"${my_dir}/../.."}
TF_NAMESPACE=${TF_NAMESPACE:-"tf"}

# patch oparator with new registry/tag
deployments_count=$(kubectl get deployment -n ${TF_NAMESPACE}  --no-headers=true | wc -l)
if [[ $deployments_count == 1 ]]; then
    echo "We have found one deployment"
elif [[ $deployments_count == 0 ]];then
    err "We have not found any deployment"
else
    err "We have more than one deployment in tf namespace - something is going wrong"
fi

deployment=$(kubectl get deployment -o name -n ${TF_NAMESPACE})
#kubectl set image ${deployment} tf-operator=$DEPLOYER_CONTAINER_REGISTRY/tf-operator:${CONTRAIL_DEPLOYER_CONTAINER_TAG}
kubectl delete ${deployment}

# update CRDS
kubectl apply -f $OPERATOR_REPO/deploy/crds/

# setup new manager resource
export CONFIGDB_MIN_HEAP_SIZE=${CONFIGDB_MIN_HEAP_SIZE:-"1g"}
export CONFIGDB_MAX_HEAP_SIZE=${CONFIGDB_MAX_HEAP_SIZE:-"4g"}
export ANALYTICSDB_ENABLE=${ANALYTICSDB_ENABLE:-"false"}
$OPERATOR_REPO/contrib/render_manifests.sh
kubectl apply -k $OPERATOR_REPO/deploy/kustomize/contrail/templates/
kubectl apply -k $OPERATOR_REPO/deploy/kustomize/operator/templates/