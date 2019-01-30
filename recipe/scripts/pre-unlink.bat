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

REM TODO: exit 1 on _msg_cnt > 0, once script is totally awesome
