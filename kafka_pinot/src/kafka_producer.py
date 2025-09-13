from kafka import KafkaProducer
import json
import time
import uuid

producer = KafkaProducer(
    bootstrap_servers='localhost:9092',
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

def send_event(user_id, event_type, amount):
    event = {
        "eventId": str(uuid.uuid4()),
        "userId": user_id,
        "eventType": event_type,
        "amount": amount,
        "ts": int(time.time() * 1000)
    }
    producer.send('events_topic', event)
    producer.flush()

if __name__ == "__main__":
    for i in range(10):
        send_event(f"user_{i}", "purchase", i*10)
        time.sleep(1)
