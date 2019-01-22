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
set QGIS_PLUGINPATH=%OSGEO4W_ROOT%\apps\qgis-plugins\python;%QGIS_PLUGINPATH%

cd "%~dp0"

set qgis_vars=qgis-bin.vars
set qgis_env=qgis-bin.env

if not exist %qgis_vars% exit /b 1
if exist %qgis_env% del /q %qgis_env%

@setlocal enabledelayedexpansion

for /f "delims=" %%L in (%qgis_vars%) do (

  if not "!%%L!" == "" (
    echo %%L=!%%L! >> %qgis_env%
  )

)

@endlocal
