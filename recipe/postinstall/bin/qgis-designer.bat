@echo off
call "%~dp0\o4w_env.bat"
path %OSGEO4W_ROOT%\apps\qgis\bin;%PATH%
set QGIS_PREFIX_PATH=%OSGEO4W_ROOT:\=/%/apps/qgis
set QT_PLUGIN_PATH=%OSGEO4W_ROOT%\apps\qgis\qtplugins;%OSGEO4W_ROOT%\plugins
start "Qt Designer with QGIS custom widgets" /B "%OSGEO4W_ROOT%"\bin\designer.exe %*
