from airflow.decorators import dag, task
from datetime import datetime, timedelta
import logging
from airflow.configuration import conf
from airflow.utils.session import provide_session
from airflow.models import Variable

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

        # Log Airflow info (Airflow 3.0+ compatible)
        from airflow import settings
        from airflow.configuration import conf

        airflow_info = {
            "AIRFLOW_HOME": settings.AIRFLOW_HOME,
            "DAGS_FOLDER": settings.DAGS_FOLDER,
            "EXECUTOR": conf.get("core", "executor"),
            "DEFAULT_TIMEZONE": conf.get("core", "default_timezone"),
        }

        logging.info(f"Airflow Info: {airflow_info}")
        print(f"Airflow Info: {airflow_info}")

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
