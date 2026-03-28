# Databricks notebook source
# MAGIC %md
# MAGIC # Entries by Gender Data Transformation

# COMMAND ----------

from pyspark.sql import SparkSession
from pyspark.sql.functions import col, trim, round as spark_round

# COMMAND ----------

spark = SparkSession.builder.appName("Olympics-EntriesGender-Transform").getOrCreate()

# COMMAND ----------

# MAGIC %md
# MAGIC ## Read and Transform Data

# COMMAND ----------

mount_point = "/mnt/raw"

entriesgender_df = spark.read.csv(
    f"{mount_point}/olympics/EntriesGender.csv",
    header=True,
    inferSchema=True
)

print(f"Total records: {entriesgender_df.count()}")

# COMMAND ----------

# Clean and add calculated columns
entriesgender_clean = entriesgender_df \
    .dropna() \
    .dropDuplicates() \
    .withColumn("Discipline", trim(col("Discipline"))) \
    .withColumn("Female_Percentage", 
                spark_round((col("Female") / col("Total")) * 100, 2)) \
    .withColumn("Male_Percentage", 
                spark_round((col("Male") / col("Total")) * 100, 2))

display(entriesgender_clean.limit(10))

# COMMAND ----------

# MAGIC %md
# MAGIC ## Gender Parity Analysis

# COMMAND ----------

# Find disciplines with perfect gender parity
parity_disciplines = entriesgender_clean \
    .filter(col("Female") == col("Male")) \
    .select("Discipline", "Female", "Male", "Total")

print(f"Disciplines with gender parity: {parity_disciplines.count()}")
display(parity_disciplines)

# COMMAND ----------

# MAGIC %md
# MAGIC ## Write Processed Data

# COMMAND ----------

# Write to processed and curated layers
entriesgender_clean.write.mode("overwrite").parquet("/mnt/processed/olympics/entriesgender")
entriesgender_clean.write.format("delta").mode("overwrite").save("/mnt/curated/olympics/entriesgender")

print("✅ EntriesGender data transformation complete")
