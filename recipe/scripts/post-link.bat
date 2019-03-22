set "LIBRARY_PREFIX=%PREFIX%\Library"

set "MSG_LOG=%PREFIX%\.messages.txt"
set _msg_cnt=0

if not exist "%LIBRARY_PREFIX%" (
  echo "%DATE% %TIME% qgis post-link error: %LIBRARY_PREFIX% not found" >> "%MSG_LOG%"
  exit 1
)

if "%LIBRARY_PREFIX_SHORT%" == "" (
  REM Set LIBRARY_PREFIX to short path version
  for %%i in ("%LIBRARY_PREFIX%") do set LIBRARY_PREFIX_SHORT=%%~fsi
)

if "%LIBRARY_PREFIX_POSIX%" == "" set LIBRARY_PREFIX_POSIX=%LIBRARY_PREFIX:\=/%

REM Set up extra plugin paths
mkdir "%LIBRARY_PREFIX%\apps\qgis-plugins\cpp"
mkdir "%LIBRARY_PREFIX%\apps\qgis-plugins\python"

REM Ensure gdalplugins path exists, so env var is set
REM See activate.bat of gdal pkg
REM Note: differs from gdal src build, which defaults to bin\gdalplugins
mkdir "%LIBRARY_PREFIX%\lib\gdalplugins"

REM Set env var now, for qgis-bin-vars-to-env.bat,
REM   as gdal activation may not have set it yet (if dir did not exist)
set "GDAL_DRIVER_PATH=%LIBRARY_PREFIX%\lib\gdalplugins"

REM Parse out qgis.vars to qgis.env
call %LIBRARY_PREFIX_SHORT%\bin\qgis-bin-vars-to-env.bat
if errorlevel 1 (
  echo "%DATE% %TIME% qgis post-link error: qgis-vars-to-env failed" >> "%MSG_LOG%"
  set /a "_msg_cnt=_msg_cnt+1"
)

REM Copy qt5 pkg's qt.conf for qgis bin directory
copy /y "%LIBRARY_PREFIX%\bin\qt.conf" "%LIBRARY_PREFIX%\apps\qgis\bin\qt.conf"
if errorlevel 1 (
  echo "%DATE% %TIME% qgis post-link error: copy of qt.conf failed" >> "%MSG_LOG%"
  set /a "_msg_cnt=_msg_cnt+1"
)

REM Parse any custom global settings template
REM ini format requires \\ (doubled) path separators in Win filesys mappings
REM Use full, expanded (non-short-name) Win paths for mappings
if exist "%LIBRARY_PREFIX_SHORT%\apps\qgis\resources\qgis_global_settings.ini.tmpl" (
  del /q "%LIBRARY_PREFIX_SHORT%\apps\qgis\resources\qgis_global_settings.ini"
  %LIBRARY_PREFIX_SHORT%\bin\textreplace ^
    -sf "%LIBRARY_PREFIX_SHORT%\apps\qgis\resources\qgis_global_settings.ini.tmpl" ^
    -df "%LIBRARY_PREFIX_SHORT%\apps\qgis\resources\qgis_global_settings.ini" ^
    -map @conda_prefix@ "%PREFIX:\=\\%" ^
    -map @conda_root@ "%PREFIX:\=/%"
  if errorlevel 1 (
    echo "%DATE% %TIME% qgis post-link error: textreplace of qgis_global_settings.ini.tmpl failed" >> "%MSG_LOG%"
    set /a "_msg_cnt=_msg_cnt+1"
  )
)

REM Parse registry template
REM ini format requires \\ (doubled) path separators in Win filesys mappings
REM Use full, expanded (non-short-name) Win paths for mappings

REM Determine permission level for registry
set "_reg=HKEY_LOCAL_MACHINE"
set "_elev=elevate"
REM Ref: https://stackoverflow.com/a/16248527
reg add HKLM /F>nul 2>&1
if errorlevel 1 (
  set "_reg=HKEY_CURRENT_USER"
  set "_elev=exec hide"
)

if exist "%LIBRARY_PREFIX_SHORT%\apps\qgis\bin\qgis.reg.tmpl" (
  %LIBRARY_PREFIX_SHORT%\bin\textreplace ^
    -sf "%LIBRARY_PREFIX_SHORT%\apps\qgis\bin\qgis.reg.tmpl" ^
    -df "%LIBRARY_PREFIX_SHORT%\apps\qgis\bin\qgis.reg" ^
    -map @package@ qgis ^
    -map @osgeo4w@ "%LIBRARY_PREFIX:\=\\%" ^
    -map @reglevel@ %_reg%
  if errorlevel 1 (
    echo "%DATE% %TIME% qgis post-link error: textreplace of qgis.reg.tmpl failed" >> "%MSG_LOG%"
    set /a "_msg_cnt=_msg_cnt+1"
  )
) else (
  echo "%DATE% %TIME% qgis post-link error: qgis.reg.tmpl not found" >> "%MSG_LOG%"
    set /a "_msg_cnt=_msg_cnt+1"
)

REM Update registry
if exist "%LIBRARY_PREFIX_SHORT%\apps\qgis\bin\qgis.reg" (
  %LIBRARY_PREFIX_SHORT%\bin\nircmd %_elev% "%WINDIR%\regedit" /s "%LIBRARY_PREFIX_SHORT%\apps\qgis\bin\qgis.reg"
  if errorlevel 1 (
    echo "%DATE% %TIME% qgis post-link error: update of registry with qgis.reg failed" >> "%MSG_LOG%"
    set /a "_msg_cnt=_msg_cnt+1"
  )
) else (
  echo "%DATE% %TIME% qgis post-link error: qgis.reg parsed template not found" >> "%MSG_LOG%"
    set /a "_msg_cnt=_msg_cnt+1"
)

REM Run crssync; generally we will always run against the same GDAL/OGR we build against
REM This is done in CMake postinstall build step; uncomment if that is not enough sync
REM path %PATH%;%PKGDIR%\bin
REM set QGIS_PREFIX_PATH=%LIBRARY_PREFIX_SHORT:\=/%/apps/qgis
REM "%PKGDIR%\crssync"

REM TODO: exit 1 on _msg_cnt > 0, once script is totally awesome
