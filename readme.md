# DEVOPSHIFT STACK 
## Installing Developer stack
<b>TTY:</b>
Usage: ./install-cluster.sh {install-kind|create-cluster [NAME]|install_ingress|install-prometheus|install_es|install_kafka|install_rmq|install-all}

<b>Ports</b>
This kind installation expose the following ports:

<b>Ingress</b> http://localhost:8080
<b>zookeeper</b> http://localhost:2181
<b>kafka bootstrap</b> localhost:9092
<b>kafka broker1</b> localhost:9093
<b>kafka broker2</b> localhost:9094
<b>RMQ</b> localhost:5672
<b>RMQ Managment site</b> http://localhost:8080/rmq/
<b>Kafka Connec UI</b> http://localhost:8000

### Step I run K8S kind
The following command will:
1. Check if your local machine has the following packages installed ["kind","kubectl","helm >V3"]
2. Configure new K8S Cluster using KIND project with Two nodes 
3. Install and configure Prometheus Monitoring platform and operator along with Ambassador Ingress.

First Installation time is around 4Minutes 
<b>From the root project run:</b>
~~~
./install-cluster.sh create-cluster [CLUSTERNAME]                                  
...
checking CLI requirments
Required CLI validated
creating new cluster and ingress on cluster named attenti
Creating kind cluster attenti
No kind nodes found for cluster "attenti".
Creating cluster "attenti" ...
 ✓ Ensuring node image (kindest/node:v1.17.0) 🖼
 ✓ Preparing nodes 📦 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌 
 ✓ Installing StorageClass 💾 
 ✓ Joining worker nodes 🚜 
 ✓ Waiting ≤ 4m0s for control-plane = Ready ⏳ 
 • Ready after 2s 💚
Set kubectl context to "kind-attenti"
You can now use your cluster with:
~~~
<b> Once installation is completed</b>
expcected results:
~~~
.......
CLUSTER READY
~~~
<b>Note</b>: If the installation of Ambassador or prometheus will fail,
an error message will be shown.

<b>Once fixed you may run:</b>
1. ./install-cluster install-ingress

2. ./install-cluster install-prometheus

Run the following Command to validate:

~~~
kubectl get all -A
NAMESPACE            NAME                                                         READY   STATUS    RESTARTS   AGE
ambassador           pod/ambassador-6c67f577c6-46kdw                              1/1     Running   0          5m40s
ambassador           pod/ambassador-6c67f577c6-9ckg9                              1/1     Running   0          5m40s
ambassador           pod/ambassador-6c67f577c6-ms8t8                              1/1     Running   0          5m40s
default              pod/alertmanager-prometheus-prometheus-oper-alertmanager-0   2/2     Running   0          2m4s
default              pod/prometheus-grafana-5c6cdccddb-t8cgz                      2/2     Running   0          4m25s
default              pod/prometheus-kube-state-metrics-d5dc994cc-x4cv2            1/1     Running   0          4m25s
default              pod/prometheus-prometheus-node-exporter-cqkhr                1/1     Running   0          4m25s
default              pod/prometheus-prometheus-node-exporter-gw2sl                1/1     Running   0          4m25s
default              pod/prometheus-prometheus-oper-operator-696cd4c8c6-kh2vx     2/2     Running   0          4m25s
default              pod/prometheus-prometheus-prometheus-oper-prometheus-0       3/3     Running   1          114s
kube-system          pod/coredns-6955765f44-dvpkt                                 1/1     Running   0          6m38s
kube-system          pod/coredns-6955765f44-gkghw                                 1/1     Running   0          6m38s
kube-system          pod/etcd-attenti-control-plane                               1/1     Running   0          6m55s
kube-system          pod/kindnet-h9nbx                                            1/1     Running   0          6m38s
kube-system          pod/kindnet-rk5p7                                            1/1     Running   0          6m27s
kube-system          pod/kube-apiserver-attenti-control-plane                     1/1     Running   0          6m55s
kube-system          pod/kube-controller-manager-attenti-control-plane            1/1     Running   0          6m55s
kube-system          pod/kube-proxy-k7w4t                                         1/1     Running   0          6m38s
kube-system          pod/kube-proxy-x9hsp                                         1/1     Running   0          6m27s
kube-system          pod/kube-scheduler-attenti-control-plane                     1/1     Running   0          6m55s
local-path-storage   pod/local-path-provisioner-7745554f7f-tw8vj                  1/1     Running   0          6m38s

