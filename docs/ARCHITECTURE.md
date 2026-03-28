# Tokyo Olympics Data Engineering - Architecture

## Overview

This project implements a complete **modern data platform on Azure** for analyzing Tokyo Olympics data using industry-standard patterns and best practices.

## Architecture Diagram

```
┌──────────────────┐
│  Data Sources    │
│  (GitHub/Local)  │
└────────┬─────────┘
         │
         ▼
┌──────────────────────────────────────┐
│   Azure Data Factory (ADF)           │
│   - Ingestion Pipelines              │
│   - Orchestration                    │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│   Azure Data Lake Gen2               │
│   ┌────────────────────────────┐     │
│   │  Raw Layer                 │     │
│   │  - Athletes.csv            │     │
│   │  - Medals.csv              │     │
│   │  - Teams.csv               │     │
│   └────────────────────────────┘     │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│   Azure Databricks                   │
│   - PySpark Transformations          │
│   - Data Quality Checks              │
│   - Business Logic                   │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│   Azure Data Lake Gen2               │
│   ┌────────────────────────────┐     │
│   │  Processed Layer           │     │
│   │  - Parquet files           │     │
│   └────────────────────────────┘     │
│   ┌────────────────────────────┐     │
│   │  Curated Layer             │     │
│   │  - Delta tables            │     │
│   └────────────────────────────┘     │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│   Azure Synapse Analytics            │
│   - SQL Pools                        │
│   - Analytics Queries                │
│   - Data Warehouse                   │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│   Power BI                           │
│   - Dashboards                       │
│   - Reports                          │
│   - Visualizations                   │
└──────────────────────────────────────┘
```

## Data Flow

### 1. **Ingestion Layer**
- **Tool**: Azure Data Factory
- **Source**: GitHub raw CSV files
- **Destination**: ADLS Gen2 (Raw container)
- **Pattern**: HTTP source → Copy Activity → Blob Storage

### 2. **Raw Layer** (Bronze)
- **Location**: `raw/olympics/`
- **Format**: CSV files (as-is from source)
- **Purpose**: Immutable source of truth

### 3. **Transformation Layer**
- **Tool**: Azure Databricks (PySpark)
- **Operations**:
  - Data cleansing
  - Schema standardization
  - Business transformations
  - Data quality checks
- **Notebooks**:
  - `transform_athletes.py`
  - `transform_medals.py`
  - `transform_entriesgender.py`

### 4. **Processed Layer** (Silver)
- **Location**: `processed/olympics/`
- **Format**: Parquet (columnar, compressed)
- **Purpose**: Clean, validated data ready for analytics

### 5. **Curated Layer** (Gold)
- **Location**: `curated/olympics/`
- **Format**: Delta Lake
- **Purpose**: Business-ready datasets with ACID properties

### 6. **Analytics Layer**
- **Tool**: Azure Synapse Analytics
- **Tables**: Dimensional model
- **SQL Scripts**: Pre-built analysis queries

### 7. **Visualization Layer**
- **Tool**: Power BI
- **Dashboards**:
  - Medal standings
  - Gender participation analysis
  - Country performance metrics

## Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Orchestration | Azure Data Factory | Pipeline management |
| Storage | Azure Data Lake Gen2 | Scalable data lake |
| Compute | Azure Databricks | Distributed processing |
| Analytics | Azure Synapse Analytics | Data warehouse |
| Visualization | Power BI | Business intelligence |

## Design Patterns

### 1. **Medallion Architecture**
- **Bronze** (Raw): Unchanged source data
- **Silver** (Processed): Cleaned and validated
- **Gold** (Curated): Business-ready aggregates

### 2. **ELT Pattern**
Extract → Load → Transform
- Data loaded raw first
- Transformations in scalable compute (Databricks)

### 3. **Schema-on-Read**
- Flexible schema evolution
- No upfront schema enforcement

## Security & Governance

- **Authentication**: Azure AD / Managed Identity
- **Encryption**: At rest and in transit
- **RBAC**: Role-based access control
- **Audit**: Activity logs and monitoring

## Scalability Considerations

- **Data Lake**: Unlimited storage scale
- **Databricks**: Auto-scaling clusters
- **Synapse**: Elastic SQL pools
- **ADF**: Parallel execution with DIU scaling

## Cost Optimization

- **Storage tiers**: Hot/Cool/Archive based on access
- **Databricks**: Job clusters (terminate after use)
- **Synapse**: Pause when not in use
- **ADF**: On-demand triggers vs scheduled

## Monitoring & Observability

- Azure Monitor
- Log Analytics
- ADF monitoring dashboards
- Databricks job metrics
- Synapse query insights

## Future Enhancements

- Real-time streaming with Event Hubs
- ML integration with Azure ML
- Advanced analytics with Synapse Spark
- Data quality framework (Great Expectations)
- CI/CD with Azure DevOps
