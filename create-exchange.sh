#!/bin/bash
# This will install k8s kind and ARGO CD

# Validate all cli tools are installed - PLEASE ADD CLI REQUIRED
declare -a CLI=("kubectl" "kind" "helm" "python" )
#export REGISTRY_IP=192.168.86.73 # Change to the IP where NEXUS is installed
#export REGISTRY_HOSTNAME=registry.emei # change to the name of the host name
export CLUSTER_NAME=localdev # change to the name of your cluster

function welcome {

#  /$$$$$$$  /$$$$$$$$ /$$    /$$  /$$$$$$  /$$$$$$$   /$$$$$$  /$$   /$$ /$$$$$$ /$$$$$$$$ /$$$$$$$$        /$$$$$$  /$$$$$$$$ /$$$$$$   /$$$$$$  /$$   /$$
# | $$__  $$| $$_____/| $$   | $$ /$$__  $$| $$__  $$ /$$__  $$| $$  | $$|_  $$_/| $$_____/|__  $$__/       /$$__  $$|__  $$__//$$__  $$ /$$__  $$| $$  /$$/
# | $$  \ $$| $$      | $$   | $$| $$  \ $$| $$  \ $$| $$  \__/| $$  | $$  | $$  | $$         | $$         | $$  \__/   | $$  | $$  \ $$| $$  \__/| $$ /$$/ 
# | $$  | $$| $$$$$   |  $$ / $$/| $$  | $$| $$$$$$$/|  $$$$$$ | $$$$$$$$  | $$  | $$$$$      | $$         |  $$$$$$    | $$  | $$$$$$$$| $$      | $$$$$/  
# | $$  | $$| $$__/    \  $$ $$/ | $$  | $$| $$____/  \____  $$| $$__  $$  | $$  | $$__/      | $$          \____  $$   | $$  | $$__  $$| $$      | $$  $$  
# | $$  | $$| $$        \  $$$/  | $$  | $$| $$       /$$  \ $$| $$  | $$  | $$  | $$         | $$          /$$  \ $$   | $$  | $$  | $$| $$    $$| $$\  $$ 
# | $$$$$$$/| $$$$$$$$   \  $/   |  $$$$$$/| $$      |  $$$$$$/| $$  | $$ /$$$$$$| $$         | $$         |  $$$$$$/   | $$  | $$  | $$|  $$$$$$/| $$ \  $$
# |_______/ |________/    \_/     \______/ |__/       \______/ |__/  |__/|______/|__/         |__/          \______/    |__/  |__/  |__/ \______/ |__/  \__/
                                                                                                                                                          
echo -e "\n\n"
base64 -d <<<"IC8kJCQkJCQkICAvJCQkJCQkJCQgLyQkICAgIC8kJCAgLyQkJCQkJCAgLyQkJCQkJCQgICAvJCQkJCQkICAvJCQgICAvJCQgLyQkJCQkJCAvJCQkJCQkJCQgLyQkJCQkJCQkICAgICAgICAvJCQkJCQkICAvJCQkJCQkJCQgLyQkJCQkJCAgIC8kJCQkJCQgIC8kJCAgIC8kJAp8ICQkX18gICQkfCAkJF9fX19fL3wgJCQgICB8ICQkIC8kJF9fICAkJHwgJCRfXyAgJCQgLyQkX18gICQkfCAkJCAgfCAkJHxfICAkJF8vfCAkJF9fX19fL3xfXyAgJCRfXy8gICAgICAgLyQkX18gICQkfF9fICAkJF9fLy8kJF9fICAkJCAvJCRfXyAgJCR8ICQkICAvJCQvCnwgJCQgIFwgJCR8ICQkICAgICAgfCAkJCAgIHwgJCR8ICQkICBcICQkfCAkJCAgXCAkJHwgJCQgIFxfXy98ICQkICB8ICQkICB8ICQkICB8ICQkICAgICAgICAgfCAkJCAgICAgICAgIHwgJCQgIFxfXy8gICB8ICQkICB8ICQkICBcICQkfCAkJCAgXF9fL3wgJCQgLyQkLyAKfCAkJCAgfCAkJHwgJCQkJCQgICB8ICAkJCAvICQkL3wgJCQgIHwgJCR8ICQkJCQkJCQvfCAgJCQkJCQkIHwgJCQkJCQkJCQgIHwgJCQgIHwgJCQkJCQgICAgICB8ICQkICAgICAgICAgfCAgJCQkJCQkICAgIHwgJCQgIHwgJCQkJCQkJCR8ICQkICAgICAgfCAkJCQkJC8gIAp8ICQkICB8ICQkfCAkJF9fLyAgICBcICAkJCAkJC8gfCAkJCAgfCAkJHwgJCRfX19fLyAgXF9fX18gICQkfCAkJF9fICAkJCAgfCAkJCAgfCAkJF9fLyAgICAgIHwgJCQgICAgICAgICAgXF9fX18gICQkICAgfCAkJCAgfCAkJF9fICAkJHwgJCQgICAgICB8ICQkICAkJCAgCnwgJCQgIHwgJCR8ICQkICAgICAgICBcICAkJCQvICB8ICQkICB8ICQkfCAkJCAgICAgICAvJCQgIFwgJCR8ICQkICB8ICQkICB8ICQkICB8ICQkICAgICAgICAgfCAkJCAgICAgICAgICAvJCQgIFwgJCQgICB8ICQkICB8ICQkICB8ICQkfCAkJCAgICAkJHwgJCRcICAkJCAKfCAkJCQkJCQkL3wgJCQkJCQkJCQgICBcICAkLyAgIHwgICQkJCQkJC98ICQkICAgICAgfCAgJCQkJCQkL3wgJCQgIHwgJCQgLyQkJCQkJHwgJCQgICAgICAgICB8ICQkICAgICAgICAgfCAgJCQkJCQkLyAgIHwgJCQgIHwgJCQgIHwgJCR8ICAkJCQkJCQvfCAkJCBcICAkJAp8X19fX19fXy8gfF9fX19fX19fLyAgICBcXy8gICAgIFxfX19fX18vIHxfXy8gICAgICAgXF9fX19fXy8gfF9fLyAgfF9fL3xfX19fX18vfF9fLyAgICAgICAgIHxfXy8gICAgICAgICAgXF9fX19fXy8gICAgfF9fLyAgfF9fLyAgfF9fLyBcX19fX19fLyB8X18vICBcX18vCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg"
echo -e "\n\n"                                                                                                                                                          

}

