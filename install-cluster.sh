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
sleep 3

}

function init_process {
    welcome
    validate_command $CLI 
    case_script $@
}
function init_process_expose {
    if [ -z $CLUSTER_NAME ]; then
        echo -e "\nPlease add Cluster name as an argument\n"
        exit 0
    fi
}

function validate_command {
    echo "checking CLI requirments"
    declare -a cli_missing=()
    for cli in "${CLI[@]}"
    do 
        command -v "$cli" >/dev/null 2>&1 || { echo >&2 ; cli_missing+=($cli); }                
    done
    # Check if array object count is bigger then 0 and if so exit
    len=${#cli_missing[@]}
    if [ $len \> 0 ]; then 
    echo "The following CLI are missing in your system. Please install them: ${cli_missing[@]} - Aborting"
    exit 44
    fi

    # Checking helm version (Need to be at least V3)
    HELMVEVRSION=$(helm version)
    [[ $HELMVEVRSION == *v3* ]] >/dev/null 2>&1 || { echo >&2 "Please install HELM Version 3. Aborting."; exit 1; }
    echo "Required CLI validated"
}

function create_cluster {
               echo "Creating kind cluster $1"
               # Check if kind exists
               command -v kind >/dev/null 2>&1 || { echo >&2 "I require kind but it's not installed. Please use install-kind flag. Aborting."; exit 1; }
               # Create KIND CLUSTER & Check if CLUSTER exists
               check_cluster $CLUSTER_NAME

               # Check if kubectl works
               echo -e "\nListing K8S NODES Please wait...\n"
               sleep 40
               kubectl get nodes 2>&1 || { echo >&2 "Unable to run kubectl - Aborting."; exit 1; }
               #echo -e "\nInstalling ingress\n"
               #install_ingress
               #echo -e "\ninstall_prometheus\n"
               #install_prometheus
               echo -e "\nCLUSTER READY\n"
           }

#TODO: Finish PROMETHEUS INSTALLATION
function install_prometheus {
    echo -e "\nInstalling prometheus\n"
    echo -e "\nCreating Namespace for Monitoring\n"
    kubectl create namespace monitoring 2>&1 || { echo >&2 "Failed to install prometheus - Aborting."; exit 1; }
    echo -e "\nInstalling prometheus operator\n"
    helm install prometheus ./helm/prometheus-operator 2>&1 || { echo >&2 "Failed to install RMQ"; exit 1; }
    echo -e "\nWaiting for prometheus packages to be deployed (up to 4 minutes)\n"
    kubectl wait --for=condition=Ready pods -l "release=prometheus" --timeout 4m 2>&1 || { echo >&2 "Failed to install prometheus - Aborting.\n1. kubectl wait --for=condition=Ready pods -l "release=prometheus" --timeout 4m \n2."; exit 1; }
    echo -e "\nPrometheus deployed and working \n"
}


function install_ingress {
    echo -e "\nInstalling ingress\n"
    echo -e "\nCreating Namespace for Ambassador\n"
    kubectl create namespace ambassador 2>&1 || { echo >&2 "Failed to install ingress - Aborting. Please read ingress readme file in it's folder"; exit 1; }
    echo -e "\nInstalling ingress\n"
    helm install ambassador --namespace ambassador ./helm/ambassador 2>&1 || { echo >&2 "Failed to install ingress - Aborting. Please read ingress readme file in it's folder"; exit 1; }
    echo -e "\nWaiting for ingress packages to be deployed (up to 4 minutes)\n"
    kubectl wait --for=condition=Ready pods --all -n ambassador --timeout 4m 2>&1 || { echo >&2 "Failed to install ingress - Aborting.\n1.Please rerun kubectl wait --for=condition=Ready pods --all -n ambassador \n2."; exit 1; }
    echo -e "\nIngress deployed and working \n"
}

function install_rmq {
    init_process_expose
    echo -e "Making sure kafka is installed"
    helm status kafka-cluster 2>&1 || { echo >&2 "Kafka Cluster not installed - Installing."; install_kafka; }
    echo -e "\nInstalling RMQ\n"
    helm install rmq  ./helm/kafka/04-rabbitmq-ha/ 2>&1 || { echo >&2 "Failed to install RMQ"; exit 1; }
    echo -e "\nWaiting for RMQ packages to be deployed (up to 4 minutes)\n"
    kubectl wait --for=condition=Ready pods -l "app=rabbitmq-ha"  --timeout 4m 2>&1 || { echo >&2 "Failed to install RMQ - Aborting.\n1.Please rerun kubectl wait --for=condition=Ready pods -l "app=rabbitmq-ha"  --timeout 4m \n2."; exit 1; }
    echo -e "\nRMQ deployed and working \n"
    echo -e "\nRMQ USER/PASS credentials \n"
    GUESTPASS=$(kubectl get secret --namespace default rmq-rabbitmq-ha -o jsonpath="{.data.rabbitmq-password}" | base64 --decode)
    MNGPASS=$(kubectl get secret --namespace default rmq-rabbitmq-ha -o jsonpath="{.data.rabbitmq-management-password}" | base64 --decode)
    echo -e "Please save the following RMQ credentials
    Username: guest
    Password: $GUESTPASS
    Management username : management
    Management password : $MNGPASS
    "
    echo -e "\nExposing RMQ for  cluster: $1 as \n"
    
    expose_port 32025 2>&1 || { echo >&2 "Failed to expose RMQ - check ports avilable on localhost - Aborting."; exit 1; }
    echo -e "\nExposing RMQ BROKERS as \n 
    localhost:32025 - RMQ ADMIN"



    create_qexchange
}

function create_qexchange {
    echo -e "Creating new QUEUE And Exchance binding"
    echo -e "If creation fails - make sure rmq pods are up and then run - ./install-cluster.sh create_qexchange ./"
    ./rabbitmqadmin -u guest -p guest --host localhost --port 32025 -V / declare exchange name=test.exchange type=direct 2>&1 || { echo >&2 "failed to create RMQ exchange."; exit 1; }
    ./rabbitmqadmin -u guest -p guest --host localhost --port 32025  -V / declare queue name=test.queue 2>&1 || { echo >&2 "failed to create RMQ queue."; exit 1; }
    ./rabbitmqadmin -u guest -p guest --host localhost --port 32025   -V / declare binding source=test.exchange destination=test.queue 2>&1 || { echo >&2 "failed to create RMQ binding."; exit 1; }

    echo -e "Creating kafka connector"
    create_connector
}


function create_connector {
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
  "topics": "topic",
  "tasks.max": "1",
  "errors.deadletterqueue.context.headers.enable": "true",
  "value.errors.log.enable": "true",
  "connect.rabbitmq.kcql": "INSERT INTO test.exchange SELECT * FROM topic WITHTYPE topic",
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

function install_es {
    init_process_expose

    echo -e "\nInstalling ELASTICSEARCH \n"
    echo -e "\nInstalling CRD's \n"
    kubectl create -f ./helm/eck/customresources/all-in-one.yaml 
    echo -e "\nInstalling ELASTICSEARCH Operator\n"
    helm install eck ./helm/eck/ 2>&1 || { echo >&2 "Failed to install ELASTIC - Aborting"; exit 1; }
    echo -e "\nWaiting for ELASTICSEARCH packages to be deployed (up to 7 minutes)\n"
    sleep 45
    kubectl wait --for=condition=Ready pods -l "common.k8s.elastic.co/type=elasticsearch"  --timeout 7m 2>&1 || { echo >&2 "Failed to install elasticsearch - Aborting.\n"; exit 1; }
    kubectl wait --for=condition=Ready pods -l "common.k8s.elastic.co/type=kibana"  --timeout 7m 2>&1 || { echo >&2 "Failed to install KIBANA - Aborting."; exit 1; }
    echo -e "\nECK deployed and working \n"
    
    GUESTPASS=$(kubectl get secret quickstart-es-elastic-user -n default -o=jsonpath='{.data.elastic}' | base64 --decode)
    echo -e "Please save the following ECK credentials to be used with KIBANA 
    Username: elastic
    Password: $GUESTPASS
    "
    echo -e "\nExposing Kibana for  cluster: $1 as \n"
    
    expose_port 31111 2>&1 || { echo >&2 "Failed to expose Kibana - check ports avilable on localhost - Aborting."; exit 1; }
    echo -e "\n\nTo Access Kibana and ES please browse:
    KIBANA: http://localhost:31111
    Username: elastic
    Password: $GUESTPASS
    " 



}


function install_kafka {
    init_process_expose
    echo -e "\nInstalling KAFKA Operators\n"
    helm install kafka ./helm/kafka/01-operators/ 2>&1 || { echo >&2 "Failed to install Kafka Operators - Aborting"; exit 1; }
    echo -e "\nWaiting for KAFKA operator to be deployed (up to 4 minutes)\n"
    kubectl wait --for=condition=Ready pods -l "name=strimzi-cluster-operator" --timeout 4m 2>&1 || { echo >&2 "Failed to install  strimzi-cluster-operator - please check pods and rerun kafka install"; exit 1; }
    echo -e "\nInstalling KAFKA Cluster\n"
    helm install kafka-cluster ./helm/kafka/02-clusters/ 2>&1 || { echo >&2 "Failed to install Kafka Cluster - Aborting"; exit 1; }
    echo -e "\nWaiting for KAFKA zookeeper to be deployed (up to 4 minutes)\n"
    sleep 15
    kubectl wait --for=condition=Ready pods -l "strimzi.io/name=kafka-cluster-zookeeper" --timeout 4m  2>&1 || { echo >&2 "Failed to install  kafka-cluster-zookeeper - please check pods and rerun kafka install"; exit 1; }
    echo -e "\nWaiting for KAFKA cluster to be deployed (up to 4 minutes)\n"
    kubectl wait --for=condition=Ready pods -l "strimzi.io/name=kafka-cluster-kafka" --timeout 4m 2>&1 || { echo >&2 "Failed to install  kafka-cluster-kafka - please check pods and rerun kafka install"; exit 1; } 
        echo -e "\nWaiting for kafka-cluster-entity-operator to be deployed (up to 4 minutes)\n"
    kubectl wait --for=condition=Ready pods -l "strimzi.io/name=kafka-cluster-entity-operator" --timeout 4m 2>&1 || { echo >&2 "Failed to install  kafka-cluster-entity-operator - please check pods and rerun kafka install"; exit 1; }
    echo -e "\nInstalling KAFKA Registry\n"
    helm install kafka-registry --set kafka.bootstrapServers="PLAINTEXT://kafka-cluster-kafka-bootstrap:9092" ./helm/kafka/03-connectNregistry/kafka-registry  2>&1 || { echo >&2 "Failed to install Kafka registry - please check pods and rerun kafka install"; exit 1; }
    echo -e "\nWaiting for KAFKA Registry to be deployed (up to 4 minutes)\n"
    kubectl wait --for=condition=Ready pods -l "release=kafka-registry" --timeout 4m 2>&1 || { echo >&2 "Failed to install kafka-registry - please check pods and rerun kafka install"; exit 1; }
    echo -e "\nInstalling KAFKA Connect\n"
    helm install kafka-connect --set kafka.bootstrapServers="PLAINTEXT://kafka-cluster-kafka-bootstrap:9092",cp-schema-registry.url="kafkaregistry-cp-schema-registry:8081" ./helm/kafka/03-connectNregistry/kafka-connect 2>&1 || { echo >&2 "Failed to install Kafka connect - please check pods and rerun kafka install"; exit 1; }
    echo -e "\nWaiting for KAFKA Connect to be deployed (up to 4 minutes)\n"
    kubectl wait --for=condition=Ready pods -l "release=kafka-connect" --timeout 4m 2>&1 || { echo >&2 "Failed to install kafka-connect - please check pods and rerun kafka install"; exit 1; }

    echo -e "\nExposing KAKFA BROKERS for server $1 as \n"
    expose_port 32200 2>&1 || { echo >&2 "Failed to expose broker - check ports avilable on localhost"; exit 1; }
    echo "starting two"
    expose_port 30825 2>&1 || { echo >&2 "Failed to expose zookeeper - check ports avilable on localhost - Aborting."; exit 1; }
    echo -e "\nExposing KAKFA BROKERS as \n 
    localhost:32200 - Kafka broker
    localhost:30825 - kafka zookeeper"

    echo -e "\nKAKFKA deployed and working \n"
}


# function configure_connector {
#     #TODO: Auto Configure Connector for kafka
# }

function check_cluster {
    kind get nodes --name $CLUSTER_NAME
    if kubectl get nodes > /dev/null 2>&1 ; then
        echo "Cluster already created - switching context"
        return 0
    else
        kind create cluster --name $CLUSTER_NAME --wait 4m --config kind_values.yaml  2>&1 || { echo >&2 "Kind Cluster creation failed - Aborting."; exit 1; }
        echo "Configuring KUBECONFIG"
        export KUBECONFIG="$(kind get kubeconfig-path --name=$CLUSTER_NAME)" 2>&1 || { echo >&2 "Configuring KUBECONFIG FAILED. Please run it manualy - Aborting."; exit 1; }
        return 0
    fi

}
function expose_port {
    #Check if container forward already exposed
# if docker container inspect proxy-$CLUSTER_NAME-${port} > /dev/null 2>&1 ; then
#     echo proxy-$CLUSTER_NAME-${port}
#     echo -e "\nExpose already exists - Skipping step\n"
    
# else
    for port in $1
do            
    echo -e "\n killing old expose containers connections and rebuilding"
    docker kill proxy-$CLUSTER_NAME-${port} > /dev/null 2>&1 

    node_port=$1

    docker run --rm -d --name proxy-$CLUSTER_NAME-${port} \
      --publish 127.0.0.1:${port}:${port} \
      --link $CLUSTER_NAME-worker:target \
      alpine/socat -dd \
      tcp-listen:${port},fork,reuseaddr tcp-connect:target:${node_port}
done
#   
}



function delete_cluster {
    echo "checking CLI requirments"
    for cli in "$@"
    do 
        command -v $cli >/dev/null 2>&1 || { echo >&2 "I require $1 but it's not installed. Please install it first. Aborting."; exit 1; }                
    done

    
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
            echo please make sure you write - install-elastic [k8s kind cluster name]
            CLUSTER_NAME=$2
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
            echo please make sure you write - install-rmq [k8s kind cluster name]
            CLUSTER_NAME=$2
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


