#!/bin/bash

#############################################################################
# Kafka Deployment Script for Kubernetes
# This script deploys Apache Kafka with Strimzi operator on Kubernetes
#############################################################################

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
KAFKA_NAMESPACE="kafka"
STRIMZI_VERSION="0.37.0"
KAFKA_CHART="strimzi/strimzi-kafka-operator"
KUBERNETES_CONFIG_PATH="${KUBECONFIG:-$HOME/.kube/config}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to check command existence
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."

    if ! command_exists kubectl; then
        print_error "kubectl is not installed. Please install kubectl first."
        exit 1
    fi
    print_success "kubectl is installed"

    if ! command_exists helm; then
        print_error "helm is not installed. Please install helm first."
        exit 1
    fi
    print_success "helm is installed"

    # Check Kubernetes cluster connectivity
    if ! kubectl cluster-info >/dev/null 2>&1; then
        print_error "Unable to connect to Kubernetes cluster. Please check your kubeconfig."
        exit 1
    fi
    print_success "Connected to Kubernetes cluster"
}

# Function to add Helm repository
add_helm_repo() {
    print_info "Adding Strimzi Helm repository..."

    if helm repo list | grep -q "strimzi"; then
        print_info "Strimzi repo already exists, updating..."
        helm repo update strimzi || print_warning "Failed to update strimzi repo"
    else
        helm repo add strimzi https://strimzi.io/charts
        helm repo update strimzi
    fi

    print_success "Helm repository configured"
}

# Function to create namespace
create_namespace() {
    print_info "Creating Kafka namespace..."

    if kubectl get namespace "$KAFKA_NAMESPACE" >/dev/null 2>&1; then
        print_warning "Namespace '$KAFKA_NAMESPACE' already exists"
    else
        kubectl apply -f "$PROJECT_ROOT/iac/kubernetes/kafka/namespace.yaml"
        print_success "Namespace '$KAFKA_NAMESPACE' created"
    fi
}

# Function to install Strimzi operator
install_strimzi_operator() {
    print_info "Installing Strimzi Kafka Operator (version $STRIMZI_VERSION)..."

    # Check if the operator is already installed
    if helm list -n "$KAFKA_NAMESPACE" | grep -q "strimzi-kafka-operator"; then
        print_warning "Strimzi operator already installed. Skipping installation."
        return 0
    fi

    helm install strimzi-kafka-operator "$KAFKA_CHART" \
        --namespace "$KAFKA_NAMESPACE" \
        --version "$STRIMZI_VERSION" \
        --set replicas=1 \
        --wait \
        --timeout 5m

    print_success "Strimzi operator installed successfully"
}

# Function to wait for Strimzi operator to be ready
wait_for_operator() {
    print_info "Waiting for Strimzi operator to be ready..."

    kubectl rollout status deployment/strimzi-cluster-operator \
        -n "$KAFKA_NAMESPACE" \
        --timeout=5m

    print_success "Strimzi operator is ready"
}

# Function to deploy Kafka cluster
deploy_kafka_cluster() {
    print_info "Deploying Kafka cluster..."

    if kubectl get kafka -n "$KAFKA_NAMESPACE" | grep -q "banking-kafka"; then
        print_warning "Kafka cluster 'banking-kafka' already exists"
    else
        kubectl apply -f "$PROJECT_ROOT/iac/kubernetes/kafka/../../../iac/helm/kafka/kafka-cluster.yaml"
        print_success "Kafka cluster configuration applied"
    fi

    print_info "Waiting for Kafka cluster to be ready (this may take 2-3 minutes)..."
    kubectl wait kafka/banking-kafka -n "$KAFKA_NAMESPACE" --for=condition=Ready --timeout=10m || {
        print_warning "Kafka cluster may still be initializing. Check status with: kubectl get kafka -n kafka"
    }
}

# Function to deploy Kafka topics
deploy_kafka_topics() {
    print_info "Deploying Kafka topics..."

    kubectl apply -f "$PROJECT_ROOT/iac/kubernetes/kafka/topic.yaml"
    print_success "Kafka topics configured"
}

# Function to verify deployment
verify_deployment() {
    print_info "Verifying Kafka deployment..."
    echo ""

    print_info "Strimzi Operator Status:"
    kubectl get deployment -n "$KAFKA_NAMESPACE"
    echo ""

    print_info "Kafka Cluster Status:"
    kubectl get kafka -n "$KAFKA_NAMESPACE"
    echo ""

    print_info "Kafka Pods:"
    kubectl get pods -n "$KAFKA_NAMESPACE"
    echo ""

    print_info "Kafka Topics:"
    kubectl get kafkatopic -n "$KAFKA_NAMESPACE"
    echo ""
}

# Function to display access information
display_access_info() {
    print_info "Kafka Deployment Information:"
    echo ""
    echo -e "${BLUE}Bootstrap Server (inside cluster):${NC} banking-kafka-kafka-bootstrap.kafka.svc.cluster.local:9092"
    echo -e "${BLUE}Bootstrap Server (port-forward):${NC} localhost:9092"
    echo ""
    echo "To access Kafka from your machine:"
    echo "  kubectl port-forward -n kafka svc/banking-kafka-kafka-bootstrap 9092:9092"
    echo ""
    echo "To access Kafka CLI:"
    echo "  kubectl exec -it banking-kafka-kafka-0 -n kafka -- bash"
    echo ""
    echo "To view Kafka logs:"
    echo "  kubectl logs -n kafka -l app.kubernetes.io/name=kafka -f"
    echo ""
}

# Function to cleanup (optional)
cleanup() {
    print_warning "Cleanup function - use with caution!"
    read -p "Are you sure you want to delete Kafka deployment? (yes/no): " confirm

    if [ "$confirm" = "yes" ]; then
        print_info "Deleting Kafka resources..."
        kubectl delete -f "$PROJECT_ROOT/iac/kubernetes/kafka/" -n "$KAFKA_NAMESPACE"
        print_success "Kafka resources deleted"
    else
        print_info "Cleanup cancelled"
    fi
}

# Main execution
main() {
    echo -e "${BLUE}======================================${NC}"
    echo -e "${BLUE}   Kafka Kubernetes Deployment${NC}"
    echo -e "${BLUE}======================================${NC}"
    echo ""

    # Check if cleanup is requested
    if [ "${1:-}" = "cleanup" ]; then
        cleanup
        exit 0
    fi

    # Execute deployment steps
    check_prerequisites
    add_helm_repo
    create_namespace
    install_strimzi_operator
    wait_for_operator
    deploy_kafka_cluster
    deploy_kafka_topics
    verify_deployment
    display_access_info

    print_success "Kafka deployment completed successfully!"
    echo ""
}

# Run main function
main "$@"
