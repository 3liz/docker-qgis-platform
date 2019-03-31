import sys
import os
import pytest
import lxml.etree
import glob
import configparser
import logging

from pathlib import Path

logging.basicConfig( stream=sys.stderr )
logging.disable(logging.NOTSET)

LOGGER = logging.getLogger('server')
LOGGER.setLevel(logging.DEBUG)

from typing import Any, Mapping, Dict, Generator

from qgis.core import Qgis, QgsApplication, QgsProject
from qgis.server import (QgsServer, 
                         QgsServerRequest, 
                         QgsBufferServerRequest, 
                         QgsBufferServerResponse)

qgis_application = None

def pytest_sessionstart(session) -> None:
    """ Start qgis application
    """
    global qgis_application
    os.environ['QT_QPA_PLATFORM'] = 'offscreen'
    qgis_application = QgsApplication([], False)
    qgis_application.initQgis()

    # Install logger hook
    install_logger_hook()


def pytest_sessionfinish(session, exitstatus) -> None:
    """ End qgis session
    """
    global qgis_application
    qgis_application.exitQgis()
    del qgis_application


NAMESPACES = {
    'xlink': "http://www.w3.org/1999/xlink",
    'wms': "http://www.opengis.net/wms",
    'wfs': "http://www.opengis.net/wfs",
    'wcs': "http://www.opengis.net/wcs",
    'ows': "http://www.opengis.net/ows/1.1",
    'gml': "http://www.opengis.net/gml",
    'xsi': "http://www.w3.org/2001/XMLSchema-instance"
}

class OWSResponse:

    def __init__(self, resp: QgsBufferServerResponse) -> None:
        self._resp = resp
        self._xml = None

    @property
    def xml(self) -> 'xml':
        if self._xml is None and self._resp.headers().get('Content-Type','').find('text/xml')==0:
            self._xml = lxml.etree.fromstring(self.content)
        return self._xml

    @property
    def content(self) -> bytes:
        return bytes(self._resp.body())

    @property
    def status_code(self) -> int:
        return self._resp.statusCode()

    @property
    def headers(self) -> Dict[str,str]:
        return self._resp.headers()

    def xpath(self, path: str) -> lxml.etree.Element:
        assert self.xml is not None
        return self.xml.xpath(path, namespaces=NAMESPACES)

    def xpath_text(self, path: str) -> str:
        assert self.xml is not None
        return ' '.join(e.text for e in self.xpath(path))


@pytest.fixture(scope='session')
def data(request) -> Path:
    return Path(request.config.rootdir.join('data').strpath)


@pytest.fixture(scope='session')
def client(request):
    """ Return a qgis server instance
    """
    class _Client:

        def __init__(self) -> None:
            self.datapath = request.config.rootdir.join('data')
            self.server = QgsServer()

        @property
        def serverInterface(self) -> 'QgsServerInterface':
            return self.server.serverInterface()

        @property
        def serviceRegistry(self) -> 'QgsServiceRegistry':
            return self.serverInterface.serviceRegistry()

        def getprojectpath(self, name: str) -> str:
            return Path(self.datapath.join(name).strpath)

        def get(self, query: str, project: str=None) -> OWSResponse:
            """ Return server response from query
            """
            request  = QgsBufferServerRequest(query, QgsServerRequest.GetMethod, {}, None)
            response = QgsBufferServerResponse()
            if project is not None and not os.path.isabs(project):
                projectpath = self.datapath.join(project)
                qgsproject  = QgsProject()
                if not qgsproject.read(projectpath.strpath):
                    raise ValueError("Error reading project '%s':" % projectpath.strpath)
            else:
                qgsproject = None
            self.server.handleRequest(request, response, project=qgsproject)
            return OWSResponse(response)

    return _Client()



#
# Logger hook
#

def install_logger_hook( verbose: bool=False ) -> None:
    """ Install message log hook
    """
    from qgis.core import Qgis, QgsApplication, QgsMessageLog
    # Add a hook to qgis  message log
    def writelogmessage(message, tag, level):
        arg = '{}: {}'.format( tag, message )
        if level == Qgis.Warning:
            LOGGER.warning(arg)
        elif level == Qgis.Critical:
            LOGGER.error(arg)
        elif verbose:
            # Qgis is somehow very noisy
            # log only if verbose is set
            LOGGER.info(arg)

    messageLog = QgsApplication.messageLog()
    messageLog.messageReceived.connect( writelogmessage )
