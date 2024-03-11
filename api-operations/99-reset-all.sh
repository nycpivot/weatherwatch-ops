#!/bin/bash

resource_group=weatherwatch
weatherwatch_api_cluster=weatherwatch-api

az aks delete --name ${weatherwatch_api_cluster} --resource-group ${resource_group}
