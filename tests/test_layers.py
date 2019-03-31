
from qgis.core import (Qgis, QgsProject, QgsVectorLayer)


def test_can_load_layer(data):
    """ Check if layer can be loaded
    """
    source = str(data / "france_parts/france_parts.shp")
    layer  = QgsVectorLayer(source)

    assert layer.isValid()


def test_can_load_project(data):
    """ Check if project can be loaded
    """
    source  = str(data / "france_parts.qgs")
    project = QgsProject()
    project.read(source)

    assert len(project.mapLayers()) >= 1
