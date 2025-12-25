from pydantic import BaseModel, Field, validator
from typing import Literal, Optional, Dict 


# ---------- Pipeline ----------
class PipelineConfig(BaseModel):
    name: str
    mode: Literal["batch", "stream"]


# ---------- Source ----------
class KafkaSourceConfig(BaseModel):
    type: Literal["kafka"]
    bootstrap_servers: str
    topic: str
    starting_offsets: Literal["earliest", "latest"] = "latest"


# ---------- Target ----------
class MySQLTargetConfig(BaseModel):
    type: Literal["mysql"]
    host: str
    port: int = 3306
    database: str
    table: str
    user: str
    password: str


# ---------- Spark ----------
class SparkConfig(BaseModel):
    app_name: str
    master: str
    configs: Dict[str, str] = {}


# ---------- Metrics ----------
class MetricsConfig(BaseModel):
    enabled: bool = False
    port: int = 8000


# ---------- Root ----------
class AppConfig(BaseModel):
    pipeline: PipelineConfig
    source: KafkaSourceConfig
    target: MySQLTargetConfig
    spark: SparkConfig
    metrics: Optional[MetricsConfig] = MetricsConfig()
