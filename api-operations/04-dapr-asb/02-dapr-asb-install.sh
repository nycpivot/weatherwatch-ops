#!/bin/bash

resource_group=weatherwatch
namespace=weatherwatch

connectionString=$(az servicebus namespace authorization-rule keys list --resource-group $resource_group --namespace-name $namespace --name RootManageSharedAccessKey --query primaryConnectionString -o tsv)

#kubectl create secret generic weatherwatch-asb-secret --from-literal=ServiceBus=$connectionString

cat <<EOF | kubectl apply -f -
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: extreme-temps
spec:
  type: pubsub.azure.servicebus.topics
  version: v1
  metadata:
  - name: connectionString
    value: "${connectionString}"
EOF

