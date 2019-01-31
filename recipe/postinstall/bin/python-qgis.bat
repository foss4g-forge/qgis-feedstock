@echo off
@setlocal

call "%~dp0\qgis_env.bat"

"%CONDA_ROOT%\python.exe" %*

@endlocal
