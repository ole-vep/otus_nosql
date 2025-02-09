from confluent_kafka import Consumer, KafkaException

config = {
    'bootstrap.servers': 'localhost:9091',  # Список серверов Kafka
    'group.id': 'mygroup',                  # Идентификатор группы потребителей
    'auto.offset.reset': 'earliest'         # Начальная точка чтения ('earliest' или 'latest')
}

consumer = Consumer(config)

consumer.subscribe(['test_topic1'])

try:
    while True:
        msg = consumer.poll(timeout=1.0)  # ожидание сообщения
        if msg is None:                   # если сообщений нет
            continue
        if msg.error():                   # обработка ошибок
            raise KafkaException(msg.error())
        else:
            # действия с полученным сообщением
            print(f"Received message: {msg.value().decode('utf-8')}")
except KeyboardInterrupt:
    pass
finally:
    consumer.close()  # не забываем закрыть соединение
