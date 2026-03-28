#!/bin/bash

# =====================================================
# Tokyo Olympics Data Engineering - Azure Setup Script
# =====================================================

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
RESOURCE_GROUP="olympics-rg"
LOCATION="centralindia"
STORAGE_ACCOUNT="olympicsdatalake123"
DATA_FACTORY="olympics-adf"
DATABRICKS_WORKSPACE="olympics-databricks"
SYNAPSE_WORKSPACE="olympics-synapse"

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Tokyo Olympics Azure Infrastructure Setup${NC}"
echo -e "${GREEN}=========================================${NC}\n"

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}Error: Azure CLI is not installed${NC}"
    echo "Please install from: https://docs.microsoft.com/cli/azure/install-azure-cli"
    exit 1
fi

# Login to Azure
echo -e "${YELLOW}Logging in to Azure...${NC}"
az login

# Set subscription (optional - uncomment and add your subscription ID)
# az account set --subscription "YOUR_SUBSCRIPTION_ID"

# Create Resource Group
echo -e "${YELLOW}Creating Resource Group: $RESOURCE_GROUP${NC}"
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

# Create Storage Account (ADLS Gen2)
echo -e "${YELLOW}Creating Storage Account: $STORAGE_ACCOUNT${NC}"
az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_LRS \
  --kind StorageV2 \
  --hierarchical-namespace true

# Get Storage Account Key
STORAGE_KEY=$(az storage account keys list \
  --resource-group $RESOURCE_GROUP \
  --account-name $STORAGE_ACCOUNT \
  --query '[0].value' -o tsv)

# Create Containers
echo -e "${YELLOW}Creating Storage Containers...${NC}"
for container in raw processed curated staging; do
  az storage container create \
    --name $container \
    --account-name $STORAGE_ACCOUNT \
    --account-key $STORAGE_KEY
  echo -e "${GREEN}✓ Created container: $container${NC}"
done

# Create Azure Data Factory
echo -e "${YELLOW}Creating Azure Data Factory: $DATA_FACTORY${NC}"
az datafactory create \
  --resource-group $RESOURCE_GROUP \
  --factory-name $DATA_FACTORY \
  --location $LOCATION

# Create Azure Databricks Workspace
echo -e "${YELLOW}Creating Azure Databricks Workspace: $DATABRICKS_WORKSPACE${NC}"
az databricks workspace create \
  --resource-group $RESOURCE_GROUP \
  --name $DATABRICKS_WORKSPACE \
  --location $LOCATION \
  --sku premium

# Create Synapse Workspace (requires unique storage for Synapse)
SYNAPSE_STORAGE="${SYNAPSE_WORKSPACE}storage"
echo -e "${YELLOW}Creating Synapse Analytics Workspace: $SYNAPSE_WORKSPACE${NC}"

# Create storage for Synapse
az storage account create \
  --name $SYNAPSE_STORAGE \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_LRS \
  --kind StorageV2 \
  --hierarchical-namespace true

# Create filesystem for Synapse
az storage container create \
  --name synapsefs \
  --account-name $SYNAPSE_STORAGE \
  --account-key $(az storage account keys list \
    --resource-group $RESOURCE_GROUP \
    --account-name $SYNAPSE_STORAGE \
    --query '[0].value' -o tsv)

# Create Synapse Workspace
az synapse workspace create \
  --name $SYNAPSE_WORKSPACE \
  --resource-group $RESOURCE_GROUP \
  --storage-account $SYNAPSE_STORAGE \
  --file-system synapsefs \
  --sql-admin-login-user sqladmin \
  --sql-admin-login-password "ComplexP@ssw0rd123!" \
  --location $LOCATION

echo -e "\n${GREEN}=========================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${GREEN}=========================================${NC}\n"

echo -e "${YELLOW}Resource Details:${NC}"
echo "Resource Group: $RESOURCE_GROUP"
echo "Storage Account: $STORAGE_ACCOUNT"
echo "Data Factory: $DATA_FACTORY"
echo "Databricks Workspace: $DATABRICKS_WORKSPACE"
echo "Synapse Workspace: $SYNAPSE_WORKSPACE"

echo -e "\n${YELLOW}Next Steps:${NC}"
echo "1. Upload notebooks to Databricks"
echo "2. Configure ADF pipelines"
echo "3. Create Synapse SQL pool"
echo "4. Run the master pipeline"

echo -e "\n${GREEN}✓ Infrastructure provisioning complete!${NC}"
