set "LIBRARY_PREFIX=%PREFIX%\Library"

set "MSG_LOG=%PREFIX%\.messages.txt"
set _msg_cnt=0

if not exist "%LIBRARY_PREFIX%" (
  echo "%DATE% %TIME% pre-unlink error: %LIBRARY_PREFIX% not found" >> "%MSG_LOG%"
  set /a "_msg_cnt=_msg_cnt+1"
)

set "OSGEO4W_ROOT=%LIBRARY_PREFIX%"

REM Remove generated files
del /q "%OSGEO4W_ROOT%\bin\qgis-bin.env"
del /q "%OSGEO4W_ROOT%\apps\qgis\python\qgis\qgisconfig.py"
del /q "%OSGEO4W_ROOT%\apps\qgis\bin\qgis.reg"

del /s /q "%OSGEO4W_ROOT%\apps\qgis\python\*.pyc"

REM TODO: exit 1 on _msg_cnt > 0, once script is totally awesome
