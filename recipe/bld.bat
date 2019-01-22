setlocal enabledelayedexpansion

set BUILDDIR=%cd%\build
if not exist "%BUILDDIR%" mkdir %BUILDDIR%
if not exist "%BUILDDIR%" (echo could not create build directory %BUILDDIR% & goto error)

if not exist "%OSGEO4W_ROOT%\bin\o4w_env.bat" (echo o4w_env.bat not found & goto error)
call "%OSGEO4W_ROOT%\bin\o4w_env.bat"
call "%OSGEO4W_ROOT%\bin\grass_env.bat"
call "%OSGEO4W_ROOT%\bin\py3_env.bat"
call "%OSGEO4W_ROOT%\bin\qt5_env.bat"

REM set PYVER=pythonXX
for /f "usebackq tokens=1" %%a in (`python -c "import sys; print('python{0}{1}'.format(sys.version_info.major,sys.version_info.minor))"`) do set PYVER=%%a

set O4W_ROOT=%OSGEO4W_ROOT:\=/%
set LIB_DIR=%O4W_ROOT%

set CMAKE_COMPILER_PATH=%PF86%\Microsoft Visual Studio 14.0\VC\bin\amd64
set VC_VER=vc14
set WIN_SDK=win81sdk
set SETUPAPI_LIBRARY=%PF86%\Windows Kits\8.0\Lib\win8\um\x64\SetupAPI.Lib

set BUILDCONF=RelWithDebInfo

set SRCDIR=%CD%

rem #################### Start Pre-customize ####################
if defined QGIS_PRE_CUSTOMIZE_DIR if exist "%QGIS_PRE_CUSTOMIZE_DIR%" (
  pushd "%QGIS_PRE_CUSTOMIZE_DIR%"
    for %%G in ("*.bat") do call "%%G"
  popd
)
rem #################### End Pre-customize ####################


if "%BUILDDIR:~1,1%"==":" %BUILDDIR:~0,2%
cd /D %BUILDDIR%

set PKGDIR=%OSGEO4W_ROOT%\apps\qgis

REM For debugging setup; leave commentted
set

if exist repackage goto package


echo BEGIN: %DATE% %TIME%

if exist qgsversion.h del qgsversion.h

if exist CMakeCache.txt if exist skipcmake goto skipcmake

touch %SRCDIR%\CMakeLists.txt

echo CMAKE: %DATE% %TIME%
if errorlevel 1 goto error

if "%CMAKEGEN%"=="" set CMAKEGEN=Ninja

