@echo off
call "%~dp0\o4w_env.bat"
set "PATH=%LIBRARY_PREFIX%\apps\qgis\bin;%PATH%"
set "QGIS_PREFIX_PATH=%LIBRARY_PREFIX_POSIX%/apps/qgis"
set "QT_PLUGIN_PATH=%LIBRARY_PREFIX_POSIX%/apps/qgis/qtplugins;%LIBRARY_PREFIX_POSIX%/plugins"
start "Qt Designer with QGIS custom widgets" /B "%LIBRARY_PREFIX%\bin\designer.exe" %*
