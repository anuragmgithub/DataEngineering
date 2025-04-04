import json
import random
import time
from faker import Faker
from confluent_kafka import SerializingProducer
from confluent_kafka.schema_registry import SchemaRegistryClient
from confluent_kafka.schema_registry.avro import AvroSerializer
from confluent_kafka.schema_registry import topic_subject_name_strategy
from confluent_kafka.schema_registry import record_subject_name_strategy

fake = Faker()

SCHEMA_REGISTRY_URL = "http://localhost:8081"
KAFKA_BROKER = "localhost:9092"

# Initialize Schema Registry
schema_registry_client = SchemaRegistryClient({"url": SCHEMA_REGISTRY_URL})

# Load Avro Schemas
def load_avro_schema(schema_name):
    with open(f"kafka/schemas/{schema_name}.avsc", "r") as f:
        return f.read()

schemas = {
    "orders": load_avro_schema("orders"),
    "customers": load_avro_schema("customers"),
    "products": load_avro_schema("products"),
    "transactions": load_avro_schema("transactions"),
}

print("Schemas loaded successfully.")
print(schemas)

avro_serializers = {
    topic: AvroSerializer(
        schema_registry_client=schema_registry_client,
        schema_str=schemas[topic],
        conf={"subject.name.strategy": record_subject_name_strategy},
    )
    for topic in schemas
}

# Kafka Producer Configuration
# producer_conf = {
#     "bootstrap.servers": KAFKA_BROKER,
#     "key.serializer": str.encode
# }
# producer = SerializingProducer(producer_conf)

from confluent_kafka.serialization import StringSerializer

producer_conf = {
    "bootstrap.servers": KAFKA_BROKER,
    "key.serializer": StringSerializer("utf_8")
}

producer = SerializingProducer(producer_conf)


# Generate Fake Data
def generate_fake_data():
    return {
        "orders": {
            "id": random.randint(1, 1000),
            "customer_id": random.randint(1, 100),
            "product_id": random.randint(1, 50),
            "amount": round(random.uniform(10, 1000), 2),
            "timestamp": fake.iso8601(),
        },
        "customers": {
            "id": random.randint(1, 100),
            "name": fake.name(),
            "email": fake.email(),
            "phone": fake.phone_number(),
            "address": fake.address(),
        },
        "products": {
            "id": random.randint(1, 50),
            "name": fake.word(),
            "category": fake.word(),
            "price": round(random.uniform(10, 500), 2),
            "stock": random.randint(0, 100),
        },
        "transactions": {
            "id": random.randint(1, 1000),
            "order_id": random.randint(1, 1000),
            "payment_method": random.choice(["Credit Card", "Debit Card", "PayPal"]),
            "status": random.choice(["Pending", "Completed", "Failed"]),
            "timestamp": fake.iso8601(),
        },
    }

# Produce messages
def produce_messages():
    while True:
        for topic in schemas.keys():
            print(f"Producing to topic: {topic}")
            data = generate_fake_data()[topic]
            print(f"Data: {data}")
            producer.produce(
                topic=topic,
                key=str(data["id"]),
                value=avro_serializers[topic](data),
                on_delivery=lambda err, msg: print(
                    f"Delivered to {msg.topic()} [{msg.partition()}]" if not err else f"Error: {err}"
                ),
            )
        producer.flush()
        time.sleep(2)

if __name__ == "__main__":
    produce_messages()
