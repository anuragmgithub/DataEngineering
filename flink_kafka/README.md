# Flink Kafka Streaming Project

## Overview
This project demonstrates a full **continuous streaming pipeline** using Flink and Kafka:

- Continuous sensor data ingestion via Kafka
- Real-time processing in Flink (stateful + anomaly detection)
- Output to another Kafka topic
- Checkpointing for fault-tolerance
- Real-time alerts (temperature > 80°C)
- Can be extended to exactly-once sinks (Kafka transactional producer)

## How to Run
1. Start Docker services:
   docker-compose -f docker/docker-compose.yml up -d
2. Run Kafka producer:
   python3 producer/kafka_producer.py
3. Submit Flink Python job:
   docker exec -it flink-jobmanager /bin/bash
   python /opt/flink_job/flink_kafka_job.py
4. Consume processed events:
   kafka-console-consumer.sh --bootstrap-server kafka:9092 --topic output-topic --from-beginning
