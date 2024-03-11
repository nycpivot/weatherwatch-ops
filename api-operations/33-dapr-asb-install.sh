#!/bin/bash

cat <<EOF | kubectl apply -f -
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: weatherwatch-pubsub
spec:
  type: pubsub.azure.servicebus
  metadata:
  - name: connectionString
    secretKeyRef:
      name: weatherwatch-asb-secret
      key: ServiceBus
auth:
  secretStore: kubernetes
EOF

