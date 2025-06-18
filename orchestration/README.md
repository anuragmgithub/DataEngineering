ip addr show eth0
airflow scheduler &
airflow webserver --port 8080
export AIRFLOW_HOME="/home/anurag/vscode/wkspace/DataEngineering/orchestration/airflow"


BranchPythonOperator: Chooses a path depending on whether it’s a weekday or weekend.

ShortCircuitOperator: Prevents downstream tasks from running if condition fails.

trigger_rule='none_failed_min_one_success': Ensures the join task runs even if one path is skipped.