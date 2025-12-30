FROM bitnami/spark:latest

WORKDIR /app

# Copy application
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY src/ ./src
COPY configs_rendered/app_config.yaml /app/config/app_config.yaml

ENV PYTHONPATH=/app

ENTRYPOINT ["spark-submit", "--master", "local[*]", "/app/src/main.py", "--config", "/app/config/app_config.yaml"]