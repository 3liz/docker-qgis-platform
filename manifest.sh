#!/usr/bin/env python3

import os
from qgis.core import Qgis

def getenv( name ):
    return os.environ[name]

flavor = getenv( 'FLAVOR' )
version_short = None

qgis_version=Qgis.QGIS_VERSION

if flavor == 'release':
    version = qgis_version.split('-')[0]
    version_short = "{}.{}".format(*version.split('.')[0:2])
elif flavor == 'ltr':
    version = "{}.{}".format(*version.split('.')[0:2])+'-ltr'
    version_short = 'ltr'
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

