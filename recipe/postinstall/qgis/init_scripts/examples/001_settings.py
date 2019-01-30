# Sample script for QGIS Init Script
# This script will check for a setting value in user
# settings and set it to 'A Value' if not found

from qgis.PyQt.QtCore import QSettings
from qgis.core import QgsMessageLog, Qgis

QgsMessageLog.logMessage("Init script: %s" % __file__, tag="Init script", level=Qgis.Info)

if not QSettings().value("InitScript/MyTestSetting"):
    QgsMessageLog.logMessage("Setting 'InitScript/MyTestSetting' to 'A Value'", tag="Init script", level=Qgis.Info)
    QSettings().setValue("InitScript/MyTestSetting", "A Value")
else:
    QgsMessageLog.logMessage("'InitScript/MyTestSetting' already set to '%s'" % QSettings().value("InitScript/MyTestSetting"), tag="Init script", level=Qgis.Info)
