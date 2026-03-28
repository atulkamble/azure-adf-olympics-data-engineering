#!/bin/bash

# =====================================================
# Upload Sample Data to Azure Data Lake
# =====================================================

set -e

RESOURCE_GROUP="olympics-rg"
STORAGE_ACCOUNT="olympicsdatalake123"
CONTAINER="raw"
LOCAL_DATA_PATH="../data/raw"

echo "Uploading sample data to Azure Data Lake..."

# Get storage account key
STORAGE_KEY=$(az storage account keys list \
  --resource-group $RESOURCE_GROUP \
  --account-name $STORAGE_ACCOUNT \
  --query '[0].value' -o tsv)

# Upload each CSV file
for file in Athletes.csv Coaches.csv Medals.csv Teams.csv EntriesGender.csv; do
  echo "Uploading $file..."
  az storage blob upload \
    --account-name $STORAGE_ACCOUNT \
    --account-key $STORAGE_KEY \
    --container-name $CONTAINER \
    --name "olympics/$file" \
    --file "$LOCAL_DATA_PATH/$file" \
    --overwrite
  echo "✓ Uploaded $file"
done

echo "✓ All sample data uploaded successfully!"
