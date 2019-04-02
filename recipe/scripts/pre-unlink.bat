set "LIBRARY_PREFIX=%PREFIX%\Library"

set "MSG_LOG=%PREFIX%\.messages.txt"
set _msg_cnt=0

if not exist "%LIBRARY_PREFIX%" (
  echo "%DATE% %TIME% qgis pre-unlink error: %LIBRARY_PREFIX% not found" >> "%MSG_LOG%"
  exit 1
)

REM Remove generated files
del /q "%LIBRARY_PREFIX%\bin\qgis-bin.env"
del /q "%LIBRARY_PREFIX%\apps\qgis\python\qgis\qgisconfig.py"
del /q "%LIBRARY_PREFIX%\apps\qgis\bin\qgis.reg"
del /q "%LIBRARY_PREFIX%\apps\qgis\bin\qt.conf"

del /s /q "%LIBRARY_PREFIX%\apps\qgis\python\*.pyc"

REM Remove any custom init_scripts added after installation
del /s /q "%LIBRARY_PREFIX%\apps\qgis\python\init_scripts\*"

REM Remove registry items with paths to prefix
REM Determine permission level for registry
set "_elev=elevate"
REM Ref: https://stackoverflow.com/a/16248527
reg add HKLM /F>nul 2>&1
if errorlevel 1 (
  set "_elev=exec hide"
)

if exist "%LIBRARY_PREFIX_SHORT%\apps\qgis\bin\qgis-remove.reg" (
  %LIBRARY_PREFIX_SHORT%\bin\nircmd %_elev% "%WINDIR%\regedit" /s "%LIBRARY_PREFIX_SHORT%\apps\qgis\bin\qgis-remove.reg"
  if errorlevel 1 (
    echo "%DATE% %TIME% qgis post-link error: update of registry with qgis-remove.reg failed" >> "%MSG_LOG%"
    set /a "_msg_cnt=_msg_cnt+1"
  )
) else (
  echo "%DATE% %TIME% qgis post-link error: qgis-remove.reg parsed template not found" >> "%MSG_LOG%"
    set /a "_msg_cnt=_msg_cnt+1"
)

REM TODO: exit 1 on _msg_cnt > 0, once script is totally awesome
