import sys
import os
from qgis.core import QgsApplication, QgsVectorLayer

# prevent display not found error
os.environ['QT_QPA_PLATFORM'] = 'offscreen'

qgis_application = QgsApplication([], False)
qgis_application.setPrefixPath('/usr', True)
qgis_application.initQgis()

# Add a hook to qgis  message log
def writelogmessage(message, tag, level):
    print('Qgis: {}({}): {}'.format( tag, level, message ), file=sys.stderr, flush=True)

QgsApplication.instance().messageLog().messageReceived.connect( writelogmessage )

print("--- Reading data")
layer = QgsVectorLayer('data/france_parts/france_parts.shp')

# Return True on 3.4.5/stretch, False on 3.6.0/buster
print("Layer is valid", layer.isValid())

