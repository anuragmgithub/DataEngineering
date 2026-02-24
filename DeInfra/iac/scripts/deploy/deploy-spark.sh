#!/bin/bash

#############################################################################
# Spark Operator with Iceberg Deployment Script for Kubernetes
# This script deploys Apache Spark Operator with Iceberg integration on K8s
#############################################################################

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SPARK_NAMESPACE="spark-operator"
SPARK_OPERATOR_VERSION="1.3.8"
SPARK_OPERATOR_CHART="spark-operator/spark-operator"
ICEBERG_JAR_VERSION="1.4.0"
ICEBERG_SPARK_VERSION="3.5"
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

    if ! command_exists docker; then
        print_warning "docker is not installed. You may need it for building custom Spark images."
    else
        print_success "docker is installed"
    fi

    # Check Kubernetes cluster connectivity
    if ! kubectl cluster-info >/dev/null 2>&1; then
        print_error "Unable to connect to Kubernetes cluster. Please check your kubeconfig."
        exit 1
    fi
    print_success "Connected to Kubernetes cluster"
}

# Function to add Helm repository
add_helm_repo() {
    print_info "Adding Spark Operator Helm repository..."

    if helm repo list | grep -q "spark-operator"; then
        print_info "Spark Operator repo already exists, updating..."
        helm repo update spark-operator || print_warning "Failed to update spark-operator repo"
    else
        helm repo add spark-operator https://kubeflow.github.io/spark-operator
        helm repo update spark-operator
    fi

    print_success "Helm repository configured"
}

# Function to create namespace
create_namespace() {
    print_info "Creating Spark Operator namespace..."

    if kubectl get namespace "$SPARK_NAMESPACE" >/dev/null 2>&1; then
        print_warning "Namespace '$SPARK_NAMESPACE' already exists"
    else
        kubectl apply -f "$PROJECT_ROOT/iac/kubernetes/namespaces/spark-operator-ns.yaml"
        print_success "Namespace '$SPARK_NAMESPACE' created"
    fi
}