cmake -G "%CMAKEGEN%" ^
  -D CMAKE_CXX_COMPILER="%CMAKE_COMPILER_PATH:\=/%/cl.exe" ^
  -D CMAKE_C_COMPILER="%CMAKE_COMPILER_PATH:\=/%/cl.exe" ^
  -D CMAKE_LINKER="%CMAKE_COMPILER_PATH:\=/%/link.exe" ^
  -D CMAKE_BUILD_TYPE=%BUILDCONF% ^
  -D CMAKE_CONFIGURATION_TYPES=%BUILDCONF% ^
  -D CMAKE_CXX_FLAGS_RELWITHDEBINFO="/MD /Zi /MP /Od /D NDEBUG" ^
  -D CMAKE_INSTALL_PREFIX=%O4W_ROOT%/apps/qgis ^
  -D CMAKE_PDB_OUTPUT_DIRECTORY_RELWITHDEBINFO=%BUILDDIR%\apps\qgis\pdb ^
  -D CMAKE_PREFIX_PATH="%CONDA_ROOT%;%O4W_ROOT%" ^
  -D BUILDNAME="qgis-%PKG_VERSION%-%WIN_SDK%-%VC_VER%-x64" ^
  -D SITE="osgeo-forge" ^
  -D PEDANTIC=TRUE ^
  -D ENABLE_TESTS=TRUE ^
  -D GEOS_LIBRARY=%O4W_ROOT%/lib/geos_c.lib ^
  -D SQLITE3_LIBRARY=%O4W_ROOT%/lib/sqlite3_i.lib ^
  -D SPATIALINDEX_LIBRARY=%O4W_ROOT%/lib/spatialindex-64.lib ^
  -D SPATIALITE_LIBRARY=%O4W_ROOT%/lib/spatialite_i.lib ^
  -D PYTHON_EXECUTABLE=%CONDA_ROOT%/python.exe ^
  -D PYTHON_INCLUDE_PATH=%CONDA_ROOT%/include ^
  -D PYTHON_LIBRARY=%CONDA_ROOT%/libs/%PYVER%.lib ^
  -D SIP_BINARY_PATH=%O4W_ROOT%/bin/sip.exe ^
  -D QT_BINARY_DIR=%O4W_ROOT%/bin ^
  -D QT_LIBRARY_DIR=%O4W_ROOT%/lib ^
  -D QT_HEADERS_DIR=%O4W_ROOT%/include/qt ^
  -D QCA_INCLUDE_DIR=%OSGEO4W_ROOT%\include\Qca-qt5\QtCrypto ^
  -D QCA_LIBRARY=%OSGEO4W_ROOT%\lib\qca-qt5.lib ^
  -D QSCINTILLA_LIBRARY=%OSGEO4W_ROOT%\lib\qscintilla2_qt5.lib ^
  -D QWT_INCLUDE_DIR=%O4W_ROOT%/include ^
  -D QWT_LIBRARY=%O4W_ROOT%/lib/qwt.lib ^
  -D FCGI_INCLUDE_DIR=%O4W_ROOT%/include ^
  -D FCGI_LIBRARY=%O4W_ROOT%/lib/libfcgi.lib ^
  -D ORACLE_INCLUDEDIR=%O4W_ROOT%/include/oci ^
  -D ORACLE_LIBDIR=%O4W_ROOT%/lib ^
  -D WITH_QSPATIALITE=TRUE ^
  -D WITH_3D=TRUE ^
  -D WITH_SERVER=FALSE ^
  -D SERVER_SKIP_ECW=TRUE ^
  -D WITH_ASTYLE=TRUE ^
  -D WITH_TOUCH=TRUE ^
  -D WITH_ORACLE=TRUE ^
  -D WITH_GLOBE=FALSE ^
  -D WITH_GRASS=TRUE ^
  -D WITH_GRASS7=TRUE ^
  -D GRASS_PREFIX7=%GRASS_ROOT% ^
  -D GRASS_INCLUDE_DIR7=%GRASS_ROOT%/include ^
  -D WITH_CUSTOM_WIDGETS=TRUE ^
  -D WITH_INTERNAL_JINJA2=FALSE ^
  -D WITH_INTERNAL_MARKUPSAFE=FALSE ^
  -D WITH_INTERNAL_PYGMENTS=FALSE ^
  -D WITH_INTERNAL_DATEUTIL=FALSE ^
  -D WITH_INTERNAL_PYTZ=FALSE ^
  -D WITH_INTERNAL_SIX=FALSE ^
  -D SETUPAPI_LIBRARY=%SETUPAPI_LIBRARY% ^
  -D CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_NO_WARNINGS=TRUE ^
  ..
if errorlevel 1 (echo cmake failed & goto error)

REM This needs to exit with 1, to kill 'conda build' but preserve build envs
if "%CONFIGONLY%"=="1" (echo Exiting after configuring build directory: %CD% & exit /b 1)

:skipcmake
if exist ..\noclean (echo skip clean & goto skipclean)
echo CLEAN: %DATE% %TIME%
cmake --build %BUILDDIR% --target clean --config %BUILDCONF%
if errorlevel 1 (echo clean failed & goto error)

:skipclean
if exist ..\skipbuild (echo skip build & goto skipbuild)
echo ALL_BUILD: %DATE% %TIME%
cmake --build %BUILDDIR% --config %BUILDCONF%
if errorlevel 1 cmake --build %BUILDDIR% --config %BUILDCONF%
if errorlevel 1 (echo build failed twice & goto error)

:skipbuild
if exist ..\skiptests goto skiptests

echo RUNNING TESTS: %DATE% %TIME%

reg add "HKCU\Software\Microsoft\Windows\Windows Error Reporting" /v DontShow /t REG_DWORD /d 1 /f

set oldtemp=%TEMP%
set oldtmp=%TMP%
set oldpath=%PATH%

set TEMP=%TEMP%\qgis-x64
set TMP=%TEMP%
if exist "%TEMP%" rmdir /s /q "%TEMP%"
mkdir "%TEMP%"

path %PATH%;%BUILDDIR%\output\plugins;%GISBASE%\lib
set QT_PLUGIN_PATH=%BUILDDIR%\output\plugins;%OSGEO4W_ROOT%\plugins

cmake --build %BUILDDIR% --target Experimental --config %BUILDCONF%
if errorlevel 1 echo TESTS WERE NOT SUCCESSFUL.

set TEMP=%oldtemp%
set TMP=%oldtmp%
PATH %oldpath%

:skiptests

if exist "%PKGDIR%" (
	echo REMOVE: %DATE% %TIME%
	rmdir /s /q "%PKGDIR%"
)

echo INSTALL: %DATE% %TIME%
cmake --build %BUILDDIR% --target install --config %BUILDCONF%
if errorlevel 1 (echo INSTALL failed & goto error)

