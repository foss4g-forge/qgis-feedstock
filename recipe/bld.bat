setlocal enabledelayedexpansion

set BUILDDIR=%SRC_DIR%\build
if not exist "%BUILDDIR%" mkdir %BUILDDIR%
if not exist "%BUILDDIR%" (echo could not create build directory %BUILDDIR% & goto error)

set "CONDA_ROOT=%PREFIX%"

if not exist "%LIBRARY_PREFIX%\bin\o4w_env.bat" (echo o4w_env.bat not found & goto error)
REM Calling o4w_env.bat (~ osgf_env.bat), within a conda-build context, reactivates
REM _h_env activate.d scripts (clobbered by conda-build's _build_env final activation),
REM so we can (re)populate relevant dependency package env vars, e.g. GDAL_DATA, etc.
REM Sets the following env vars:
REM   OSGEO4W_ROOT=LIBRARY_PREFIX (though LIBRARY_PREFIX should be used when possible)
REM   LIBRARY_PREFIX_SHORT, LIBRARY_PREFIX_SHORT, LIBRARY_PREFIX_SHORT_POSIX
REM   CONDA_ROOT, CONDA_ROOT_POSIX, CONDA_ROOT_SHORT, CONDA_ROOT_SHORT_POSIX
REM   PF, PF_SHORT, PF86, PF86_SHORT
call "%LIBRARY_PREFIX%\bin\o4w_env.bat"
call "%LIBRARY_PREFIX%\bin\grass_env.bat"
REM Sets: PYTHONHOME; Clears: PYTHONPATH
call "%LIBRARY_PREFIX%\bin\py3_env.bat"
call "%LIBRARY_PREFIX%\bin\qt5_env.bat"

REM set PYVER=pythonXX, from PY_VER, e.g. 3.7 to python37
set "PYVER=python%PY_VER:~0,1%%PY_VER:~2,1%"

set LIB_DIR=%LIBRARY_PREFIX_POSIX%

set "CMAKE_COMPILER_PATH=%PF86%\Microsoft Visual Studio 14.0\VC\bin\amd64"
set VC_VER=vc14
set WIN_SDK=win81sdk
set "SETUPAPI_LIBRARY=%PF86%\Windows Kits\8.0\Lib\win8\um\x64\SetupAPI.Lib"

set BUILDCONF=RelWithDebInfo

if errorlevel 1 goto error

rem #################### Start Pre-customize ####################
if defined QGIS_PRE_CUSTOMIZE_DIR if exist "%QGIS_PRE_CUSTOMIZE_DIR%" (
  pushd "%QGIS_PRE_CUSTOMIZE_DIR%"
    for %%G in ("*.bat") do call "%%G"
  popd
)
rem #################### End Pre-customize ####################


if "%BUILDDIR:~1,1%"==":" %BUILDDIR:~0,2%
cd /D %BUILDDIR%

set PKGDIR=%LIBRARY_PREFIX_SHORT%\apps\qgis

echo "######### Current env; also dumping to build\env-conda.txt #########"
set
set > env-conda.txt

if exist repackage goto package


echo BEGIN: %DATE% %TIME%

if exist CMakeCache.txt if exist skipcmake goto skipcmake

if exist qgsversion.h del qgsversion.h

if exist CMakeCache.txt del /q CMakeCache.txt
type nul >> "%SRC_DIR%\CMakeLists.txt"

echo CMAKE: %DATE% %TIME%
if errorlevel 1 goto error

if "%CMAKEGEN%"=="" set CMAKEGEN=Ninja

cmake -G "%CMAKEGEN%" ^
  -D CMAKE_CXX_COMPILER="%CMAKE_COMPILER_PATH:\=/%/cl.exe" ^
  -D CMAKE_C_COMPILER="%CMAKE_COMPILER_PATH:\=/%/cl.exe" ^
  -D CMAKE_LINKER="%CMAKE_COMPILER_PATH:\=/%/link.exe" ^
  -D CMAKE_BUILD_TYPE=%BUILDCONF% ^
  -D CMAKE_CONFIGURATION_TYPES=%BUILDCONF% ^
  -D CMAKE_C_FLAGS:STRING="-MD /DWIN32 /D_WINDOWS /W3" ^
  -D CMAKE_CXX_FLAGS:STRING="-MD /DWIN32 /D_WINDOWS /W3 /GR /EHsc" ^
  -D CMAKE_CXX_FLAGS_RELWITHDEBINFO="/MD /Zi /MP /Od /D NDEBUG" ^
  -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX_POSIX%/apps/qgis ^
  -D CMAKE_PDB_OUTPUT_DIRECTORY_RELWITHDEBINFO=%BUILDDIR%\apps\qgis\pdb ^
  -D CMAKE_PREFIX_PATH="%LIBRARY_PREFIX_POSIX%;%CONDA_ROOT_POSIX%;%BUILD_PREFIX:\=/%" ^
  -D BUILDNAME="qgis-%PKG_VERSION%-%WIN_SDK%-%VC_VER%-x64" ^
  -D SITE="osgeo-forge" ^
  -D PEDANTIC=TRUE ^
  -D ENABLE_TESTS=TRUE ^
  -D GEOS_LIBRARY=%LIBRARY_PREFIX_POSIX%/lib/geos_c.lib ^
  -D SQLITE3_LIBRARY=%LIBRARY_PREFIX_POSIX%/lib/sqlite3.lib ^
  -D SPATIALINDEX_LIBRARY=%LIBRARY_PREFIX_POSIX%/lib/spatialindex-64.lib ^
  -D SPATIALITE_LIBRARY=%LIBRARY_PREFIX_POSIX%/lib/spatialite_i.lib ^
  -D PYTHON_EXECUTABLE=%CONDA_ROOT_POSIX%/python.exe ^
  -D SIP_BINARY_PATH=%LIBRARY_PREFIX_POSIX%/bin/sip.exe ^
  -D QT_BINARY_DIR=%LIBRARY_PREFIX_POSIX%/bin ^
  -D QT_LIBRARY_DIR=%LIBRARY_PREFIX_POSIX%/lib ^
  -D QT_HEADERS_DIR=%LIBRARY_PREFIX_POSIX%/include/qt ^
  -D QCA_INCLUDE_DIR=%LIBRARY_PREFIX%\include\Qca-qt5\QtCrypto ^
  -D QCA_LIBRARY=%LIBRARY_PREFIX%\lib\qca-qt5.lib ^
  -D QSCINTILLA_LIBRARY=%LIBRARY_PREFIX%\lib\qscintilla2_qt5.lib ^
  -D QWT_INCLUDE_DIR=%LIBRARY_PREFIX_POSIX%/include ^
  -D QWT_LIBRARY=%LIBRARY_PREFIX_POSIX%/lib/qwt.lib ^
  -D FCGI_INCLUDE_DIR=%LIBRARY_PREFIX_POSIX%/include ^
  -D FCGI_LIBRARY=%LIBRARY_PREFIX_POSIX%/lib/libfcgi.lib ^
  -D ORACLE_INCLUDEDIR=%LIBRARY_PREFIX_POSIX%/include/oci ^
  -D ORACLE_LIBDIR=%LIBRARY_PREFIX_POSIX%/lib ^
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
  -D GRASS_PREFIX7=%GRASS_PREFIX_POSIX% ^
  -D GRASS_INCLUDE_DIR7=%GRASS_PREFIX_POSIX%/include ^
  -D WITH_CUSTOM_WIDGETS=TRUE ^
  -D WITH_INTERNAL_JINJA2=FALSE ^
  -D WITH_INTERNAL_MARKUPSAFE=FALSE ^
  -D WITH_INTERNAL_PYGMENTS=FALSE ^
  -D WITH_INTERNAL_DATEUTIL=FALSE ^
  -D WITH_INTERNAL_PYTZ=FALSE ^
  -D WITH_INTERNAL_SIX=FALSE ^
  -D SETUPAPI_LIBRARY="%SETUPAPI_LIBRARY%" ^
  -D CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_NO_WARNINGS=TRUE ^
  ..
if errorlevel 1 (echo cmake failed & goto error)

REM This needs to exit with 1, to kill 'conda build' but preserve build envs
if "%CONFIGONLY%"=="1" (echo Exiting after configuring build directory: %CD% & exit /b 1)

:skipcmake
if exist ..\skipclean (echo skip clean & goto skipclean)
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
REM if exist ..\skiptests goto skiptests
goto skiptests

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
set "QT_PLUGIN_PATH=%BUILDDIR%\output\plugins;%LIBRARY_PREFIX%\plugins"

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

REM Cleanup files installed eslewhere within prefix; move to apps\qgis\

move %PKGDIR%\bin\qgis.exe %LIBRARY_PREFIX_SHORT%\bin\qgis-bin.exe
if errorlevel 1 (echo move of desktop executable failed & goto error)

REM Move QGIS SQL plugins out of standard install prefixes to qgis dir
if not exist %PKGDIR%\qtplugins\sqldrivers mkdir %PKGDIR%\qtplugins\sqldrivers
move %LIBRARY_PREFIX_SHORT%\plugins\sqldrivers\qsqlocispatial.dll %PKGDIR%\qtplugins\sqldrivers
if errorlevel 1 (echo move of oci sqldriver failed & goto error)
move %LIBRARY_PREFIX_SHORT%\plugins\sqldrivers\qsqlspatialite.dll %PKGDIR%\qtplugins\sqldrivers
if errorlevel 1 (echo move of spatialite sqldriver failed & goto error)

REM Move PyQGIS custom widget support out of standard install prefixes to qgis dir
if not exist %PKGDIR%\qtplugins\designer mkdir %PKGDIR%\qtplugins\designer
move %LIBRARY_PREFIX_SHORT%\plugins\designer\qgis_customwidgets.dll %PKGDIR%\qtplugins\designer
if errorlevel 1 (echo move of customwidgets failed & goto error)

if not exist %PKGDIR%\python\PyQt5\uic\widget-plugins mkdir %PKGDIR%\python\PyQt5\uic\widget-plugins
move %PYTHONHOME%\Lib\site-packages\PyQt5\uic\widget-plugins\qgis_customwidgets.py %PKGDIR%\python\PyQt5\uic\widget-plugins
if errorlevel 1 (echo move of customwidgets binding failed & goto error)

rem #################### Post-build-install ####################

pushd "%RECIPE_DIR%\postinstall"

  REM Add bin wrapper and env scripts
  xcopy /y /r /i bin\*.bat %LIBRARY_PREFIX_SHORT%\bin\
  copy /y bin\qgis-bin.vars %LIBRARY_PREFIX_SHORT%\bin\qgis-bin.vars

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
del /s /q "%LIBRARY_PREFIX%\apps\qgis\python\*.pyc"
del /s /q "%LIBRARY_PREFIX%\apps\qgis\python\*.pyo"

REM Alternative, using python3
REM pushd "%LIBRARY_PREFIX%\apps\qgis"
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
