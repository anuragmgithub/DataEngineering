from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.sensors.external_task import ExternalTaskSensor
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from datetime import datetime, timedelta

with DAG(
    dag_id='dag_c_sensor',
    start_date=datetime(2023, 1, 1),
    schedule_interval=None,
    catchup=False,
) as dag:

    wait_for_b = ExternalTaskSensor(
        task_id='wait_for_b',
        external_dag_id='dag_b',  # The ID of the DAG to wait for
        external_task_id='run_task_b',  # The task in the external DAG to wait for
        mode='poke',  # Use poke mode for efficiency
        timeout=600,  # Timeout after 10 minutes
        poke_interval=30,  # Check every 30 seconds
    )

    after_b = PythonOperator(
        task_id="after_b",
        python_callable=lambda: print("Running after task_b in dag_b"),
    )

    wait_for_b >> after_b