#!/bin/bash

set -e

# Add /.local to path
export PATH=$PATH:/.local/bin

echo "Installing required packages..."
pip3 install -q -U --prefer-binary --user -r tests/requirements.txt

# Disable qDebug stuff that bloats test outputs
if [ "$QGIS_DEBUG" == "1" ]; then
export QT_LOGGING_RULES="*.debug=true;*.warning=true"
else
export QT_LOGGING_RULES="*.debug=false;*.warning=false"
fi 

# Disable python hooks/overrides
export QGIS_DISABLE_MESSAGE_HOOKS=1
export QGIS_NO_OVERRIDE_IMPORT=1

cd tests

pytest -s -v  $@

