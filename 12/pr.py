from confluent_kafka import Producer

config = {
    'bootstrap.servers': 'localhost:9091',
    'group.id': 'mygroup',
    'auto.offset.reset': 'earliest'
}

producer = Producer(config)

def send_message(topic, message):
    producer.produce(topic, value=message)
    producer.flush()

send_message('test_topic1', 'Hello Kafka World!')
send_message('test_topic1', 'How are you doing?')
