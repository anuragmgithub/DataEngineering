import click
from pathlib import Path
from configs.loader import load_config
from pipelines.pipeline import Pipeline

@click.command()
@click.option(
    "--config",
    type=click.Path(exists=True, dir_okay=False, path_type=Path),
    required=True
)
def cli(config: Path):
    app_config = load_config(config)

    pipeline = Pipeline(app_config)
    pipeline.run()

if __name__ == "__main__":
    cli()
