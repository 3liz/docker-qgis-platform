# QGIS platform for Docker

A Docker container for the QGIS platform

The QGIS platform is aimed to be a base image for building pyqgis and qgis server based Docker applications.

The QGIS platform does not include the qgis desktop apllication and include the `python-qgis` and the
`qgis-server` official debian packages from [qgis.org](https://www.qgis.org/fr/site/forusers/alldownloads.html#debian-ubuntu) 


The image run only the default shell from the debian base image.

You may test the installation by running the `qgis-check-platform` command that display the list of the  processing
algorithm availables.

GRASS and SAGA are not installed by default and should be installed in child images if needed.

## Building image

```
make build tag clean FLAVOR=<FLAVOR> TARGET=<TARGET>
```

* Where `FLAVOR` is `ltr`,`release`,`nightly-ltr`,`nightly-release` or any X.YY version available as debian/ubuntu package.
* Where `TARGET` is `debian` or `ubuntu`

