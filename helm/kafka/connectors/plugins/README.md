# LEANSES CONNECTORS
https://github.com/lensesio/stream-reactor/releases



when creating the connector configuration a binding between the exchange and and the queue in 
rabbitmq need to be set 


working connector setup
connector.class=com.datamountaineer.streamreactor.connect.rabbitmq.sink.RabbitMQSinkConnector
connect.rabbitmq.password=qd8bcqqke1
errors.log.include.messages= true
connect.rabbitmq.port=5672
connect.rabbitmq.username=user
topics=blogpost5
tasks.max=1
errors.deadletterqueue.context.headers.enable=true
value.errors.log.enable=true
connect.rabbitmq.kcql=INSERT INTO yaniv SELECT * FROM blogpost5 WITHTYPE yaniv
connect.rabbitmq.use.tls=false
errors.deadletterqueue.topic.name=deadletter
connect.rabbitmq.host=rmq-rabbitmq
value.converter.schemas.enable=false
errors.tolerance=all
errors.deadletterqueue.topic.replication.factor=1
value.converter=org.apache.kafka.connect.json.JsonConverter
key.converter=org.apache.kafka.connect.json.JsonConverter
