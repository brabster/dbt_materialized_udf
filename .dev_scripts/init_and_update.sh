#!/bin/bash

set -euo pipefail

PIP_REQUIRE_VIRTUALENV=true # have pip abort if we try to install outside a venv
PROJECT_DIR=$(dirname "$0")/.. # script directory
VENV_PATH=${PROJECT_DIR}/.venv
IS_RUNNING_IN_VENV="$(python -c 'import sys; print(sys.prefix != sys.base_prefix)')"

if [ "${IS_RUNNING_IN_VENV}" == 'False' ]; then
    echo 'Not in virtualenv, setting up';
    python -m venv ${VENV_PATH}
    source ${VENV_PATH}/bin/activate
fi

echo "install or upgrade system packages"
pip install --upgrade pip setuptools

echo "install safety for vulnerability check; it prints its own messages about noncommercial use"
pip install --upgrade safety

echo "install or upgrade project-specific dependencies"
pip install -U -r ${PROJECT_DIR}/requirements.txt

echo "install or upgrade dbt dependencies"
dbt deps

echo "check for vulnerabilities"
safety check

echo "load user environment, if present"
ENV_PATH=${PROJECT_DIR}/.env
if [ -f "${ENV_PATH}" ]; then
    source ${ENV_PATH}
    echo "check dbt setup"
    dbt debug
else
    echo "Unable to check dbt setup until .env file is set up and suitable data warehouse credentials are available"
fi



