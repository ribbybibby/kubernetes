#!/bin/bash

# This script makes the changes required to bootstrap a new namespace

set -e

NAMESPACE=${1:?"Usage $0 <namespace>"}
CLUSTER=$(basename ${PWD})

# Create the namespace resource
#   CREATE: default/${NAMESPACE}.yaml
#   UPDATE: default/kustomization.yaml
docker run --rm -v $(dirname ${PWD})/scripts/templates:/templates bitnami/jsonnet \
    -V namespace="${NAMESPACE}" \
    /templates/namespace.jsonnet \
    | docker run -i --rm mikefarah/yq yq r - > "default/${NAMESPACE}.yaml"
docker run --rm -v ${PWD}:/workdir mikefarah/yq yq w -i "default/kustomization.yaml" "resources[+]" "${NAMESPACE}.yaml"
docker run --rm -v ${PWD}:/work tmknom/prettier --write "default/kustomization.yaml" > /dev/null

# Create the namespace directory with an empty kustomization.yaml
#   CREATE: ${NAMESPACE}/kustomization.yaml
mkdir -p "${NAMESPACE}"
docker run --rm mikefarah/yq yq n 'resources' [] > "${NAMESPACE}/kustomization.yaml"

# Create a new argocd application for the namespace
#   CREATE: argocd/applications/${NAMESPACE}.yaml
#   UPDATE: argocd/kustomization.yaml
docker run --rm -v $(dirname ${PWD})/scripts/templates:/templates bitnami/jsonnet \
    -V namespace="${NAMESPACE}" \
    -V path="${CLUSTER}/${NAMESPACE}" \
    /templates/argocd_application.jsonnet \
    | \
    docker run -i --rm mikefarah/yq yq r - > "argocd/applications/${NAMESPACE}.yaml"
docker run --rm -v ${PWD}:/workdir mikefarah/yq yq w -i "argocd/kustomization.yaml" "resources[+]" "applications/${NAMESPACE}.yaml"
docker run --rm -v ${PWD}:/work tmknom/prettier --write "argocd/kustomization.yaml" > /dev/null
