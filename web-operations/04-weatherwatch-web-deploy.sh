#!/bin/bash

image_registry_url=$(az keyvault secret show --name image-registry-url --subscription thejameshome --vault-name cloud-operations-vault --query value --output tsv)
image_registry_username=$(az keyvault secret show --name image-registry-username --subscription thejameshome --vault-name cloud-operations-vault --query value --output tsv)
image_registry_password=$(az keyvault secret show --name image-registry-password --subscription thejameshome --vault-name cloud-operations-vault --query value --output tsv)

weather_api_url=www.google.com

cd ~

#docker login $image_registry_url -u $image_registry_username -p $image_registry_password

kubectl config use-context weatherwatch-web

kubectl delete secret weatherwatch-web-secret --ignore-not-found

kubectl create secret docker-registry weatherwatch-web-secret \
	--docker-server=$image_registry_url \
	--docker-username=$image_registry_username \
	--docker-password=$image_registry_password

rm weatherwatch-web-deployment.yaml
cat <<EOF | tee weatherwatch-web-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: weatherwatch-web-deployment
  labels:
    app: weatherwatch-web
spec:
  replicas: 1
  selector:
    matchLabels:
      app: weatherwatch-web
  template:
    metadata:
      labels:
        app: weatherwatch-web
    spec:
      containers:
      - name: weatherwatch-web
        image: weatherwatch.azurecr.io/weatherwatch-web
        env:
        - name: WEATHER_API
          value: $weather_api_url 
        ports:
        - containerPort: 80
      imagePullSecrets:
      - name: weatherwatch-web-secret
---
apiVersion: v1
kind: Service
metadata:
  name: weatherwatch-web
spec:
  selector:
    app: weatherwatch-web
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: LoadBalancer
EOF

kubectl delete -f weatherwatch-web-deployment.yaml --ignore-not-found

kubectl apply -f weatherwatch-web-deployment.yaml

kubectl get pods
kubectl get services

