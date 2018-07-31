#!/bin/bash
#Deploy network template with peering
az group deployment create --name NetworkPeeringDeployment --resource-group test-network-rg \
 --template-file ../templates/peered-network.json --parameters @../templates/peered-network.parameters.json 
