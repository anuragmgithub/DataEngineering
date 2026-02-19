## Configure kubectl:  
```
aws eks update-kubeconfig \
  --region us-east-1 \
  --name eks-data-lake

kubectl get nodes
```
## Verify EBS CSI Driver: 
```
kubectl get pods -n kube-system | grep ebs
```

- If CrashLoopBackOff: 
```
kubectl logs -n kube-system <ebs-controller-pod> -c ebs-plugin
```
note, ensure IRSA role attached to addon  

## Verify StorageClass:  
```
kubectl get storageclass
```

- DO NOT use ReadWriteMany with EBS 
Why?

EBS supports only:  

✅ ReadWriteOnce  
❌ ReadWriteMany  

- DO NOT add accessModes in new chart  
Additional property accessModes is not allowed  

- install Airflow 
```
helm upgrade --install airflow apache-airflow/airflow \
  -n airflow \
  -f values-dev.yaml
```

- Verify Pods:  
```
kubectl get pods -n airflow
```

Expected:  
- scheduler → Running  
- webserver/api → Running  
- triggerer → Running  
- postgres → Running  

### If Pods Pending  
- check events:  
```
kubectl describe pod <pod-name> -n airflow
```
- check pvc: 
```
kubectl get pvc -n airflow
``` 
STATUS = Bound  

- If PVC Pending 
```
kubectl describe pvc <pvc-name> -n airflow
```

## TODO 
- External RDS
- S3 logs
- ALB ingress
- autoscaling
- cost optimization
- spot-aware scheduling

