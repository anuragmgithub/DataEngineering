from abc import ABC, abstractmethod 
from pyspark.sql import DataFrame

class Source(ABC):
    @abstractmethod
    def read(self) -> DataFrame:
        pass
