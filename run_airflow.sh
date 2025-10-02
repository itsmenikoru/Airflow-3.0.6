#!/bin/bash
# start_airflow.sh
# Exit on any error
set -e
export AIRFLOW_HOME=/app/airflow
export AIRFLOW_CONFIG=/app/airflow/airflow.cfg
source /app/airflow/airflow_env/bin/activate

echo "Starting all Airflow components..."

# Start components in the background and store their PIDs
airflow scheduler &
PIDS[0]=$!

airflow dag-processor &
PIDS[1]=$!

airflow triggerer &
PIDS[2]=$!

airflow api-server --port 8080 &
PIDS[3]=$!

# Function to clean up
cleanup() {
    echo "Shutting down all Airflow components..."
    for PID in "${PIDS[@]}"; do
        kill "$PID" 2>/dev/null || true
    done
}

# Trap exit and kill children
trap cleanup EXIT

# Wait for all processes, not just the first to die
wait -n || true