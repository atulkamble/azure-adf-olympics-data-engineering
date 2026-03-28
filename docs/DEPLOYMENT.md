# Deployment Guide

## Prerequisites

1. **Azure Subscription** with sufficient permissions
2. **Azure CLI** installed ([Install Guide](https://docs.microsoft.com/cli/azure/install-azure-cli))
3. **Git** for version control
4. **Python 3.8+** for local development

## Step-by-Step Deployment

### 1. Clone Repository

```bash
git clone https://github.com/your-repo/azure-adf-olympics-data-engineering.git
cd azure-adf-olympics-data-engineering
```

### 2. Configure Settings

Edit `config/config.json` with your values:

```json
{
  "azure": {
    "subscription_id": "YOUR_SUBSCRIPTION_ID",
    "resource_group": "olympics-rg",
    "location": "centralindia"
  },
  "storage": {
    "account_name": "olympicsdatalake123"
  }
}
```

### 3. Run Infrastructure Setup

```bash
cd scripts
chmod +x setup.sh
./setup.sh
```

This creates:
- Resource Group
- Storage Account (ADLS Gen2) with containers
- Azure Data Factory
- Azure Databricks Workspace
- Azure Synapse Workspace

### 4. Upload Sample Data

```bash
chmod +x upload_sample_data.sh
./upload_sample_data.sh
```

### 5. Configure Databricks

#### 5.1 Create Cluster

1. Go to Databricks workspace
2. Create new cluster:
   - **Name**: `olympics-cluster`
   - **Runtime**: `13.3 LTS (Scala 2.12, Spark 3.4.1)`
   - **Node type**: `Standard_DS3_v2`
   - **Workers**: 2-8 (autoscaling)

#### 5.2 Mount ADLS to Databricks

```python
# Run in Databricks notebook
configs = {
  "fs.azure.account.auth.type": "OAuth",
  "fs.azure.account.oauth.provider.type": "org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider",
  "fs.azure.account.oauth2.client.id": "<application-id>",
  "fs.azure.account.oauth2.client.secret": "<service-credential>",
  "fs.azure.account.oauth2.client.endpoint": "https://login.microsoftonline.com/<directory-id>/oauth2/token"
}

dbutils.fs.mount(
  source = "abfss://raw@olympicsdatalake123.dfs.core.windows.net/",
  mount_point = "/mnt/raw",
  extra_configs = configs
)

# Repeat for processed and curated containers
```

#### 5.3 Upload Notebooks

1. Import notebooks from `databricks/notebooks/`
2. Place in `/Workspace/Olympics/` folder

### 6. Configure Azure Data Factory

#### 6.1 Create Linked Services

**HTTP Linked Service (Source)**
```json
{
  "name": "LS_HTTP_GitHub",
  "properties": {
    "type": "HttpServer",
    "typeProperties": {
      "url": "https://raw.githubusercontent.com/your-repo/main/data/raw/",
      "authenticationType": "Anonymous"
    }
  }
}
```

**ADLS Gen2 Linked Service**
```json
{
  "name": "LS_ADLS_Olympics",
  "properties": {
    "type": "AzureBlobFS",
    "typeProperties": {
      "url": "https://olympicsdatalake123.dfs.core.windows.net/"
    }
  }
}
```

**Databricks Linked Service**
- Use access token or Azure AD authentication
- Point to your Databricks workspace

**Synapse Linked Service**
- Use SQL authentication or Managed Identity

#### 6.2 Import Pipelines

Import pipeline JSONs from `adf/pipelines/`:
1. Go to ADF Studio → Author
2. Import from template
3. Select pipeline JSON files
4. Update linked service references

### 7. Configure Synapse Analytics

#### 7.1 Create SQL Pool

```bash
az synapse sql pool create \
  --name olympicspool \
  --workspace-name olympics-synapse \
  --resource-group olympics-rg \
  --performance-level DW100c
```

#### 7.2 Create Tables

Run `sql/create_tables.sql` in Synapse Studio

### 8. Run the Pipeline

1. Go to ADF Studio
2. Trigger `Olympics_Master_Pipeline`
3. Monitor execution

## Validation

### Check Data in ADLS
```bash
az storage blob list \
  --account-name olympicsdatalake123 \
  --container-name processed \
  --output table
```

### Query Data in Synapse
```sql
SELECT COUNT(*) FROM dbo.Athletes;
SELECT TOP 10 * FROM dbo.Medals ORDER BY Total DESC;
```

### View Databricks Job Runs
- Check cluster metrics
- Review notebook execution logs

## Troubleshooting

### Common Issues

**1. Storage Access Denied**
- Verify RBAC permissions
- Check firewall settings
- Ensure managed identity is configured

**2. Databricks Mount Fails**
- Verify service principal credentials
- Check storage account name
- Ensure containers exist

**3. ADF Pipeline Fails**
- Check linked service connectivity
- Verify dataset paths
- Review activity error details

**4. Synapse Connection Issues**
- Verify firewall rules
- Check SQL admin credentials
- Ensure SQL pool is running

## Production Considerations

### Security
- Use Azure Key Vault for secrets
- Enable managed identities
- Configure private endpoints
- Implement RBAC properly

### Performance
- Optimize partition strategy
- Use Delta Lake for curated layer
- Configure Databricks cluster autoscaling
- Monitor and tune Synapse queries

### Cost Management
- Pause Synapse pool when not in use
- Use auto-termination for Databricks
- Implement lifecycle policies for storage
- Monitor with Azure Cost Management

### Monitoring
- Set up alerts for pipeline failures
- Configure log analytics
- Enable diagnostic settings
- Create monitoring dashboards

## Next Steps

1. **Power BI**: Connect to Synapse and create dashboards
2. **Automation**: Set up scheduled triggers in ADF
3. **CI/CD**: Implement Azure DevOps pipelines
4. **Data Quality**: Add validation frameworks
5. **Documentation**: Maintain data catalog
