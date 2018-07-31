
#!/bin/bash
TOKEN=$(az account get-access-token --query "accessToken" -o tsv)
echo $TOKEN


