# Patches 

## Patch mkdirs 

Replace recusive creation function by library recursive directory creation function
[`os.makedirs`](https://docs.python.org/3.8/library/os.html). This will not throw exception
in case the directory already exists because it has been created atfer the existence test.

This fix the raising of exception in  concurrency situation when initializing processing in a multi processing environment.

Files modified: `/usr/share/qgis/python/plugins/processing/tools/system.py`

Ref: https://github.com/qgis/QGIS/pull/43006

