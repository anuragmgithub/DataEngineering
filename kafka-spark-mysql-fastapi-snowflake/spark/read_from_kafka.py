from pyspark.sql import SparkSession
from pyspark.sql.functions import udf, col
from pyspark.sql.types import StringType
import requests
import io
from fastavro import parse_schema, schemaless_reader

# ----------------------------------------
# 1. SparkSession with required packages
# ----------------------------------------
spark = SparkSession.builder \
    .appName("KafkaAvroReader") \
    .config("spark.jars.packages",
            "org.apache.spark:spark-sql-kafka-0-10_2.12:3.5.1,"
            "io.confluent:kafka-schema-registry-client:7.6.0,"
            "io.confluent:kafka-avro-serializer:7.6.0").config("spark.jars.repositories",  "https://packages.confluent.io/maven/").getOrCreate()

# ----------------------------------------
# 2. Kafka Configuration
# ----------------------------------------

topics = "orders,customers,products,transactions"

kafka_df = spark.readStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", "localhost:9092") \
    .option("subscribe", topics) \
    .option("startingOffsets", "earliest") \
    .load()

# ----------------------------------------
# 3. Schema Registry + Avro Decoder
# ----------------------------------------

SCHEMA_REGISTRY_URL = "http://localhost:8081"
schema_cache = {}

def get_latest_schema(topic):
    if topic not in schema_cache:
        url = f"{SCHEMA_REGISTRY_URL}/subjects/{topic}/versions/latest"
        res = requests.get(url)
        schema_json = res.json()["schema"]
        schema_cache[topic] = parse_schema(eval(schema_json))  # Convert str to dict
    return schema_cache[topic]

def decode_avro(value_bytes, topic):
    try:
        raw_bytes = io.BytesIO(value_bytes[5:])  # Skip magic byte + schema ID
        schema = get_latest_schema(topic)
        record = schemaless_reader(raw_bytes, schema)
        return str(record)
    except Exception as e:
        return f"Error decoding: {e}"

decode_udf = udf(lambda value, topic: decode_avro(value, topic), StringType())

# ----------------------------------------
# 4. Decode Avro + Output
# ----------------------------------------

decoded_df = kafka_df.withColumn("decoded_value", decode_udf(col("value"), col("topic"))) \
                     .selectExpr("CAST(key AS STRING) as key", "topic", "decoded_value")

query = decoded_df.writeStream \
    .outputMode("append") \
    .format("console") \
    .option("truncate", False) \
    .start()

query.awaitTermination()
