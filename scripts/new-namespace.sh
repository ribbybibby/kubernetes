#!/bin/bash

# This script makes the changes required to bootstrap a new namespace

set -e

CLUSTER=${1:?"Usage $0 <cluster> <namespace>"}
NAMESPACE=${2:?"Usage $0 <cluster> <namespace>"}

test -d "${CLUSTER}" || (echo "directory '${CLUSTER}' doesn't exist"; exit 1)

# ${CLUSTER}/argocd/applications/${NAMESPACE}.yaml
jsonnet \
    -V namespace="${NAMESPACE}" \
    -V path="${CLUSTER}/${NAMESPACE}" \
    scripts/templates/argocd_application.jsonnet \
    | yq r - > "${CLUSTER}/argocd/applications/${NAMESPACE}.yaml"

grep -q "applications/${NAMESPACE}.yaml" "${CLUSTER}/argocd/kustomization.yaml" || \
    yq w -i "${CLUSTER}/argocd/kustomization.yaml" "resources[+]" "applications/${NAMESPACE}.yaml"

prettier --write "${CLUSTER}/argocd/kustomization.yaml" > /dev/null

# ${CLUSTER}/default/${NAMESPACE}.yaml
jsonnet \
    -V namespace="${NAMESPACE}" \
    scripts/templates/namespace.jsonnet \
    | yq r - > "${CLUSTER}/default/${NAMESPACE}.yaml"

grep -q "${NAMESPACE}.yaml" "${CLUSTER}/default/kustomization.yaml" || \
    yq w -i "${CLUSTER}/default/kustomization.yaml" "resources[+]" "${NAMESPACE}.yaml"

prettier --write "${CLUSTER}/default/kustomization.yaml" > /dev/null

# ${CLUSTER}/${NAMESPACE}/kustomization.yaml
mkdir -p "${CLUSTER}/${NAMESPACE}"
yq n 'resources' [] > "${CLUSTER}/${NAMESPACE}/kustomization.yaml"
