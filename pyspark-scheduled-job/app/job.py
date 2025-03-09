from pyspark.sql import SparkSession
from pyspark.sql.functions import col, avg

# Initialize Spark session
spark = SparkSession.builder.appName("ScheduledJob").getOrCreate()

# Create sample data
data = [
    (1, "Alice", 5000),
    (2, "Bob", 3000),
    (3, "Charlie", 7000),
    (4, "David", 2000),
    (5, "Eve", 8000)
]

# Define schema
columns = ["id", "name", "salary"]

# Create DataFrame
df = spark.createDataFrame(data, columns)

# Transformation: Filter employees with salary > 4000
filtered_df = df.filter(col("salary") > 4000)

# Transformation: Calculate average salary
avg_salary = df.agg(avg("salary").alias("average_salary"))

# Show DataFrames
print("Filtered DataFrame:")
filtered_df.show()

print("Average Salary:")
avg_salary.show()

spark.stop()