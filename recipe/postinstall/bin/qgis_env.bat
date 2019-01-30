@echo off

pushd "%~dp0"

  call o4w_env.bat
  call qt5_env.bat
  call py3_env.bat
  if exist grass_env.bat call grass_env.bat

  @echo off
  if exist grass_env.bat (
    path %LIBRARY_PREFIX%\apps\qgis\bin;%GISBASE%\lib;%GISBASE%\bin;%PATH%
  ) else (
    path %LIBRARY_PREFIX%\apps\qgis\bin;%PATH%
  )
  set QGIS_PREFIX_PATH=%LIBRARY_PREFIX_POSIX%/apps/qgis
  set GDAL_FILENAME_IS_UTF8=YES
  rem Set VSI cache to be used as buffer, see #6448
  set VSI_CACHE=TRUE
  set VSI_CACHE_SIZE=1000000
  REM Add qt plugins search path, while honoring any user-set QT_PLUGIN_PATH
  set QT_PLUGIN_PATH=%LIBRARY_PREFIX%\apps\qgis\qtplugins;%LIBRARY_PREFIX%\plugins;%QT_PLUGIN_PATH%

  REM Extra deployed plugins within %LIBRARY_PREFIX%
  REM Plugins should be installed as expanded plugin archive, via separate conda package
  set QGIS_PLUGINPATH=%LIBRARY_PREFIX%\apps\qgis-plugins\python;%QGIS_PLUGINPATH%

  REM Add qgis's python, while honoring any user-set PYTHONPATH
  set PYTHONPATH=%CONDA_ROOT%\Lib\site-packages;%LIBRARY_PREFIX%\apps\qgis\python;%PYTHONPATH%

  REM For debugging
  REM set > qgis-env-vars.txt

popd
