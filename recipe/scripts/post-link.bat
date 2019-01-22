set "LIBRARY_PREFIX=%PREFIX%\Library"
set "LIBRARY_BIN=%PREFIX%\Library\bin"
set "LIBRARY_APPS=%PREFIX%\Library\apps"

set "MSG_LOG=%PREFIX%\.messages.txt"
set _msg_cnt=0

if not exist "%LIBRARY_PREFIX%" (
  echo "%DATE% %TIME% post-link error: %LIBRARY_PREFIX% not found" >> "%MSG_LOG%"
  set /a "_msg_cnt=_msg_cnt+1"
)

set "OSGEO4W_ROOT=%LIBRARY_PREFIX%"
REM get short path without blanks
for %%i in ("%LIBRARY_PREFIX%") do set O4W_ROOT=%%~fsi

REM Parse out qgis.vars to qgis.env
call %LIBRARY_BIN%\qgis-bin-vars-to-env.bat
if errorlevel 1 (
  echo "%DATE% %TIME% post-link error: qgis-vars-to-env failed" >> "%MSG_LOG%"
  set /a "_msg_cnt=_msg_cnt+1"
)

REM Copy qt5 pkg's qt.conf for qgis bin directory
copy /y "%OSGEO4W_ROOT%\bin\qt.conf" "%OSGEO4W_ROOT%\apps\qgis\bin\qt.conf"
if errorlevel 1 (
  echo "%DATE% %TIME% post-link error: copy of qt.conf failed" >> "%MSG_LOG%"
  set /a "_msg_cnt=_msg_cnt+1"
)

REM Parse any custom global settings template
REM textreplace requires \\ (doubled) path separators in mappings
REM Use full, expanded Win paths for mappings
if exist "%O4W_ROOT%\apps\qgis\resources\qgis_global_settings.ini.tmpl" (
  del /q "%O4W_ROOT%\apps\qgis\resources\qgis_global_settings.ini"
  textreplace ^
    -sf "%O4W_ROOT%\apps\qgis\resources\qgis_global_settings.ini.tmpl" ^
    -df "%O4W_ROOT%\apps\qgis\resources\qgis_global_settings.ini" ^
    -map @conda_prefix@ %PREFIX:\=\\% ^
    -map @conda_root@ %PREFIX:\=/%
  if errorlevel 1 (
    echo "%DATE% %TIME% post-link error: textreplace of qgis_global_settings.ini.tmpl failed" >> "%MSG_LOG%"
    set /a "_msg_cnt=_msg_cnt+1"
  )
)

REM Parse registry template
REM textreplace requires \\ (doubled) path separators in mappings
REM Use full, expanded Win paths for mappings in mappings
textreplace ^
  -sf "%O4W_ROOT%\apps\qgis\bin\qgis.reg.tmpl" ^
  -df "%O4W_ROOT%\apps\qgis\bin\qgis.reg" ^
  -map @package@ qgis ^
  -map @osgeo4w@ %OSGEO4W_ROOT:\=\\%
if errorlevel 1 (
  echo "%DATE% %TIME% post-link error: textreplace of qgis.reg.tmpl failed" >> "%MSG_LOG%"
  set /a "_msg_cnt=_msg_cnt+1"
)

REM Update registry
nircmd elevate "%WINDIR%\regedit" /s "%O4W_ROOT%\apps\qgis\bin\qgis.reg"
if errorlevel 1 (
  echo "%DATE% %TIME% post-link error: update of registry with qgis.reg failed" >> "%MSG_LOG%"
  set /a "_msg_cnt=_msg_cnt+1"
)

REM Run crssync; generally we will always run against the same GDAL/OGR we build against
REM This is done in CMake postinstall build step; uncomment if that is not enough sync
REM path %PATH%;%PKGDIR%\bin
REM set QGIS_PREFIX_PATH=%O4W_ROOT%/apps/qgis
REM "%PKGDIR%\crssync"

REM TODO: exit 1 on _msg_cnt > 0, once script is totally awesome
