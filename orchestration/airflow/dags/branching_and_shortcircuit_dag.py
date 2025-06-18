from airflow import DAG
from airflow.operators.python import PythonOperator, BranchPythonOperator, ShortCircuitOperator
from airflow.operators.empty import EmptyOperator
from datetime import datetime
import pendulum

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2024, 1, 1),
}

with DAG(
    dag_id='branching_and_shortcircuit_dag',
    default_args=default_args,
    schedule_interval='@daily',
    catchup=False,
    tags=['practice', 'branching'],
) as dag:

    def check_day():
        day = pendulum.now().day_of_week  # 0 = Monday, 6 = Sunday
        if day < 5:
            return 'weekday_task'
        else:
            return 'weekend_task'

    branch = BranchPythonOperator(
        task_id='branching',
        python_callable=check_day
    )

    weekday_task = PythonOperator(
        task_id='weekday_task',
        python_callable=lambda: print("Running weekday task")
    )

    weekend_task = PythonOperator(
        task_id='weekend_task',
        python_callable=lambda: print("Running weekend task")
    )

    join = EmptyOperator(
        task_id='join',
        trigger_rule='none_failed_min_one_success'
    )

    def should_continue():
        # Use this in place of a branch for fine-grained control
        return pendulum.now().day_of_week < 5

    short_circuit = ShortCircuitOperator(
        task_id='check_if_weekday',
        python_callable=should_continue
    )

    continue_task = PythonOperator(
        task_id='continued_task',
        python_callable=lambda: print("ShortCircuit allowed this task to run.")
    )

    # DAG Flow
    branch >> [weekday_task, weekend_task] >> join
    join >> short_circuit >> continue_task
