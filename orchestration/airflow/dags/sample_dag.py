from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator

# Python function to be used as a task
def say_hello():
    print("Hello, Airflow!")

# Default arguments for the DAG
default_args = {
    'owner': 'anurag',
    'retries': 1,
    'retry_delay': timedelta(minutes=1)
}

# Define the DAG
with DAG(
    dag_id='hello_world_dag',
    default_args=default_args,
    description='A simple Hello World DAG',
    start_date=datetime(2024, 1, 1),
    schedule_interval='@daily',  # runs once a day
    catchup=False,               # don’t backfill past runs
    tags=['example']
) as dag:

    # Define task using PythonOperator
    hello_task = PythonOperator(
        task_id='say_hello_task',
        python_callable=say_hello
    )

    hello_task
