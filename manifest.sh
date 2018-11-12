#!/usr/bin/env python

from __future__ import print_function

import os
from qgis.core import QGis

def getenv( name ):
    return os.environ[name]

flavor = getenv( 'FLAVOR' )
version_short = None

qgis_version=QGis.QGIS_VERSION

if flavor in ('release','ltr'):
    version = qgis_version.split('-')[0]
    version_short = "{}.{}".format(*version.split('.')[0:2])
else:
    version = flavor

print("name=%s" % getenv('NAME'))
print("version=%s" % version)
if version_short:
    print('version_short=%s' % version_short)
print("buildid=%s"  % getenv('BUILDID')) 
print("commitid=%s" % getenv('COMMITID')) 
print("qgis_version=%s" % qgis_version)
print("flavor=%s" % flavor)