function init_process() {
    welcome
    validate_command $CLI 
    create_qexchange $@
}

function create_qexchange() {
    echo -e "Creating new QUEUE And Exchance binding"
    echo -e "If creation fails - make sure rmq pods are up and then run - ./install-cluster.sh create_qexchange"
    a=("$@")
    ((last_idx=${#a[@]} - 1))
    b=${a[last_idx]}
    unset a[last_idx]

    for i in "${a[@]}" ; do
        echo -e "creating queue and exchange"
        create_rmqqexchange $i
        echo -e "Creating kafka connector"
        create_connector $argument
    done

}

function create_rmqqexchange(){
    argument=("$1")
    echo "THE exchange and queue to create: $argument"
    ./rabbitmqadmin -u guest -p guest --host localhost --port 8080 --path-prefix /rmq  -V / declare exchange name=$argument.exchange type=direct 2>&1 || { echo >&2 "failed to create RMQ exchange."; exit 1; }
    ./rabbitmqadmin -u guest -p guest --host localhost --port 8080 --path-prefix /rmq  -V / declare queue name=$argument.queue 2>&1 || { echo >&2 "failed to create RMQ queue."; exit 1; }
    ./rabbitmqadmin -u guest -p guest --host localhost --port 8080 --path-prefix /rmq  -V / declare binding source=$argument.exchange destination=$argument.queue 2>&1 || { echo >&2 "failed to create RMQ binding."; exit 1; }

    
}




function create_connector() {
argument=("$1")
echo "\n Creating Kafka connector and topic: $argument\n"
sleep 3 

curl -X PUT \
  localhost:8000/api/kafka-connect-1/connectors/RabbitMQSinkConnector/config \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -d '{
  "name": "RabbitMQSinkConnector",
  "connector.class": "com.datamountaineer.streamreactor.connect.rabbitmq.sink.RabbitMQSinkConnector",
  "connect.rabbitmq.password": "guest",
  "errors.log.include.messages": " true",
  "connect.rabbitmq.port": "5672",
  "connect.rabbitmq.username": "guest",
  "topics": "'$argument'",
  "tasks.max": "1",
  "errors.deadletterqueue.context.headers.enable": "true",
  "value.errors.log.enable": "true",
  "connect.rabbitmq.kcql": "INSERT INTO '$argument'.exchange SELECT * FROM '$argument' WITHTYPE '$argument'",
  "connect.rabbitmq.use.tls": "false",
  "errors.deadletterqueue.topic.name": "deadletter",
  "connect.rabbitmq.host": "rmq-rabbitmq-ha",
  "value.converter.schemas.enable": "false",
  "errors.tolerance": "all",
  "errors.deadletterqueue.topic.replication.factor": "1",
  "value.converter": "org.apache.kafka.connect.json.JsonConverter",
  "key.converter": "org.apache.kafka.connect.json.JsonConverter"
}' 2>&1 || { echo >&2 "failed to create KAFKA CONNECTOR."; exit 1; }
}


# STARTING CASE
function case_script {
case "$1" in
        install-kind)
            echo installing kind
            ;;
        create-cluster)
            echo creating new cluster and ingress on cluster named $2
            CLUSTER_NAME=$2
            create_cluster $CLUSTER_NAME
            ;;
        install-all)
            echo installing all packages on local cluster 
            install_ingress
            install-prometheus
            install_es
            install_kafka
            install_rmq
            ;;
        install-ingress)
            echo installing ambassador
            install_ingress
            ;;                     
        install-prometheus)
            echo installing install-prometheus on local cluster 
            install_prometheus
            ;;                     
        install-elastic)
            echo installing elasticsearch on local cluster 
            install_es
            ;;         
        install-kafka)
            echo installing kafka on local cluster 
            echo please make sure you write - install-kafka [k8s kind cluster name]
            CLUSTER_NAME=$2
            echo "Installing on cluster $CLUSTER_NAME" 
            install_kafka 
            ;;                     
        install-rmq)
            echo installing rmq on local cluster 
            install_rmq
            ;;        
        create_qexchange)
            echo installing exchnage on local cluster 
            create_qexchange
            ;;        

                         
        delete-cluster)
            echo deleting cluster named $2
            CLUSTER_NAME=$2
            delete_cluster $CLUSTER_NAME
            ;;
        restart)
            stop
            start
            ;;
        condrestart)
            if test "x`pidof anacron`" != x; then
                stop
                start
            fi
            ;;
         
        *)
            echo $"Usage: $0 {install-kind|create-cluster [NAME]|install-ingress|install-prometheus|install-elastic|install-kafka|install-rmq|install-all|create_qexchange}"
            exit 1
 
esac
}



init_process $@


