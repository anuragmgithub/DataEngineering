from pathlib import Path
import yaml
from configs.schema import AppConfig 

def load_conifg(config_path: Path) -> AppConfig:
    with config_path.open("r") as f:
        config_dict = yaml.safe_load(f)
    return AppConfig(**config_dict)