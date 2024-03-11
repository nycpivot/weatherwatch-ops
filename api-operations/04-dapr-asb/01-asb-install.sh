#!/bin/bash

resource_group=weatherwatch
namespace=weatherwatch

az servicebus namespace create --name $namespace --resource-group $resource_group --location eastus

