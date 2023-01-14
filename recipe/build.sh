# in case ther are any other previous builds
rm -rf $SRC_DIR/build
rm -rf $SRC_DIR/pgdata

mkdir -p $SRC_DIR/build
mkdir -p $SRC_DIR/pgdata

cd $SRC_DIR/build

cmake \
    -D CMAKE_POLICY_DEFAULT_CMP0074=NEW \
    -D RDK_BUILD_PGSQL=ON \
    -D RDK_PGSQL_STATIC=ON \
    -D RDK_INSTALL_INTREE=OFF \
    -D RDK_INSTALL_STATIC_LIBS=OFF \
    -D RDK_INSTALL_DEV_COMPONENT=OFF \
    -D RDK_BUILD_INCHI_SUPPORT=ON \
    -D RDK_BUILD_AVALON_SUPPORT=ON \
    -D RDK_BUILD_FREESASA_SUPPORT=OFF \
    -D RDK_USE_FLEXBISON=OFF \
    -D RDK_BUILD_THREADSAFE_SSS=ON \
    -D RDK_TEST_MULTITHREADED=ON \
    -D RDK_BUILD_CPP_TESTS=OFF \
    -D RDK_BUILD_PYTHON_WRAPPERS=OFF \
    -D CMAKE_SYSTEM_PERFIX_PATH=$PREFIX \
    -D CMAKE_INSTALL_PREFIX=$PREFIX \
    -D BOOST_ROOT=$PREFIX \
    -D Boost_NO_SYSTEM_PATHS=ON \
    -D Boost_NO_BOOST_CMAKE=ON \
    -D CMAKE_BUILD_TYPE=Release \
    ..

make -j$CPU_COUNT

cd ./Code/PgSQL/rdkit

/bin/bash -e ./pgsql_install.sh

export PGPORT=54321
export PGDATA=$SRC_DIR/pgdata

pg_ctl initdb
pg_ctl start -l $PGDATA/log.txt

sleep 2 # wait for server to start

set +e
ctest --output-on-failure
check_result=$?
set -e

pg_ctl stop

exit $check_result
