# Kafka Deployment Guide

This folder contains deployment scripts for installing and managing Kafka on Kubernetes.

## Prerequisites

Before running the deployment script, ensure you have:

1. **kubectl** - Kubernetes command-line tool
   ```bash
   # Install kubectl
   curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
   chmod +x kubectl
   sudo mv kubectl /usr/local/bin/
   ```

2. **helm** - Kubernetes package manager
   ```bash
   # Install helm
   curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
   ```

3. **Kubernetes Cluster** - A running K8s cluster (EKS, AKS, GKE, etc.)
   ```bash
   # Verify cluster access
   kubectl cluster-info
   ```

4. **kubeconfig** - Properly configured kubeconfig file pointing to your cluster
   ```bash
   # Verify kubeconfig
   cat ~/.kube/config
   ```

## Deployment Steps

### 1. Deploy Kafka

Run the main deployment script:

```bash
./deploy-kafka.sh
```

This script will:
- ✅ Check prerequisites (kubectl, helm, cluster connectivity)
- ✅ Add Strimzi Helm repository
- ✅ Create `kafka` namespace
- ✅ Install Strimzi Kafka Operator v0.37.0
- ✅ Deploy Kafka cluster with 3 brokers and replicas
- ✅ Deploy Kafka topics
- ✅ Verify deployment and show access information

### 2. Monitor Deployment Progress

```bash
# Watch operator deployment
kubectl rollout status deployment/strimzi-cluster-operator -n kafka

# Watch Kafka cluster formation
kubectl get kafka -n kafka -w

# View all Kafka pods
kubectl get pods -n kafka -w
```

### 3. Access Kafka

#### From within the cluster:
```bash
# Bootstrap server address
banking-kafka-kafka-bootstrap.kafka.svc.cluster.local:9092
```

#### From your local machine (port-forward):
```bash
# In one terminal
kubectl port-forward -n kafka svc/banking-kafka-kafka-bootstrap 9092:9092

# In another terminal, you can now connect to localhost:9092
```

#### Using Kafka CLI tools:
```bash
# List topics
kubectl exec -it banking-kafka-kafka-0 -n kafka -- kafka-topics.sh --list --bootstrap-server banking-kafka-kafka-bootstrap:9092

# Create a test topic
kubectl exec -it banking-kafka-kafka-0 -n kafka -- kafka-topics.sh \
  --create \
  --topic test-topic \
  --bootstrap-server banking-kafka-kafka-bootstrap:9092 \
  --partitions 3 \
  --replication-factor 3

# Produce messages
kubectl exec -it banking-kafka-kafka-0 -n kafka -- kafka-console-producer.sh \
  --topic test-topic \
  --bootstrap-server banking-kafka-kafka-bootstrap:9092

# Consume messages
kubectl exec -it banking-kafka-kafka-0 -n kafka -- kafka-console-consumer.sh \
  --topic test-topic \
  --bootstrap-server banking-kafka-kafka-bootstrap:9092 \
  --from-beginning
```

## Configuration

The deployment uses the following configurations from the IaC folder:

### Kafka Cluster (`../iac/helm/kafka/kafka-cluster.yaml`)
- **Version**: 3.6.0
- **Replicas**: 3 brokers
- **Storage**: Persistent volumes (20GB per broker, 10GB for ZooKeeper)
- **Listener**: Plain text on port 9092

### Kafka Topics (`../iac/kubernetes/kafka/topic.yaml`)
- **Topic**: banking-transactions
- **Partitions**: 6
- **Replication Factor**: 3

### Namespace (`../iac/kubernetes/kafka/namespace.yaml`)
- **Name**: kafka

## Cleanup

To remove the Kafka deployment:

```bash
./deploy-kafka.sh cleanup
```

**Warning**: This will delete:
- Kafka cluster
- ZooKeeper
- Persistent volumes (data will be lost)
- Kafka namespace

## Troubleshooting

### Kafka cluster won't reach Ready state

Check operator logs:
```bash
kubectl logs -n kafka -l app.kubernetes.io/name=strimzi-kafka-operator -f
```

### Insufficient memory/resources

Kafka requires significant resources:
- Each Kafka broker: ~2GB RAM, 1 CPU (minimum)
- ZooKeeper pods: ~1GB RAM, 0.5 CPU (minimum)

Check node resources:
```bash
kubectl top nodes
kubectl describe nodes
```

### Persistent Volume issues

Check PV status:
```bash
kubectl get pv
kubectl get pvc -n kafka
```

Ensure your cluster has storage provisioners:
```bash
kubectl get storageclass
```

### Cannot connect to Kafka

Verify service:
```bash
kubectl get svc -n kafka
kubectl get endpoints -n kafka

# Test connectivity from a pod
kubectl run -it --image=ubuntu test-pod -- bash
apt-get update && apt-get install -y netcat
nc -zv banking-kafka-kafka-bootstrap.kafka.svc.cluster.local 9092
```

## Next Steps

After successful deployment:

1. **Integrate with Airflow**: Update your Airflow DAGs to use the Kafka broker address
2. **Create Additional Topics**: Use the KafkaTopic CRD to define more topics
3. **Set Up Monitoring**: Install Prometheus and Grafana for Kafka metrics
4. **Configure Security**: Add TLS, SASL authentication, and network policies
5. **Backup Strategy**: Set up regular backups of Kafka data

## Additional Resources

- [Strimzi Documentation](https://strimzi.io/docs/)
- [Kafka on Kubernetes Best Practices](https://strimzi.io/docs/operators/latest/deploying.html)
- [Kafka Architecture Overview](https://kafka.apache.org/documentation/#architecture)
