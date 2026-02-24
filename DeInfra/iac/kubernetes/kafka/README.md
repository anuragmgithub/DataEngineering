# Data Engineering Infrastructure Deployment

This folder contains standardized deployment scripts for the data engineering infrastructure.

## Quick Start

### Prerequisites
- `kubectl` - Kubernetes CLI
- `helm` - Kubernetes package manager
- Access to a Kubernetes cluster (EKS, AKS, GKE, etc.)

### Available Deployments

#### 1. Kafka Deployment
Deploy Apache Kafka with Strimzi operator on Kubernetes.

```bash
./deploy-kafka.sh
```

**What it deploys:**
- Kafka cluster (3 brokers, 3 ZooKeepers)
- Persistent storage (20GB per broker)
- Kafka topics (banking-transactions)
- Strimzi Kafka Operator

**Time to ready:** ~3-5 minutes

**Documentation:** See `KAFKA_DEPLOYMENT_GUIDE.md`

---

## Infrastructure Components

### Current Status

| Component | Location | Status | Notes |
|-----------|----------|--------|-------|
| Kafka | `iac/kubernetes/kafka/` | ✅ Ready to deploy | Uses Strimzi operator |
| Kafka Helm | `iac/helm/kafka/` | ✅ Ready | Cluster configuration |
| Airflow Kubernetes | `iac/kubernetes/airflow/` | 📋 In progress | Needs helm chart setup |
| Airflow Helm | `iac/helm/airflow/` | ✅ Environment configs | dev/stage/prod values |

### Kubernetes Resources Deployed

```
kafka/              # Kafka namespace
├── Kafka cluster (3 brokers)
├── ZooKeeper cluster (3 replicas)
├── Kafka topics
└── Persistent volumes
```

---

## Deployment Architecture

```
Kubernetes Cluster
├── kafka namespace
│   ├── Strimzi Operator
│   ├── Kafka Brokers (3)
│   ├── ZooKeeper Replicas (3)
│   └── Persistent Volumes
├── airflow namespace (future)
│   └── [Airflow components]
└── spark-operator namespace
    └── [Spark components]
```

---

## Common Operations

### Check Deployment Status

```bash
# Check all namespaces
kubectl get ns

# Check Kafka deployment
kubectl get all -n kafka
kubectl get kafka -n kafka
kubectl get kafkatopic -n kafka

# Check Kafka pod logs
kubectl logs -n kafka -l app.kubernetes.io/name=kafka -f
```

### Access Services

```bash
# Port-forward Kafka
kubectl port-forward -n kafka svc/banking-kafka-kafka-bootstrap 9092:9092

# Connect to Kafka pod
kubectl exec -it -n kafka banking-kafka-kafka-0 bash
```

### Monitor Resources

```bash
# Watch pod creation
kubectl get pods -n kafka -w

# Check resource usage
kubectl top pods -n kafka
kubectl top nodes
```

### Scale Kafka (if needed)

```bash
# Edit Kafka cluster
kubectl edit kafka banking-kafka -n kafka

# Change spec.kafka.replicas to desired number
# Change spec.zookeeper.replicas to desired number
```

---

## Troubleshooting

### Deployment Fails
1. Check prerequisites are installed
2. Verify cluster connectivity: `kubectl cluster-info`
3. Check Helm repositories: `helm repo list`
4. View operator logs: `kubectl logs -n kafka -l app.kubernetes.io/name=strimzi-kafka-operator -f`

### Kafka won't start
1. Check PVC status: `kubectl get pvc -n kafka`
2. Check node resources: `kubectl top nodes`
3. Check events: `kubectl describe kafka banking-kafka -n kafka`

### Cannot connect to Kafka
1. Verify service: `kubectl get svc -n kafka`
2. Test connectivity: `kubectl run -it --image=ubuntu test pod -- nc -zv banking-kafka-kafka-bootstrap.kafka.svc.cluster.local 9092`
3. Check network policies: `kubectl get networkpolicies -n kafka`

---

## Directory Structure

```
deploy/
├── deploy-kafka.sh                    # Kafka deployment script
├── KAFKA_DEPLOYMENT_GUIDE.md          # Detailed Kafka guide
└── README.md                          # This file

iac/
├── kubernetes/
│   ├── kafka/
│   │   ├── namespace.yaml             # Kafka namespace
│   │   └── topic.yaml                 # Kafka topics
│   └── airflow/
│       ├── namespace.yaml
│       ├── ingress.yaml
│       └── secrets.yaml
├── helm/
│   ├── kafka/
│   │   └── kafka-cluster.yaml         # Strimzi Kafka cluster config
│   └── airflow/
│       ├── values-dev.yaml
│       ├── values-stage.yaml
│       └── values-prod.yaml
└── cloudformation/
    └── eks-cluster.yaml               # EKS cluster definition
```

---

## Next Steps

- [ ] Deploy Kafka: `./deploy-kafka.sh`
- [ ] Create additional Kafka topics as needed
- [ ] Set up monitoring (Prometheus + Grafana)
- [ ] Deploy Airflow
- [ ] Configure integrations between services
- [ ] Set up backup and disaster recovery

---

## Support & Documentation

- **Kafka**: See `KAFKA_DEPLOYMENT_GUIDE.md`
- **Kubernetes**: `kubectl --help`
- **Helm**: `helm --help`
- **Strimzi Docs**: https://strimzi.io/docs/

