kubectl create namespace spark-jobs

kubectl create serviceaccount spark -n spark-jobs

kubectl edit deployment spark-operator-controller -n spark-operator

kubectl rollout restart deployment spark-operator-controller -n spark-operator

kubectl describe ScheduledSparkApplication pyspark-job -n spark-jobs
