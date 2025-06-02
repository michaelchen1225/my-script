#!/bin/bash

# Define plugin list
PLUGINS=(
  iexec
  image
  krew
  neat
  ns
  pod-lens
  sick-pods
  status
  view-allocations
)

# check if krew is installed

if ! kubectl krew &> /dev/null; then
    echo "krew is not installed. ref: https://krew.sigs.k8s.io/docs/user-guide/setup/install/"
    exit 1
fi

kubectl krew update

# install plugins
for plugin in "${PLUGINS[@]}"; do
  kubectl krew install $plugin
done
