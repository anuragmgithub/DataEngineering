#!/bin/bash

# ----------- 0. Configuration ------------
AIRFLOW_DIR="/home/anurag/vscode/wkspace/DataEngineering/orchestration"
PYTHON_VERSION="3.10"
AIRFLOW_VERSION="2.7.1"
VENV_DIR="$AIRFLOW_DIR/venv"
CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PYTHON_VERSION}.txt"

# ----------- 2. Setup environment ------------
echo "Creating virtual environment..."
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

echo "Upgrading pip..."
pip install --upgrade pip

echo "Installing Airflow..."
pip install "apache-airflow==${AIRFLOW_VERSION}" --constraint "${CONSTRAINT_URL}"

# ----------- 3. Set AIRFLOW_HOME ------------
export AIRFLOW_HOME="$AIRFLOW_DIR/airflow"
mkdir -p "$AIRFLOW_HOME/dags"

# ----------- 4. Initialize Airflow database ------------
airflow db init

# ----------- 5. Disable example DAGs ------------
echo "Disabling example DAGs..."
sed -i 's/load_examples = True/load_examples = False/' "$AIRFLOW_HOME/airflow.cfg"

# ----------- 6. Create Airflow admin user ------------
echo "Creating admin user..."
airflow users create \
    --username admin \
    --firstname Anurag \
    --lastname User \
    --role Admin \
    --email admin@example.com

# ----------- 7. Start services ------------
echo "Starting scheduler and webserver..."
airflow scheduler &

airflow webserver --port 8080
