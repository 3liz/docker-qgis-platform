#!/usr/bin/env bash

echo "Applying processing scripts patchs"
cp ScriptUtils.py /usr/share/qgis/python/plugins/processing/script/
cp -aR processing /usr/lib/python3/dist-packages/qgis/


