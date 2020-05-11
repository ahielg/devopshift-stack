# Installation instructions
In the following instrcution we will install:
1. Kafka Operator
2. Kafka Cluster
3. Kafka Connect + Registry + Kakfa Connect UI
4. RabbitMQ

## Installing Kafka Operator
~~~
helm install kafka-operator ./01-operators
~~~
Validate CRDS by running:
~~~
kubectl get crds
git push -u origin master
Expected:
NAME                                  CREATED AT
kafkabridges.kafka.strimzi.io         2020-04-20T09:57:14Z
kafkaconnectors.kafka.strimzi.io      2020-04-20T09:57:14Z
kafkaconnects.kafka.strimzi.io        2020-04-20T09:57:14Z
kafkaconnects2is.kafka.strimzi.io     2020-04-20T09:57:14Z
kafkamirrormaker2s.kafka.strimzi.io   2020-04-20T09:57:14Z
kafkamirrormakers.kafka.strimzi.io    2020-04-20T09:57:14Z
kafkas.kafka.strimzi.io               2020-04-20T09:57:14Z
kafkatopics.kafka.strimzi.io          2020-04-20T09:57:14Z
kafkausers.kafka.strimzi.io           2020-04-20T09:57:14Z
~~~

Check if the operator pod is up and running:
~~~
kubectl get pods -l strimzi.io/kind=cluster-operator


NAME                                        READY   STATUS    RESTARTS   AGE
strimzi-cluster-operator-59b99fc7cf-s48wl   1/1     Running   0          18m
~~~

## Installing Kafka Cluster 
Installing kafka cluster single node.
~~~
helm install  kafka-cluster  02-clusters

Validate cluster deployment:
kubectl get kafka 
NAME            DESIRED KAFKA REPLICAS   DESIRED ZK REPLICAS
kafka-cluster   1                        1

get pods -l app.kubernetes.io/managed-by=strimzi-cluster-operator
expected results (note that first the zookeeper will show and later on the other pods)
NAME                                             READY   STATUS    RESTARTS   AGE
kafka-cluster-entity-operator-66595c7df6-k9xm5   3/3     Running   0          93s
kafka-cluster-kafka-0                            2/2     Running   0          2m5s
kafka-cluster-zookeeper-0                        2/2     Running   0          2m32s
~~~

## Installing Kafka Registry
1. Get the bootstrap svc that will be used by the kafka connect side cluster (broker[s])
~~~
kubectl get svc -l app.kubernetes.io/managed-by=strimzi-cluster-operator | grep kafka-cluster-kafka-bootstrap
Expected results:
kafka-cluster-kafka-bootstrap            ClusterIP   10.96.230.50    <none>        9091/TCP,9092/TCP,9093/TCP   7m9s
kafka-cluster-kafka-external-bootstrap   NodePort    10.96.185.32    <none>        9094:31234/TCP               7m9s
~~~

Using the bootstrap SVC for our kafka cluster, 
run the following command
~~~
helm install kafkaregistry --set kafka.bootstrapServers="PLAINTEXT://kafka-cluster-kafka-bootstrap:9092" 03-connectNregistry/kafka-registry/
~~~

Validate functionality 
~~~
kubectl get pods -l app=cp-schema-registry
AND
kubectl logs -l app=cp-schema-registry -c cp-schema-registry-server
~~~
## Installing Kafka connect
This will install kafka Connect  Kafka connect UI

Using the bootstrap SVC for our kafka cluster, 
run the following command
~~~
helm install kafkaconnect --set kafka.bootstrapServers="PLAINTEXT://kafka-cluster-kafka-bootstrap:9092",cp-schema-registry.url="kafkaregistry-cp-schema-registry:8081" 03-connectNregistry/kafka-connect

Validate:
kubectl get pods -l release=kafkaconnect
NAME                                            READY   STATUS    RESTARTS   AGE
kafkaconnect-cp-kafka-connect-cdd68f768-qk4cc   2/2     Running   0          51s
kafkaconnect-kafka-ui                           1/1     Running   0          51s

AND

kubectl logs -f kafkaconnect-cp-kafka-connect-cdd68f768-qk4cc
~~~

