#!/usr/bin/env bash

# Apply script backports only for Qgis < 3.6

PYTHON36=$(python3 -c "from qgis.core import Qgis;print('1' if Qgis.QGIS_VERSION_INT >= 30600 else '')")

if [ -z "$PYTHON36" ]; then
  echo "Applying processing scripts patchs"
  cp ScriptUtils.py /usr/share/qgis/python/plugins/processing/script/
  cp -aR processing /usr/lib/python3/dist-packages/qgis/
else
  echo "No patch to apply..."
fi

