# 🚀 Azure Data Factory Project

## 📊 Tokyo Olympics Data Analysis (End-to-End)

---

## 🎯 Aim

Build a scalable **data engineering pipeline on Azure** to ingest, transform, analyze, and visualize Tokyo Olympics data.

---

## 🎯 Objectives

* Build **ETL pipeline using Azure Data Factory (ADF)**
* Store data in **Azure Data Lake Gen2**
* Transform data using **Azure Databricks (PySpark)**
* Load curated data into **Azure Synapse / SQL DB**
* Visualize insights using **Power BI**

---

## 🧱 Architecture (High-Level)

```
GitHub / API (Raw Data)
        ↓
Azure Data Factory (Ingestion)
        ↓
Azure Data Lake Gen2 (Raw Layer)
        ↓
Azure Databricks (Transformation)
        ↓
Azure Data Lake Gen2 (Curated Layer)
        ↓
Azure Synapse Analytics / SQL DB
        ↓
Power BI Dashboard
```

👉 This is a **standard modern data pipeline** combining ADF + Databricks + Synapse ([GitHub][1])

---

## 🧰 Services Included

* Azure Data Factory (ADF)
* Azure Data Lake Storage Gen2
* Azure Databricks
* Azure Synapse Analytics / Azure SQL DB
* Power BI

---

## 📂 Dataset (Tokyo Olympics)

Use dataset from GitHub/Kaggle:

* Athletes.csv
* Coaches.csv
* Medals.csv
* Teams.csv
* EntriesGender.csv

👉 Data is typically ingested from GitHub using HTTP connector ([Medium][2])

---

# ⚙️ Step-by-Step Implementation

---

## 🔹 Step 1: Create Resource Group

```bash
az group create \
--name olympics-rg \
--location centralindia
```

---

## 🔹 Step 2: Create Storage Account (ADLS Gen2)

```bash
az storage account create \
--name olympicsdatalake123 \
--resource-group olympics-rg \
--location centralindia \
--sku Standard_LRS \
--hierarchical-namespace true
```

### Create Containers:

* raw
* processed
* curated

---

## 🔹 Step 3: Create Azure Data Factory

```bash
az datafactory create \
--resource-group olympics-rg \
--factory-name olympics-adf
```

---

## 🔹 Step 4: ADF Pipeline (Data Ingestion)

### 🔗 Linked Services

1. **HTTP (GitHub Source)**
2. **ADLS Gen2 (Destination)**

---

### 📥 Pipeline Activities

* Copy Data Activity

#### Source (HTTP Dataset)

```json
{
  "type": "HttpServer",
  "typeProperties": {
    "url": "https://raw.githubusercontent.com/.../Athletes.csv"
  }
}
```

#### Sink (ADLS)

```json
{
  "type": "AzureBlobFS",
  "typeProperties": {
    "folderPath": "raw/olympics/"
  }
}
```

👉 ADF orchestrates ingestion from GitHub → Data Lake ([Texas A&M University Personal Webpage][3])

---

## 🔹 Step 5: Data Transformation (Azure Databricks)

### 📘 PySpark Notebook

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("Olympics").getOrCreate()

# Read raw data
df = spark.read.csv("/mnt/raw/Athletes.csv", header=True, inferSchema=True)

# Clean data
df_clean = df.dropna()

# Example transformation
df_final = df_clean.withColumnRenamed("Name", "Athlete_Name")

# Write to processed layer
df_final.write.mode("overwrite").parquet("/mnt/processed/athletes")
```

👉 Databricks handles large-scale transformation using Spark ([GitHub][1])

---

## 🔹 Step 6: Orchestrate Databricks from ADF

Add activity:

* **Databricks Notebook Activity**

```json
{
  "type": "DatabricksNotebook",
  "typeProperties": {
    "notebookPath": "/Users/olympics-transform"
  }
}
```

---

## 🔹 Step 7: Load Data to Synapse

### Create Table

```sql
CREATE TABLE athletes (
    Athlete_Name VARCHAR(100),
    Country VARCHAR(50),
    Discipline VARCHAR(100)
);
```

### Copy from ADLS → Synapse using ADF

---

## 🔹 Step 8: Data Analysis (SQL)

```sql
-- Top countries by medals
SELECT Country, COUNT(*) AS TotalMedals
FROM medals
GROUP BY Country
ORDER BY TotalMedals DESC;
```

```sql
-- Gender participation
SELECT Gender, COUNT(*) 
FROM entriesgender
GROUP BY Gender;
```

---

## 🔹 Step 9: Power BI Dashboard

Create visuals:

* Medal Count by Country
* Athletes by Sport
* Gender Distribution
* Top Performing Countries

👉 Final insights are visualized via Power BI dashboards ([GitHub][4])

---

# 🔁 ADF Pipeline Flow (Final)

```
Copy Activity → Databricks Notebook → Copy to Synapse → Success
```

---

# 📊 Sample Insights

* USA / China top medal winners
* Athletics & Swimming most competitive sports
* Gender participation trends
* Country-wise performance

---

# 📦 Project Folder Structure

```
azure-olympics-project/
│
├── data/
├── notebooks/
│   └── transformation.py
├── adf-pipeline/
│   └── pipeline.json
├── sql/
│   └── queries.sql
├── powerbi/
│   └── dashboard.pbix
└── README.md
```

---

# 🧠 Interview / Resume Points

* Built **end-to-end Azure Data Engineering pipeline**
* Used **ADF for orchestration**
* Implemented **ETL using Databricks (PySpark)**
* Designed **Data Lake architecture (raw → processed → curated)**
* Integrated with **Synapse & Power BI**

---

# ✅ Conclusion

This project demonstrates a **production-grade Azure data pipeline**:

* Automated ingestion with ADF
* Scalable transformation using Spark
* Structured analytics via Synapse
* Business insights through Power BI

👉 This is exactly how modern **real-world data engineering systems are built on Azure**.

---
