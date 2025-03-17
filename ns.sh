#!/bin/bash

# Check if namespace is provided as a command-line argument
if [ -z "$1" ]; then
  echo "Error: Namespace is required!"
  echo "Usage: ./ns.sh <namespace>"
  exit 1
fi

# Get the namespace from the command-line argument
namespace="$1"

# Set the current context to the specified namespace
kubectl config set-context --current --namespace="$namespace"

echo "Namespace set to '$namespace' for the current context."
