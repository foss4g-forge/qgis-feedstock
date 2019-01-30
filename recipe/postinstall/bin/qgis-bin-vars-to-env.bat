@echo off
@setlocal enabledelayedexpansion

pushd "%~dp0"

  call qgis_env.bat

  set qgis_vars=qgis-bin.vars
  set qgis_env=qgis-bin.env

  if not exist %qgis_vars% exit /b 1
  if exist %qgis_env% del /q %qgis_env%

  for /f "delims=" %%L in (%qgis_vars%) do (

    if not "!%%L!" == "" (
      echo %%L=!%%L!>> %qgis_env%
    )

  )

popd

@endlocal
