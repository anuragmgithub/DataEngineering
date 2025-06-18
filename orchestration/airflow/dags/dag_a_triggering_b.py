from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from airflow.sensors.external_task import ExternalTaskSensor

from datetime import datetime

def task_a():
    print("Task A is running.")

with DAG(
    dag_id="dag_a_triggering_b",
    start_date=datetime(2024, 1, 1),
    schedule="@daily",
    catchup=False,
    tags=["example"],
) as dag_a:
    
    run_task_a = PythonOperator(
        task_id="run_task_a",
        python_callable=task_a,
    )

    # Trigger DAG B
    trigger_dag_b = TriggerDagRunOperator(
        task_id="trigger_dag_b",
        trigger_dag_id="dag_b",  # The ID of the DAG to trigger
    )

    run_task_a >> trigger_dag_b


