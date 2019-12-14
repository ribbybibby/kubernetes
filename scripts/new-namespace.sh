#!/bin/bash

# This script makes the changes required to bootstrap a new namespace

set -e

NAMESPACE=${1:?"Usage $0 <namespace>"}
CLUSTER=$(basename ${PWD})

# argocd/applications/${NAMESPACE}.yaml
jsonnet \
    -V namespace="${NAMESPACE}" \
    -V path="${CLUSTER}/${NAMESPACE}" \
    ../scripts/templates/argocd_application.jsonnet \
    | yq r - > "argocd/applications/${NAMESPACE}.yaml"

grep -q "applications/${NAMESPACE}.yaml" "argocd/kustomization.yaml" || \
    yq w -i "argocd/kustomization.yaml" "resources[+]" "applications/${NAMESPACE}.yaml"

prettier --write "argocd/kustomization.yaml" > /dev/null

# default/${NAMESPACE}.yaml
jsonnet \
    -V namespace="${NAMESPACE}" \
    ../scripts/templates/namespace.jsonnet \
    | yq r - > "default/${NAMESPACE}.yaml"

grep -q "${NAMESPACE}.yaml" "default/kustomization.yaml" || \
    yq w -i "default/kustomization.yaml" "resources[+]" "${NAMESPACE}.yaml"

prettier --write "default/kustomization.yaml" > /dev/null

# ${CLUSTER}/${NAMESPACE}/kustomization.yaml
mkdir -p "${NAMESPACE}"
yq n 'resources' [] > "${NAMESPACE}/kustomization.yaml"
