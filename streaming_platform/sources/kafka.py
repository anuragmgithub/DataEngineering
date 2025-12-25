from pyspark.sql import DataFrame, SparkSession
from sources.base import Source
from configs.schema import KafkaSourceConfig

class kafkaSource(Source):
    def __init__(self, spark: SparkSession, config: KafkaSourceConfig):
        self.spark = spark
        self.config = config

    def read(self) -> DataFrame:
        df = (
            self.spark.readStream.format("kafka")
            .option("kafka.bootstrap.servers", self.config.bootstrap_servers)
            .option("subscribe", self.config.topic)
            .option("startingOffsets", self.config.starting_offsets)
            .load()
        )
        return df