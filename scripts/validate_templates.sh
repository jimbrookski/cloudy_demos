#To use this script, there must be environment variables (or VSTS Build variables) named 
#RG_<resourcegroup-suffix>, e.g. RG_NETWORK. The Azure CLI must also be logged in.
#!/bin/bash
declare -a RGS

while IFS='=' read -r name value ; do
  if [[ $name == *'RG_'* ]]; then
    RGS+=( "$value" )   
  fi
done < <(env)

# Create validation group
RGVALIDATE="validate-template-rg"
RG_EXISTS=$(az group show --name $RGVALIDATE)
if [ "$RG_EXISTS" = "" ]
then
  echo "Resource group $RGVALIDATE does not exist. Creating"
  az group create --name $RGVALIDATE --location "$REGION"
  sleep 10
fi

for RG in ${RGS[@]}; do
  echo "------------------------------------------------------------------------------------"
  echo "Validating $RG"
  TEMPLATE_VALIDATION=$(az group deployment validate --resource-group $RGVALIDATE \
    --template-file ../templates/$RG.json --parameters @../templates/$RG.parameters.json)

  # Parse the response
  python ./parse_template_validation.py "$TEMPLATE_VALIDATION" "$RG"
done

# Cleanup resource group
echo "Deleting resource group $RGVALIDATE"
az group delete --name $RGVALIDATE -y