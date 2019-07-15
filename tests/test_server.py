
from qgis.core import QgsSettings
from qgis.server import QgsServiceRegistry

def test_services_loaded(client) -> None:
    """ Test services are loaded
    """
    reg = client.serviceRegistry
    assert reg.getService('WMS')  is not None
    assert reg.getService('WFS')  is not None
    assert reg.getService('WCS')  is not None
    assert reg.getService('WMTS') is not None

def test_get_capabilities(client) -> None: 
    """ Test get capabilities return all layers
    """
    rv = client.get( "?MAP=france_parts.qgs&SERVICE=WMS&request=GetCapabilities", 
                     project = "france_parts.qgs")
    assert rv.status_code == 200
    assert rv.headers['Content-Type'] == 'text/xml; charset=utf-8'
   
    # Check layers
    elem = rv.xpath(".//wms:Layer")
    assert isinstance(elem,list)
    assert len(elem) > 1

def test_settings(client) -> None:
    """ Test thas settings are read
    """

    settings = QgsSettings()    
    
    val = settings.value('test/foobar')
    assert val == '42'




