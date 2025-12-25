from pyspark.sql import SparkSession
from configs.schema import SparkConfig


class SparkSessionfactory:
    """
    _spark belongs to the class, not instances
    Shared across entire Python process
    Guarantees singleton behavior
"""
    _spark = None

    @classmethod
    def get_spark_session(cls, spark_config: SparkConfig) -> SparkSession:
        if cls._spark is None:
            builder = SparkSession.builder.appName(spark_config.app_name).master(spark_config.master)

            # Apply additional spark configurations
            for key, value in spark_config.configs.items():
                builder = builder.config(key, value)
            
            cls._spark = builder.getOrCreate()

            return cls._spark
