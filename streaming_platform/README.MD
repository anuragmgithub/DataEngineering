streaming-platform/
│
├── docker-compose.yml               # All services: Kafka (3 nodes), Spark, MySQL, Postgres, Superset, Prometheus, Grafana
├── requirements.txt                 # Python dependencies
├── README.md
│
├── config/
│   ├── pipeline.yml                 # Config-driven pipeline definitions
│   └── settings.py                  # Centralized environment / DB / Kafka settings
│
├── pipelines/                       # Batch / Streaming pipelines
│   ├── __init__.py
│   ├── pipeline_base.py             # Singleton SparkSession + common utilities
│   ├── pipeline.py                  # Unified Pipeline class (batch & streaming)
│   └── kafka_to_mysql.py            # Example pipeline using Kafka source → MySQL target
│
├── sources/                         # Source abstractions
│   ├── __init__.py
│   ├── base.py                      # Abstract base class
│   └── kafka.py                     # Kafka source implementation
│
├── targets/                         # Target abstractions
│   ├── __init__.py
│   ├── base.py                      # Abstract base class
│   └── mysql.py                      # MySQL target implementation
│
├── producers/                        # Data producers to feed sources
│   └── kafka_producer.py
│
├── metrics/                          # Prometheus / custom metrics
│   ├── __init__.py
│   └── metrics.py
│
├── utils/                             # Helper functions (logging, validation, transformations)
│   ├── __init__.py
│   └── spark_utils.py
│
├── docker/                            # Dockerfiles / service configs
│   ├── spark/
│   │   └── Dockerfile
│   ├── kafka/
│   ├── mysql/
│   ├── prometheus/
│   └── superset/
│
└── tests/                             # Unit / integration tests
    └── test_pipeline.py
