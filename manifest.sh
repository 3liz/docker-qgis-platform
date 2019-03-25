#!/usr/bin/env python

from __future__ import print_function
import os

from qgis.core import QGis

qgis_version=QGis.QGIS_VERSION

version = qgis_version.split('-')[0]
version_short = "{}.{}".format(*version.split('.')[0:2])

print("name=%s" % os.getenv('NAME'))
print("version=%s" % version)
print('version_short=%s' % version_short)
print("buildid=%s"  % os.getenv('BUILDID')) 
print("commitid=%s" % os.getenv('COMMITID')) 
print("qgis_version=%s" % qgis_version)

