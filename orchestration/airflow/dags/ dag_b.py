from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime

def task_b():
    print("Task B is running.")

with DAG(
    dag_id='dag_b',
    start_date=datetime(2023, 10, 1),
    schedule_interval=None,
    catchup=False,
) as dag_a:

    run_task_b = PythonOperator(
        task_id="run_task_b",
        python_callable=task_b,
    )

    run_task_b