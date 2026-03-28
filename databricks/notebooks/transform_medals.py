# Databricks notebook source
# MAGIC %md
# MAGIC # Medals Data Transformation
# MAGIC 
# MAGIC This notebook performs data cleaning and transformation on the Medals dataset from Tokyo Olympics.

# COMMAND ----------

from pyspark.sql import SparkSession
from pyspark.sql.functions import col, trim, sum as _sum, desc, row_number
from pyspark.sql.window import Window

# COMMAND ----------

spark = SparkSession.builder.appName("Olympics-Medals-Transform").getOrCreate()

# COMMAND ----------

# MAGIC %md
# MAGIC ## Read Raw Data

# COMMAND ----------

storage_account_name = "olympicsdatalake123"
container_name = "raw"
mount_point = f"/mnt/{container_name}"

medals_df = spark.read.csv(
    f"{mount_point}/olympics/Medals.csv",
    header=True,
    inferSchema=True
)

print(f"Total records loaded: {medals_df.count()}")
display(medals_df.limit(10))

# COMMAND ----------

# MAGIC %md
# MAGIC ## Data Transformation

# COMMAND ----------

# Clean and transform
medals_clean = medals_df \
    .dropna() \
    .dropDuplicates() \
    .withColumnRenamed("Team_Country", "Country") \
    .withColumnRenamed("Rank_by_Total", "Total_Rank") \
    .withColumn("Country", trim(col("Country"))) \
    .withColumn("Medal_Score", 
                col("Gold") * 3 + col("Silver") * 2 + col("Bronze") * 1)

print(f"Records after cleaning: {medals_clean.count()}")
display(medals_clean.limit(10))

# COMMAND ----------

# MAGIC %md
# MAGIC ## Analytics

# COMMAND ----------

# Top 5 countries by gold medals
print("=== Top 5 Countries by Gold Medals ===")
top_gold = medals_clean \
    .orderBy(desc("Gold")) \
    .select("Country", "Gold", "Silver", "Bronze", "Total") \
    .limit(5)

display(top_gold)

# Total medals statistics
print("\n=== Total Medals Statistics ===")
total_stats = medals_clean.agg(
    _sum("Gold").alias("Total_Gold"),
    _sum("Silver").alias("Total_Silver"),
    _sum("Bronze").alias("Total_Bronze"),
    _sum("Total").alias("Total_Medals")
)

display(total_stats)

# COMMAND ----------

# MAGIC %md
# MAGIC ## Write Processed Data

# COMMAND ----------

# Write to processed layer (Parquet)
output_path = "/mnt/processed/olympics/medals"
medals_clean.write.mode("overwrite").parquet(output_path)

# Write to curated layer (Delta)
curated_path = "/mnt/curated/olympics/medals"
medals_clean.write.format("delta").mode("overwrite").save(curated_path)

print(f"✅ Medals data successfully transformed and saved")
