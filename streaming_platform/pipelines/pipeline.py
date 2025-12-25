from configs.schema import AppConfig
from pipelines.pipeline_base import SparkSessionfactory
from sources.kafka import kafkaSource

class Pipeline:
    def __init__(self, config: AppConfig):
        self.config = config
        self.spark = SparkSessionfactory.get_spark_session(config.spark)

    def run(self):
        if self.config.source.type == "kafka":
            source = kafkaSource(self.spark, self.config.source.kafka)
            df = source.read()
            
            