NAMESPACE     NAME                                                         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                        AGE
ambassador    service/ambassador                                           NodePort    10.96.155.249   <none>        80:32757/TCP,443:30578/TCP     5m40s
ambassador    service/ambassador-admin                                     ClusterIP   10.96.117.99    <none>        8877/TCP                       5m40s
default       service/alertmanager-operated                                ClusterIP   None            <none>        9093/TCP,9094/TCP,9094/UDP     2m5s
default       service/kubernetes                                           ClusterIP   10.96.0.1       <none>        443/TCP                        6m57s
default       service/prometheus-grafana                                   ClusterIP   10.96.217.16    <none>        80/TCP                         4m25s
default       service/prometheus-kube-state-metrics                        ClusterIP   10.96.226.236   <none>        8080/TCP                       4m25s
default       service/prometheus-operated                                  ClusterIP   None            <none>        9090/TCP                       114s
default       service/prometheus-prometheus-node-exporter                  ClusterIP   10.96.214.236   <none>        9100/TCP                       4m25s
default       service/prometheus-prometheus-oper-alertmanager              ClusterIP   10.96.189.106   <none>        9093/TCP                       4m25s
default       service/prometheus-prometheus-oper-operator                  ClusterIP   10.96.55.255    <none>        8080/TCP,443/TCP               4m25s
default       service/prometheus-prometheus-oper-prometheus                ClusterIP   10.96.209.94    <none>        9090/TCP                       4m25s
kube-system   service/kube-dns                                             ClusterIP   10.96.0.10      <none>        53/UDP,53/TCP,9153/TCP         6m56s
kube-system   service/prometheus-prometheus-oper-coredns                   ClusterIP   None            <none>        9153/TCP                       4m25s
kube-system   service/prometheus-prometheus-oper-kube-controller-manager   ClusterIP   None            <none>        10252/TCP                      4m25s
kube-system   service/prometheus-prometheus-oper-kube-etcd                 ClusterIP   None            <none>        2379/TCP                       4m25s
kube-system   service/prometheus-prometheus-oper-kube-proxy                ClusterIP   None            <none>        10249/TCP                      4m25s
kube-system   service/prometheus-prometheus-oper-kube-scheduler            ClusterIP   None            <none>        10251/TCP                      4m25s
kube-system   service/prometheus-prometheus-oper-kubelet                   ClusterIP   None            <none>        10250/TCP,10255/TCP,4194/TCP   115s

NAMESPACE     NAME                                                 DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR                 AGE
default       daemonset.apps/prometheus-prometheus-node-exporter   2         2         2       2            2           <none>                        4m25s
kube-system   daemonset.apps/kindnet                               2         2         2       2            2           <none>                        6m55s
kube-system   daemonset.apps/kube-proxy                            2         2         2       2            2           beta.kubernetes.io/os=linux   6m56s

NAMESPACE            NAME                                                  READY   UP-TO-DATE   AVAILABLE   AGE
ambassador           deployment.apps/ambassador                            3/3     3            3           5m40s
default              deployment.apps/prometheus-grafana                    1/1     1            1           4m25s
default              deployment.apps/prometheus-kube-state-metrics         1/1     1            1           4m25s
default              deployment.apps/prometheus-prometheus-oper-operator   1/1     1            1           4m25s
kube-system          deployment.apps/coredns                               2/2     2            2           6m56s
local-path-storage   deployment.apps/local-path-provisioner                1/1     1            1           6m54s

NAMESPACE            NAME                                                             DESIRED   CURRENT   READY   AGE
ambassador           replicaset.apps/ambassador-6c67f577c6                            3         3         3       5m40s
default              replicaset.apps/prometheus-grafana-5c6cdccddb                    1         1         1       4m25s
default              replicaset.apps/prometheus-kube-state-metrics-d5dc994cc          1         1         1       4m25s
default              replicaset.apps/prometheus-prometheus-oper-operator-696cd4c8c6   1         1         1       4m25s
kube-system          replicaset.apps/coredns-6955765f44                               2         2         2       6m38s
local-path-storage   replicaset.apps/local-path-provisioner-7745554f7f                1         1         1       6m38s

NAMESPACE   NAME                                                                    READY   AGE
default     statefulset.apps/alertmanager-prometheus-prometheus-oper-alertmanager   1/1     2m4s
default     statefulset.apps/prometheus-prometheus-prometheus-oper-prometheus       1/1     114s
~~~


__________


### Step II install KAFKA
Run the following command to install:
1. KAFKA Operator and CRDS
2. Kafka Cluster of 1 Broker + Zookeeper
3. Kafka Registry
4. Kafka Bridge 
5. Kafka Connect
6. Kafka Connect UI
5. Kafka prometheus KPI's
~~~
./install-cluster install-kafka
checking CLI requirments
Required CLI validated
installing kafka on local cluster

Installing KAFKA Operators

NAME: kafka
LAST DEPLOYED: Wed May 13 18:24:21 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
Thank you for installing strimzi-kafka-operator-0.17.0

To create a Kafka cluster refer to the following documentation.

https://strimzi.io/docs/0.17.0/#kafka-cluster-str

Installing KAFKA Cluster

NAME: kafka-cluster
LAST DEPLOYED: Wed May 13 18:24:23 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
To produce messages externaly:

curl -X POST \
  http://localhost:8081/topics/my-topic \
  -H 'content-type: application/vnd.kafka.json.v2+json' \
  -d '{
    "records": [
        {
            "key": "key-1",
            "value": "value-1"
        },
        {
            "key": "key-2",
            "value": "value-2"
        }
    ]  
}'

For more information:
https://strimzi.io/blog/2019/11/05/exposing-http-bridge/

Waiting for KAFKA Cluster to be deployed (up to 4 minutes)

error: no matching resources found

Installing KAFKA Registry

NAME: kafka-registry
LAST DEPLOYED: Wed May 13 18:24:25 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
This chart installs a Confluent Kafka Schema Registry

https://github.com/confluentinc/schema-registry

Waiting for KAFKA Registry to be deployed (up to 4 minutes)

~~~

Once Kafka is deployed please run:

1. ./install-cluster.sh install-rmq
