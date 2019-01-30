@echo on

if not exist "%LIBRARY_PREFIX%" set "LIBRARY_PREFIX=%CONDA_PREFIX%\Library"
if not exist "%LIBRARY_PREFIX%\" exit /b 1

if not exist "%LIBRARY_PREFIX%\bin\" exit /b 1
if not exist "%LIBRARY_PREFIX%\bin\python-qgis.bat" exit /b 1
if not exist "%LIBRARY_PREFIX%\bin\qgis_env.bat" exit /b 1
if not exist "%LIBRARY_PREFIX%\bin\qgis-designer.bat" exit /b 1
if not exist "%LIBRARY_PREFIX%\bin\qgis.bat" exit /b 1
if not exist "%LIBRARY_PREFIX%\bin\qgis-bin.exe" exit /b 1

call "%LIBRARY_PREFIX%\bin\qgis_env.bat" || exit /b 1

set

:: FIXME: Win app can't launch in console mode
REM echo from qgis.core import QgsApplication; print(QgsApplication.showSettings())> %TEMP%/qgis-test-code.py

REM :: 'exit 2' is correct for --help
REM "%LIBRARY_PREFIX%\bin\qgis-bin.exe" --code %TEMP%/qgis--test-code.py
REM if not errorlevel 2 exit /b 1

python -c "import qgis.core"
if errorlevel 1 exit /b 1
python -c "import qgis.gui"
if errorlevel 1 exit /b 1
python -c "import qgis.utils"
if errorlevel 1 exit /b 1
