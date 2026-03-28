# Databricks notebook source
# MAGIC %md
# MAGIC # Athletes Data Transformation
# MAGIC 
# MAGIC This notebook performs data cleaning and transformation on the Athletes dataset from Tokyo Olympics.

# COMMAND ----------

from pyspark.sql import SparkSession
from pyspark.sql.functions import col, trim, upper, count, when, isnan

# COMMAND ----------

# MAGIC %md
# MAGIC ## 1. Initialize Spark Session

# COMMAND ----------

spark = SparkSession.builder.appName("Olympics-Athletes-Transform").getOrCreate()

# COMMAND ----------

# MAGIC %md
# MAGIC ## 2. Read Raw Data from ADLS

# COMMAND ----------

# Mount point configuration (update with your storage account details)
storage_account_name = "olympicsdatalake123"
container_name = "raw"
mount_point = f"/mnt/{container_name}"

# Read Athletes CSV
athletes_df = spark.read.csv(
    f"{mount_point}/olympics/Athletes.csv",
    header=True,
    inferSchema=True
)

print(f"Total records loaded: {athletes_df.count()}")
athletes_df.printSchema()

# COMMAND ----------

# MAGIC %md
# MAGIC ## 3. Data Quality Checks

# COMMAND ----------

# Display sample data
display(athletes_df.limit(10))

# Check for null values
print("\n=== Null Value Check ===")
athletes_df.select([count(when(col(c).isNull(), c)).alias(c) for c in athletes_df.columns]).show()

# Check for duplicates
print(f"\nTotal duplicates: {athletes_df.count() - athletes_df.dropDuplicates().count()}")

# COMMAND ----------

# MAGIC %md
# MAGIC ## 4. Data Cleaning and Transformation

# COMMAND ----------

# Clean and transform the data
athletes_clean = athletes_df \
    .dropna() \
    .dropDuplicates() \
    .withColumnRenamed("PersonName", "Athlete_Name") \
    .withColumn("Athlete_Name", trim(col("Athlete_Name"))) \
    .withColumn("Country", trim(col("Country"))) \
    .withColumn("Discipline", trim(col("Discipline"))) \
    .withColumn("Country_Upper", upper(col("Country")))

print(f"Records after cleaning: {athletes_clean.count()}")
display(athletes_clean.limit(10))

# COMMAND ----------

# MAGIC %md
# MAGIC ## 5. Generate Statistics

# COMMAND ----------

# Athletes by Country
print("\n=== Top 10 Countries by Athlete Count ===")
athletes_by_country = athletes_clean \
    .groupBy("Country") \
    .count() \
    .orderBy(col("count").desc()) \
    .limit(10)

display(athletes_by_country)

# Athletes by Discipline
print("\n=== Top 10 Disciplines by Athlete Count ===")
athletes_by_discipline = athletes_clean \
    .groupBy("Discipline") \
    .count() \
    .orderBy(col("count").desc()) \
    .limit(10)

display(athletes_by_discipline)

# COMMAND ----------

# MAGIC %md
# MAGIC ## 6. Write Processed Data to ADLS

# COMMAND ----------

# Write to processed container in Parquet format
output_path = "/mnt/processed/olympics/athletes"

athletes_clean.write \
    .mode("overwrite") \
    .parquet(output_path)

print(f"Data successfully written to: {output_path}")

# COMMAND ----------

# MAGIC %md
# MAGIC ## 7. Write to Curated Layer (Delta Format)

# COMMAND ----------

# Write to curated container in Delta format for better querying
curated_path = "/mnt/curated/olympics/athletes"

athletes_clean.write \
    .format("delta") \
    .mode("overwrite") \
    .save(curated_path)

print(f"Delta table successfully written to: {curated_path}")

# COMMAND ----------

# MAGIC %md
# MAGIC ## Transformation Complete ✅
