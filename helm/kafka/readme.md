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
kubectl port-forward pods/kafkaconnect-kafka-ui   --address 0.0.0.0 8080:8000                                                           
~~~

Expected result:
![alt text](https://github.com/yanivomc/devopshift-stack/blob/master/helm/kafka/screanshoots/kafka-connect-ui-01.png?raw=true "Logo Title Text 1")