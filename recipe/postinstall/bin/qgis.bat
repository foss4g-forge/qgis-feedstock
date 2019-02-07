@echo off
@setlocal

call "%~dp0\qgis_env.bat"

rem change to HOME dir so it defaults for open file(s) dialogs
cd "%USERPROFILE%"
set "initscr=%LIBRARY_PREFIX%\apps\qgis\init_scripts.py"
if exist "%initscr%" (
  start "QGIS Desktop" /B "%LIBRARY_PREFIX%\bin\qgis-bin.exe" --code "%initscr%" %*
) else (
  start "QGIS Desktop" /B "%LIBRARY_PREFIX%\bin\qgis-bin.exe" %*
)

@endlocal
