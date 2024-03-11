#!/bin/bash

kubectl config use-context weatherwatch-api

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
kind: Component
metadata:
  name: extreme-temps
spec:
  type: pubsub.rabbitmq
  version: v1
  metadata:
  - name: connectionString
    value: "amqp://localhost:5672"
  - name: protocol
    value: amqp
  - name: hostname
    value: localhost
  - name: username
    value: guest
  - name: password
    value: guest
  - name: durable
    value: "false"
  - name: deletedWhenUnused
    value: "false"
  - name: autoAck
    value: "false"
  - name: reconnectWait
    value: "0"
  - name: concurrency
    value: parallel
scopes:
- coldestday
- hottestday
EOF

