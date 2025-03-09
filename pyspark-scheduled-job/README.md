## What is a ServiceAccount in Kubernetes?  
1. Fine-Grained Access Control:  

By default, a pod running in Kubernetes has access to the API server, but it might have more permissions than necessary.
A ServiceAccount allows you to grant only the required permissions using RBAC (Role-Based Access Control).  

2. Authentication & Authorization:  
Kubernetes automatically assigns a token to a ServiceAccount, which pods can use to authenticate with the API.

3. Custom Access for Applications:  
Some applications (like Spark Operator, Helm, or custom workloads) require access to deploy, manage, or interact with Kubernetes objects. A ServiceAccount ensures they get the required permissions.


list of commands:  
```
kubectl create namespace spark-jobs

kubectl create serviceaccount spark -n spark-jobs

kubectl edit deployment spark-operator-controller -n spark-operator

kubectl rollout restart deployment spark-operator-controller -n spark-operator

kubectl describe ScheduledSparkApplication pyspark-job -n spark-jobs

If you want to delete all namespaces except system ones:
kubectl get ns --no-headers | awk '{if ($1 != "default" && $1 != "kube-system" && $1 != "kube-public" && $1 != "kube-node-lease") print $1}' | xargs kubectl delete ns

 Delete All Resources (Deployments, Pods, Services, etc.):  
 kubectl delete all --all --all-namespaces


To force delete stuck pods:  
kubectl delete pods --all --all-namespaces --force --grace-period=0  

Delete Persistent Volumes & Storage:  
kubectl delete pvc --all --all-namespaces  
kubectl delete pv --all  

For storage classes:  
kubectl delete storageclass --all  

Delete Custom Resource Definitions (CRDs):  
kubectl delete crd --all  
```



```
helm install spark-operator spark-operator/spark-operator \
  --namespace spark-jobs \
  --create-namespace \
  --set webhook.enable=true \
  --set sparkJobNamespace="*" \
  --set rbac.create=true \
  --set serviceAccounts.spark.name=spark \
  --set sparkOperator.createClusterRole=true
```

### Explanation of Parameters:  
--namespace spark-jobs → Deploys the Spark Operator in the spark-jobs namespace.  
--create-namespace → Creates the spark-jobs namespace if it doesn't exist.  
--set sparkJobNamespace="*" → Allows the operator to manage Spark jobs in all namespaces.  
--set rbac.create=true → Enables Role-Based Access Control (RBAC).  
--set serviceAccounts.spark.name=spark → Creates a service account for Spark jobs.  
--set sparkOperator.createClusterRole=true → Grants the Spark Operator cluster-wide permissions.  





