# Script to be run when QGIS starts
# The script looks for other scripts into a Init directory
# that can be specified  on the env var QGIS_INIT_SCRIPTS_DIRECTORY
# or by default will be set as QgsApplication.pkgDataPath() +
# Init_scripts
# Scripts are alphabetically sorted before they are imported (and run)


import os
try:
    # since Py 3.1
    import importlib.util
    imp_util = True
except ImportError:
    import imp
    imp_util = False
from qgis.core import QgsApplication, QgsMessageLog, Qgis

try:
    custom_scripts_directory = os.environ['QGIS_INIT_SCRIPTS_DIRECTORY']
except:
    # Default
    custom_scripts_directory = os.path.join(QgsApplication.pkgDataPath(), 'init_scripts')

if os.path.exists(custom_scripts_directory):
    scripts = []
    for f in os.listdir(custom_scripts_directory):
        if f.endswith(".py"):
            scripts.append(f)
    scripts.sort()
    if len(scripts):
        for s in scripts:
            try:
                try:
                    if imp_util:
                        spec = importlib.util.spec_from_file_location(s.replace('.py', ''),
                            os.path.join(custom_scripts_directory, s))
                        module = importlib.util.module_from_spec(spec)
                        spec.loader.exec_module(module)
                    else:
                        # this is deprecated in Py3, but still works in 3.7
                        imp.load_source(s.replace('.py', ''), os.path.join(custom_scripts_directory, s))
                    QgsMessageLog.logMessage("Init script has completed running: %s" % s, tag="Init script", level=Qgis.Info)
                except Exception as ex:
                    QgsMessageLog.logMessage("Init script runtime error: %s\n%s" % (s, ex), tag="Init script", level=Qgis.Critical)
            except ImportError as ex:
                QgsMessageLog.logMessage("Init script import error: %s\n%s" % (s, ex), tag="Init script", level=Qgis.Critical)
    else:
        QgsMessageLog.logMessage("Init scripts directory has no runnable scripts: %s" % custom_scripts_directory, tag="Init script", level=Qgis.Warning)

else:
    QgsMessageLog.logMessage("Init scripts directory does not exist: %s" % custom_scripts_directory, tag="Init script", level=Qgis.Warning)
