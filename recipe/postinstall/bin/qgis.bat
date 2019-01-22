@echo off
call "%~dp0\o4w_env.bat"
if exist grass_env.bat call grass_env.bat
call qt5_env.bat
call py3_env.bat

@echo off
if exist grass_env.bat (
  path %OSGEO4W_ROOT%\apps\qgis\bin;%GISBASE%\lib;%GISBASE%\bin;%PATH%
) else (
  path %OSGEO4W_ROOT%\apps\qgis\bin;%PATH%
)
set QGIS_PREFIX_PATH=%OSGEO4W_ROOT:\=/%/apps/qgis
set GDAL_FILENAME_IS_UTF8=YES
rem Set VSI cache to be used as buffer, see #6448
set VSI_CACHE=TRUE
set VSI_CACHE_SIZE=1000000
set QT_PLUGIN_PATH=%OSGEO4W_ROOT%\apps\qgis\qtplugins;%OSGEO4W_ROOT%\plugins

REM Extra deployed plugins within %OSGEO4W_ROOT%
REM Plugins should be installed as expanded plugin archive, via separate conda package
set QGIS_PLUGINPATH=%OSGEO4W_ROOT%\apps\qgis-plugins\python;%QGIS_PLUGINPATH%

rem change to HOME dir so it defaults for open file(s) dialogs
cd %HOMEPATH%
set initscr=%OSGEO4W_ROOT%\apps\qgis\init_scripts.py
if exist "%initscr%" (
  start "QGIS Desktop" /B "%OSGEO4W_ROOT%"\bin\qgis-bin.exe --code "%initscr%" %*
) else (
  start "QGIS Desktop" /B "%OSGEO4W_ROOT%"\bin\qgis-bin.exe %*
)