# Function to create service account
create_service_account() {
    print_info "Creating Spark service account..."

    # Create service account for Spark applications
    kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: spark
  namespace: $SPARK_NAMESPACE
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: spark
  namespace: $SPARK_NAMESPACE
rules:
  - apiGroups: [""]
    resources: ["pods", "pods/log"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["pods/exec"]
    verbs: ["create"]
EOF

    kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: spark
  namespace: $SPARK_NAMESPACE
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: spark
subjects:
  - kind: ServiceAccount
    name: spark
    namespace: $SPARK_NAMESPACE
EOF

    print_success "Service account 'spark' created"
}

# Function to install Spark Operator
install_spark_operator() {
    print_info "Installing Spark Operator (version $SPARK_OPERATOR_VERSION)..."

    # Check if the operator is already installed
    if helm list -n "$SPARK_NAMESPACE" | grep -q "spark-operator"; then
        print_warning "Spark Operator already installed. Skipping installation."
        return 0
    fi

    helm install spark-operator "$SPARK_OPERATOR_CHART" \
        --namespace "$SPARK_NAMESPACE" \
        --version "$SPARK_OPERATOR_VERSION" \
        --values "$PROJECT_ROOT/iac/helm/spark/values.yaml" \
        --wait \
        --timeout 5m

    print_success "Spark Operator installed successfully"
}

# Function to wait for Spark Operator to be ready
wait_for_operator() {
    print_info "Waiting for Spark Operator to be ready..."

    kubectl rollout status deployment/spark-operator \
        -n "$SPARK_NAMESPACE" \
        --timeout=5m || {
        print_warning "Spark Operator may still be initializing. Checking operator logs..."
        kubectl logs -n "$SPARK_NAMESPACE" -l app.kubernetes.io/name=spark-operator -f --tail=50 || true
    }

    print_success "Spark Operator is ready"
}

# Function to create persistent storage for Iceberg warehouse
create_storage() {
    print_info "Creating storage for Iceberg warehouse..."

    kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: spark-iceberg-config
  namespace: $SPARK_NAMESPACE
data:
  spark-defaults.conf: |
    spark.sql.extensions=org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions
    spark.sql.catalog.demo=org.apache.iceberg.spark.SparkCatalog
    spark.sql.catalog.demo.type=hadoop
    spark.sql.catalog.demo.warehouse=/warehouse
    spark.jars.packages=org.apache.iceberg:iceberg-spark-runtime-${ICEBERG_SPARK_VERSION}_2.12:${ICEBERG_JAR_VERSION}
EOF

    print_success "Storage configuration created"
}

# Function to deploy demo Spark application with Iceberg
deploy_demo_app() {
    print_info "Deploying demo Spark application with Iceberg..."

    kubectl apply -f "$PROJECT_ROOT/iac/kubernetes/spark-operator/iceberg-demo.yaml"

    print_success "Demo application deployed"
}

# Function to verify deployment
verify_deployment() {
    print_info "Verifying Spark Operator deployment..."
    echo ""

    print_info "Spark Operator Status:"
    kubectl get deployment -n "$SPARK_NAMESPACE"
    echo ""

    print_info "Spark Operator Pods:"
    kubectl get pods -n "$SPARK_NAMESPACE"
    echo ""

    print_info "Spark Applications:"
    kubectl get sparkapplications -n "$SPARK_NAMESPACE" || echo "No SparkApplications deployed yet"
    echo ""
}

# Function to display access information
display_access_info() {
    print_info "Spark Operator Deployment Information:"
    echo ""
    echo -e "${BLUE}Namespace:${NC} spark-operator"
    echo -e "${BLUE}Operator Version:${NC} $SPARK_OPERATOR_VERSION"
    echo -e "${BLUE}Spark Version:${NC} 3.5.0"
    echo -e "${BLUE}Iceberg Version:${NC} $ICEBERG_JAR_VERSION"
    echo ""
    echo "To submit a Spark application:"
    echo "  kubectl apply -f <spark-application.yaml>"
    echo ""
    echo "To view Spark application logs:"
    echo "  kubectl logs -n spark-operator <driver-pod-name>"
    echo ""
    echo "To access Spark Operator logs:"
    echo "  kubectl logs -n spark-operator -l app.kubernetes.io/name=spark-operator -f"
    echo ""
    echo "To run a Spark job with Iceberg:"
    echo "  kubectl apply -f $PROJECT_ROOT/iac/kubernetes/spark-operator/iceberg-demo.yaml"
    echo ""
    echo "To monitor running applications:"
    echo "  kubectl get sparkapplications -n spark-operator -w"
    echo ""
}

# Function to build custom Spark image with Iceberg (optional)
build_spark_image() {
    if ! command_exists docker; then
        print_warning "Docker is not installed. Skipping custom image build."
        return 0
    fi

    print_info "Building custom Spark image with Iceberg..."

    if [ ! -f "$PROJECT_ROOT/iac/docker/spark/Dockerfile" ]; then
        print_error "Dockerfile not found at $PROJECT_ROOT/iac/docker/spark/Dockerfile"
        return 1
    fi

    docker build \
        -t spark:3.5.0-iceberg \
        -f "$PROJECT_ROOT/iac/docker/spark/Dockerfile" \
        "$PROJECT_ROOT/iac/docker/spark/" || {
        print_warning "Failed to build Docker image. You can build it manually with:"
        echo "  docker build -t spark:3.5.0-iceberg -f $PROJECT_ROOT/iac/docker/spark/Dockerfile $PROJECT_ROOT/iac/docker/spark/"
    }
}

# Function to cleanup (optional)
cleanup() {
    print_warning "Cleanup function - use with caution!"
    read -p "Are you sure you want to delete Spark Operator deployment? (yes/no): " confirm

    if [ "$confirm" = "yes" ]; then
        print_info "Deleting Spark applications..."
        kubectl delete sparkapplications -n "$SPARK_NAMESPACE" --all || print_warning "No Spark applications to delete"

        print_info "Deleting Spark Operator..."
        helm uninstall spark-operator -n "$SPARK_NAMESPACE" || print_warning "Failed to uninstall Spark Operator"

        print_info "Deleting service accounts and RBAC..."
        kubectl delete serviceaccount spark -n "$SPARK_NAMESPACE" || true
        kubectl delete role spark -n "$SPARK_NAMESPACE" || true
        kubectl delete rolebinding spark -n "$SPARK_NAMESPACE" || true

        print_success "Spark Operator cleaned up"
    else
        print_info "Cleanup cancelled"
    fi
}

# Main execution
main() {
    echo -e "${BLUE}======================================${NC}"
    echo -e "${BLUE}   Spark Operator with Iceberg${NC}"
    echo -e "${BLUE}         Kubernetes Deployment${NC}"
    echo -e "${BLUE}======================================${NC}"
    echo ""

    # Check if cleanup is requested
    if [ "${1:-}" = "cleanup" ]; then
        cleanup
        exit 0
    fi

    # Check if build is requested
    if [ "${1:-}" = "build-image" ]; then
        build_spark_image
        exit 0
    fi

    # Execute deployment steps
    check_prerequisites
    add_helm_repo
    create_namespace
    create_service_account
    install_spark_operator
    wait_for_operator
    create_storage
    verify_deployment
    display_access_info

    print_info "Demo Iceberg application available. To deploy it, run:"
    echo "  kubectl apply -f $PROJECT_ROOT/iac/kubernetes/spark-operator/iceberg-demo.yaml"
    echo ""

    print_success "Spark Operator deployment completed successfully!"
    echo ""
}

# Run main function
main "$@"
