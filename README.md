# QGIS 2.18 LTR platform for Docker

A Docker container for the QGIS platform

The QGIS platform is aimed to be a base image for building pyqgis and qgis server based Docker applications.

The QGIS platform does not include the qgis desktop apllication and include the `python-qgis` and the
`qgis-server` official debian packages from [qgis.org](https://www.qgis.org/fr/site/forusers/alldownloads.html#debian-ubuntu) 

GRASS and SAGA are not installed by default and should be installed in child images if needed.

# Runnig the server

The fcgi server is started with the command `run-qgis-server`:

```
docker run -it qgis-platform:2.18 run-qgis-server
```

The fcgi socket is exposed on port 7000 

## Environment variables

- `QGIS_USER`: User id/name used run the server - default `qgis`
- `QGIS_HOME`: Path to the Qgis HOME directory - default `/srv/qgis`
- `QGIS_OPTIONS_PATH`: Path to the Qgis options - default `$QGIS_HOME/config`
- `QGIS_PLUGINPATH`: Path to the Qgis server plugins - default `$QGIS_HOME/plugins`
- `QGIS_SERVER_LOG_LEVEL`: Server log lever - default `2`
- `QGIS_WORKERS`: Number of qgis workers - default `2`
- `QGIS_SERVER_LOG_FILE`: Qgis server log file - default `$QGIS_HOME/qgis.log`





