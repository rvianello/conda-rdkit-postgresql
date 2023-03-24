rmdir /S /Q %SRC_DIR%\build
rmdir /S /Q %SRC_DIR%\pgdata

mkdir %SRC_DIR%\build
mkdir %SRC_DIR%\pgdata

cd %SRC_DIR%\build

cmake ^
    -G "NMake Makefiles JOM" ^
    -D CMAKE_POLICY_DEFAULT_CMP0074=NEW ^
    -D RDK_BUILD_PGSQL=ON ^
    -D RDK_PGSQL_STATIC=ON ^
    -D RDK_INSTALL_INTREE=OFF ^
    -D RDK_INSTALL_STATIC_LIBS=OFF ^
    -D RDK_INSTALL_DEV_COMPONENT=OFF ^
    -D RDK_BUILD_INCHI_SUPPORT=ON ^
    -D RDK_BUILD_AVALON_SUPPORT=ON ^
    -D RDK_BUILD_FREESASA_SUPPORT=OFF ^
    -D RDK_USE_FLEXBISON=OFF ^
    -D RDK_BUILD_THREADSAFE_SSS=ON ^
    -D RDK_TEST_MULTITHREADED=ON ^
    -D RDK_BUILD_CPP_TESTS=OFF ^
    -D RDK_BUILD_PYTHON_WRAPPERS=OFF ^
    -D CMAKE_SYSTEM_PERFIX_PATH=%LIBRARY_PREFIX% ^
    -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -D BOOST_ROOT=%LIBRARY_PREFIX% ^
    -D Boost_NO_SYSTEM_PATHS=ON ^
    -D Boost_NO_BOOST_CMAKE=ON ^
    -D CMAKE_BUILD_TYPE=Release ^
    %SRC_DIR%
if errorlevel 1 exit 1

cmake --build . --parallel %CPU_COUNT% --config Release
if errorlevel 1 exit 1

cd %SRC_DIR%\build\Code\PgSQL\rdkit
if errorlevel 1 exit 1

pgsql_install.bat
if errorlevel 1 exit 1

set PGPORT=54321
set PGDATA=%SRC_DIR%\pgdata

pg_ctl initdb
if errorlevel 1 exit 1

pg_ctl start -l $PGDATA/log.txt
if errorlevel 1 exit 1

timeout 2 /NOBREAK

ctest --output-on-failure
if errorlevel 1 set TEST_ERROR=1

pg_ctl stop

if %TEST_ERROR% equ 1 exit 1