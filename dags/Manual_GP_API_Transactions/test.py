from airflow.decorators import dag, task
from datetime import datetime, timedelta
import logging

default_args = {
    "owner": "tester",
    "retries": 0,
    "retry_delay": timedelta(minutes=1),
}

@dag(
    dag_id="test_log_dag",
    start_date=datetime(2024, 9, 30),
    schedule=None,
    catchup=False,
    tags=["test"],
    default_args=default_args,
)
def test_log_dag():

    @task
    def extract():
        logging.info("DAG is running fine in Airflow 3.0.6! [EXTRACT]")
        print("Hello World Extract")
        return "Extracted"

    @task
    def transform():
        logging.info("DAG is running fine in Airflow 3.0.6! [TRANSFORM]")
        print("Hello World Transform")
        return "Transformed"

    @task
    def load():
        logging.info("DAG is running fine in Airflow 3.0.6! [LOAD]")
        print("Hello World Load")
        return "Loaded"

    # Define task dependencies
    extracted = extract()
    transformed = transform()
    loaded = load()

    extracted >> transformed >> loaded

# Instantiate the DAG
test_log_dag()
