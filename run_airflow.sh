#!/bin/bash
# start_airflow.sh
# This script starts Airflow with custom configuration and handles cleanup

# Exit immediately if a command fails
set -e

# ----------------------------
# 1. Environment Variables
# ----------------------------
export AIRFLOW_HOME=/app/airflow
export AIRFLOW_CONFIG=/app/airflow/airflow.cfg

# Optional: add AIRFLOW_HOME permanently for this user
if ! grep -q "AIRFLOW_HOME=/app/airflow" ~/.bashrc; then
    echo "export AIRFLOW_HOME=/app/airflow" >> ~/.bashrc
fi
if ! grep -q "AIRFLOW_CONFIG=/app/airflow/airflow.cfg" ~/.bashrc; then
    echo "export AIRFLOW_CONFIG=/app/airflow/airflow.cfg" >> ~/.bashrc
fi

# Activate virtual environment
source /app/airflow/airflow_env/bin/activate

# ----------------------------
# 2. Prepare log directories
# ----------------------------
mkdir -p "$AIRFLOW_HOME/logs"
mkdir -p "$AIRFLOW_HOME/dags"
mkdir -p "$AIRFLOW_HOME/plugins"

# ----------------------------
# 3. Start Airflow components
# ----------------------------
echo "Starting Airflow components..."

# Array to hold PIDs
declare -a PIDS

# Start scheduler
airflow scheduler >> "$AIRFLOW_HOME/logs/scheduler.log" 2>&1 &
PIDS+=($!)

# Start dag-processor
airflow dag-processor >> "$AIRFLOW_HOME/logs/dag_processor.log" 2>&1 &
PIDS+=($!)

# Start triggerer
airflow triggerer >> "$AIRFLOW_HOME/logs/triggerer.log" 2>&1 &
PIDS+=($!)

# Start API server on port 8080
airflow api-server --port 8080 >> "$AIRFLOW_HOME/logs/api_server.log" 2>&1 &
PIDS+=($!)

# ----------------------------
# 4. Cleanup function
# ----------------------------
cleanup() {
    echo "Shutting down Airflow components..."
    for PID in "${PIDS[@]}"; do
        if kill -0 "$PID" 2>/dev/null; then
            kill "$PID"
            wait "$PID" 2>/dev/null
        fi
    done
    echo "All Airflow components stopped."
}

# Trap EXIT, SIGINT, and SIGTERM
trap cleanup EXIT SIGINT SIGTERM

# ----------------------------
# 5. Wait for all processes
# ----------------------------
echo "Airflow is running. Logs can be found in $AIRFLOW_HOME/logs"
wait -n
