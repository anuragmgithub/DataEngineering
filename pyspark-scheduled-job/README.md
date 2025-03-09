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

### Key Components of a ServiceAccount:  
A ServiceAccount consists of:  
1. ServiceAccount Object: Defines the identity.
2. Role or ClusterRole: Defines the permissions.
3. RoleBinding or ClusterRoleBinding: Assigns the permissions to the ServiceAccount. 

steps:  
1. Create a ServiceAccount.
2. Define a Role with Necessary Permissions.  
3. Bind the Role to the ServiceAccount.  
4. Use the ServiceAccount in a Spark Job.  


#### Types of ServiceAccounts:  
1. Default ServiceAccount (Automatically Created)

Every namespace has a default ServiceAccount.
If a pod doesn’t specify a ServiceAccount, it runs under default.
2. Custom ServiceAccounts (User-Defined for Security)

Can have specific permissions to interact with Kubernetes API.
Useful for applications needing limited API access.

3. Cluster-Wide ServiceAccounts (Using ClusterRole)

If a pod needs to access resources across namespaces, you create a ClusterRole and ClusterRoleBinding instead of a simple Role.






