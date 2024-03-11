#!/bin/bash

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
AWS_REGION_CODE=$(aws configure get region)

weatherwatch_web_cluster=weatherwatch-web
cluster_role_arn=arn:aws:iam::$AWS_ACCOUNT_ID:role/eks-cluster-role
nodegroup_role_arn=arn:aws:iam::$AWS_ACCOUNT_ID:role/eks-nodegroup-role
cluster_arn=arn:aws:eks:${AWS_REGION_CODE}:$AWS_ACCOUNT_ID:cluster

vpc_id=$(cat ~/weatherwatch-operations/web-operations/vpc-params.json | jq '.[] | select(.ParameterKey == "VpcId")' | jq -r .ParameterValue)
subnet1=$(cat ~/weatherwatch-operations/web-operations/vpc-params.json | jq '.[] | select(.ParameterKey == "SubnetId1")' | jq -r .ParameterValue)
subnet2=$(cat ~/weatherwatch-operations/web-operations/vpc-params.json | jq '.[] | select(.ParameterKey == "SubnetId2")' | jq -r .ParameterValue)
subnet3=$(cat ~/weatherwatch-operations/web-operations/vpc-params.json | jq '.[] | select(.ParameterKey == "SubnetId3")' | jq -r .ParameterValue)
subnet4=$(cat ~/weatherwatch-operations/web-operations/vpc-params.json | jq '.[] | select(.ParameterKey == "SubnetId4")' | jq -r .ParameterValue)

aws eks create-cluster \
	--name $weatherwatch_web_cluster \
	--region $AWS_REGION_CODE \
	--kubernetes-version 1.28 \
	--role-arn $cluster_role_arn \
	--resources-vpc-config subnetIds=$subnet1,$subnet2 \

aws eks wait cluster-active --name $weatherwatch_web_cluster

aws eks create-nodegroup \
	--cluster-name $weatherwatch_web_cluster \
	--nodegroup-name "${weatherwatch_web_cluster}-node-group" \
	--disk-size 50 \
	--scaling-config minSize=1,maxSize=3,desiredSize=1 \
	--subnets "$subnet1" "$subnet2" \
	--instance-types t3.medium \
	--node-role $nodegroup_role_arn \
	--kubernetes-version 1.28

aws eks update-kubeconfig --name ${weatherwatch_web_cluster} --region ${AWS_REGION_CODE}

kubectl config rename-context ${cluster_arn}/${weatherwatch_web_cluster} ${weatherwatch_web_cluster}
