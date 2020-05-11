#!/bin/bash
# This will install k8s kind and ARGO CD

# Validate all cli tools are installed - PLEASE ADD CLI REQUIRED
declare -a CLI=("kubectl" "kind" "helm")
#export REGISTRY_IP=192.168.86.73 # Change to the IP where NEXUS is installed
#export REGISTRY_HOSTNAME=registry.emei # change to the name of the host name
export CLUSTER_NAME=localdev # change to the name of your cluster

function init_process {
    validate_command $CLI 
    case_script $@
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
               echo -e "\nInstalling ingress\n"
               install_ingress
               echo -e "\ninstall_prometheus\n"
               install_prometheus
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
}


function install_es {
    echo -e "\nInstalling ELASTICSEARCH \n"
    helm install eck ./helm/eck/ 2>&1 || { echo >&2 "Failed to install ELASTIC - Aborting"; exit 1; }
    echo -e "\nWaiting for ELASTICSEARCH packages to be deployed (up to 4 minutes)\n"
    kubectl wait --for=condition=Ready pods -l "common.k8s.elastic.co/type=elasticsearch"  --timeout 4m 2>&1 || { echo >&2 "Failed to install elasticsearch - Aborting.\n"; exit 1; }
    kubectl wait --for=condition=Ready pods -l "common.k8s.elastic.co/type=kibana"  --timeout 4m 2>&1 || { echo >&2 "Failed to install KIBANA - Aborting."; exit 1; }
    echo -e "\nECK deployed and working \n"
    
    GUESTPASS=$(kubectl get secret quickstart-es-elastic-user -n default -o=jsonpath='{.data.elastic}' | base64 --decode)
    echo -e "Please save the following ECK credentials to be used with KIBANA 
    Username: elastic
    Password: $GUESTPASS
    "
    echo -e "To Access Kibana and ES please browse:
    KIBANA: http://localhost:8081/kibana/
    ELASTIC: http://localhost:8081/elastic/
    Password: $GUESTPASS
    " 
  

}


function install_kafka {
    echo -e "\nInstalling KAFKA\n"
   for file in ../packages/kafka/*
    do
          echo -e "Applying $file"
          kubectl apply -f "$file" --wait
          echo -e "\nwaiting for pods to start (up to 5 minutes for each file)\n"
          kubectl wait --for=condition=Ready pods --all -n default --timeout 5m | grep -v quickstart 2>&1 || 2>&1 || { echo >&2 "Failed to install kafka - Aborting. Please read kafka readme file in it's folder"; exit 1; }
    done
    echo -e "\nKafka Deployed\n"
}
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
if docker container inspect kind-proxy-$1 > /dev/null 2>&1 ; then
    echo port already exposed - Opening browser
else
    for port in $1
do                
    node_port=$1

    docker run --rm -d --name porxy-$CLUSTER_NAME-${port} \
      --publish 127.0.0.1:${port}:${port} \
      --link $CLUSTER_NAME-worker:target \
      alpine/socat -dd \
      tcp-listen:${port},fork,reuseaddr tcp-connect:target:${node_port}
done
fi
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
            install_kafka
            ;;                     
        install-rmq)
            echo installing rmq on local cluster 
            install_rmq
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
            echo $"Usage: $0 {install-kind|create-cluster [NAME]|install-elastic|install-kafka}"
            exit 1
 
esac
}



init_process $@