### Validate Kafka connect is working by
Exposing kafka-ui Pod to 8080
~~~
kubectl port-forward pods/kafkaconnect-kafka-ui --address 0.0.0.0 8080:8000                                                           
~~~

Expected result:
![alt text](https://github.com/yanivomc/devopshift-stack/blob/master/helm/kafka/screanshoots/kafka-connect-ui-01.png?raw=true "Logo Title Text 1")

## Installing Rabbitmq
Run the following:

~~~
helm install rmq 04-rabbitmq/
~~~
Once installed pull the user & password:
~~~
    echo "Username      : user"
    echo "Password      : $(kubectl get secret --namespace default rmq-rabbitmq -o jsonpath="{.data.rabbitmq-password}" | base64 --decode)"
    echo "ErLang Cookie : $(kubectl get secret --namespace default rmq-rabbitmq -o jsonpath="{.data.rabbitmq-erlang-cookie}" | base64 --decode)"
~~~

Expose the manamgnet ui
~~~
kubectl port-forward --namespace default svc/rmq-rabbitmq 15672:15672
~~~

#### Configure new QUEUE to work with Kafka conenct
For kafka connect RMQ to work,
we need to configure an EXCHANGE and bind it to a queue.

Use RMQ UI to create it by follwoing the next steps:
1. open RMQ UI http://localhost:15672
2. Login with the user/pass above
3. Go to QUEUE and create a new Queue named connectq1
4. Go to Exchange and create a new EXCHANGE named exchangermq
4.1 Type: Fanout and click create.
4.2 Once created click on the new exchange name
4.3 On "Add binding from this exchange" type the name of the queue you've created: "connectq1" and click BIND

RMQ Setup is now completed.


## Configuring KAFKA CONNECT TO RMQ
Open Kafka connect UI
if colosed run:
~~~
kubectl port-forward pods/kafkaconnect-kafka-ui   --address 0.0.0.0 8080:8000
~~~

Run the following:
1. Click NEW
2. Select "RabbitMQSinkConnector"
3. On the editor window paste the following:

~~~
name=RabbitMQSinkConnector
connector.class=com.datamountaineer.streamreactor.connect.rabbitmq.sink.RabbitMQSinkConnector
connect.rabbitmq.password=???????
errors.log.include.messages=true
connect.rabbitmq.port=??????
connect.rabbitmq.username=????
topics=topic-posts
tasks.max=1
errors.deadletterqueue.context.headers.enable=true
connect.rabbitmq.kcql=INSERT INTO exchangermq SELECT * FROM topic-posts
connect.rabbitmq.use.tls=false
errors.deadletterqueue.topic.name=deadqueu
connect.rabbitmq.host=rmq2-rabbitmq
value.converter.schemas.enable=false
errors.tolerance=all
errors.deadletterqueue.topic.replication.factor=1
value.converter=org.apache.kafka.connect.json.JsonConverter
errors.log.enable=true
key.converter=org.apache.kafka.connect.json.JsonConverter
~~~
Dont forget to update:
- connect.rabbitmq.password=???
- connect.rabbitmq.username=???
- connect.rabbitmq.port=?????
- connect.rabbitmq.host=????




4. Click Validate and save (ignore warrning)
4.1 If page dosent load - click refresh
5. Click on the name of the newly added connector (on the left of the screen)
6. Connector is configured and working

Notes:
Dont change configuration without understanding what are the outcomes and what every field do.

For error handling and other config options check:
https://kafka.apache.org/24/documentation.html#sinkconnectconfigs

This is an open source connector! apache2 but the configuration are confluent.

RMQ CONNECTOR GITHUB:
https://github.com/lensesio/stream-reactor


## Load data to kafka topic and see it flow to RMQ
Run the following:
~~~
kubectl exec -ti kafka-cluster-kafka-0 bash
~~~

Producing data: (JSON)
~~~
bin/kafka-console-producer.sh \
    --broker-list localhost:9092 \
    --topic topic-posts

click enter
---
~~~

Paste some jsons
https://gist.github.com/hpgrahsl/8c145bf12c3b98d8b5146632bddc6d6d