:package
echo PACKAGE: %DATE% %TIME%

move %PKGDIR%\bin\qgis.exe %OSGEO4W_ROOT%\bin\qgis-bin.exe
if errorlevel 1 (echo move of desktop executable failed & goto error)
copy /y qgis.vars %OSGEO4W_ROOT%\bin\qgis-bin.vars
if errorlevel 1 (echo copy of desktop executable vars failed & goto error)

rem move QGIS SQL plugins out of standard install prefixes to qgis dir
if not exist %PKGDIR%\qtplugins\sqldrivers mkdir %PKGDIR%\qtplugins\sqldrivers
move %OSGEO4W_ROOT%\plugins\sqldrivers\qsqlocispatial.dll %PKGDIR%\qtplugins\sqldrivers
if errorlevel 1 (echo move of oci sqldriver failed & goto error)
move %OSGEO4W_ROOT%\plugins\sqldrivers\qsqlspatialite.dll %PKGDIR%\qtplugins\sqldrivers
if errorlevel 1 (echo move of spatialite sqldriver failed & goto error)

rem move PyQGIS custom widget support out of standard install prefixes to qgis dir
if not exist %PKGDIR%\qtplugins\designer mkdir %PKGDIR%\qtplugins\designer
move %OSGEO4W_ROOT%\plugins\designer\qgis_customwidgets.dll %PKGDIR%\qtplugins\designer
if errorlevel 1 (echo move of customwidgets failed & goto error)

if not exist %PKGDIR%\python\PyQt5\uic\widget-plugins mkdir %PKGDIR%\python\PyQt5\uic\widget-plugins
move %PYTHONHOME%\Lib\site-packages\PyQt5\uic\widget-plugins\qgis_customwidgets.py %PKGDIR%\python\PyQt5\uic\widget-plugins
if errorlevel 1 (echo move of customwidgets binding failed & goto error)


rem #################### Post-build-install ####################

pushd "%RECIPE_DIR%\postinstall"

  REM Add bin wrapper and env scripts
  xcopy /y /r /i bin\*.bat "%OSGEO4W_ROOT%\bin\"
  copy /y bin\qgis-bin.vars "%OSGEO4W_ROOT%\bin\qgis-bin.vars"

  REM File ext/icon association setup, to be run on post-link
  copy /y qgis\qgis.reg.tmpl "%PKGDIR%\bin\qgis.reg.tmpl"

  REM Add init_scripts support
  if not exist "%PKGDIR%\init_scripts" mkdir "%PKGDIR%\init_scripts"
  copy /y "qgis\init_scripts\README.md" "%PKGDIR%\init_scripts\README.md"
  if not exist "%PKGDIR%\init_scripts\examples" mkdir "%PKGDIR%\init_scripts\examples"
  xcopy /y /r /i "qgis\init_scripts\examples\*" "%PKGDIR%\init_scripts\examples\"
  REM IMPORTANT: don't put init_scripts.py INSIDE the init_scripts dir upon install
  copy /y "qgis\init_scripts.py" "%PKGDIR%\init_scripts.py"

popd

REM Delete any python cache files
del /s /q "%OSGEO4W_ROOT%\apps\qgis\python\*.pyc"
del /s /q "%OSGEO4W_ROOT%\apps\qgis\python\*.pyo"

REM Alternative, using python3
REM pushd "%OSGEO4W_ROOT%\apps\qgis"
REM   python.exe -c "import pathlib; [p.unlink() for p in pathlib.Path('.').rglob('*.py[co]')]"
REM popd

if errorlevel 1 (echo delete of python cache files failed & goto error)

REM Set up link scripts
copy /y "%RECIPE_DIR%\scripts\post-link.bat" "%SCRIPTS%\.%PKG_NAME%-post-link.bat"
if errorlevel 1 (echo copy of post-link script failed & goto error)

copy /y "%RECIPE_DIR%\scripts\pre-unlink.bat" "%SCRIPTS%\.%PKG_NAME%-pre-unlink.bat"
if errorlevel 1 (echo copy of pre-unlink script failed & goto error)

rem #################### Start Post-customize ####################
if defined QGIS_POST_CUSTOMIZE_DIR if exist "%QGIS_POST_CUSTOMIZE_DIR%" (
  pushd "%QGIS_POST_CUSTOMIZE_DIR%"
    for %%G in ("*.bat") do call "%%G"
  popd
)
rem #################### End Post-customize ####################

goto end

:error
echo Failed with error #%errorlevel%.
exit /b 1

:end
echo FINISHED: %DATE% %TIME%

endlocal
