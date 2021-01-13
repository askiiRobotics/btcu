#!/bin/bash
echo "[0%] Updating apt-get..."
sudo apt-get update 
echo "[5%] Upgrading apt-get..."
sudo apt-get upgrade
echo "[10%] Finished."

install_package () {
    REQUIRED_PKG="$1"
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
    if [ "" = "$PKG_OK" ]; then
    sudo apt-get --yes install $REQUIRED_PKG 
    fi
}

uninstall_package () {
    REQUIRED_PKG="$1"
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
    if [ "install ok installed" = "$PKG_OK" ]; then
    sudo apt remove --purge --auto-remove $REQUIRED_PKG
    fi
}

echo "[11%] Installing dependency: cmake... "

install_package cmake

echo -ne  "Done!"

echo "[12%] Installing dependency: git... "

install_package git

echo -ne  "Done!"

echo "[13%] Installing dependency: libboost-all-dev... "

install_package libboost-all-dev

echo -ne  "Done!"

echo "[14%] Installing dependency: build-essential... "

install_package build-essential

echo -ne  "Done!"

echo "[15%] Installing dependency: libtool... "

install_package libtool

echo -ne  "Done!"

echo "[16%] Installing dependency: bsdmainutils... "

install_package bsdmainutils

echo -ne  "Done!"

echo "[17%] Installing dependency: autotools-dev... "

install_package autotools-dev

echo -ne  "Done!"

echo "[18%] Installing dependency: autoconf... "

install_package autoconf

echo -ne  "Done!"

echo "[19%] Installing dependency: pkg-config... "

install_package pkg-config

echo -ne  "Done!"

echo "[20%] Installing dependency: automake... "

install_package automake

echo -ne  "Done!"

echo "[21%] Installing dependency: python3... "

install_package python3

echo -ne  "Done!"

echo "[22%] Installing dependency: libminiupnpc-dev... "

install_package libminiupnpc-dev

echo -ne  "Done!"

echo "[23%] Installing dependency: libzmq3-dev... "

install_package libzmq3-dev

echo -ne  "Done!"

echo "[24%] Installing dependency: librocksdb-dev... "

install_package librocksdb-dev

echo -ne  "Done!"

echo "[25%] Installing dependency: libssl-dev... "

install_package libssl-dev

echo -ne  "Done!"

echo "[26%] Installing dependency: libgmp-dev... "

install_package libgmp-dev

echo -ne  "Done!"

echo "[27%] Installing dependency: libevent-dev... "

install_package libevent-dev

echo -ne  "Done!"

echo "[28%] Installing dependency: libjsonrpccpp-dev... "

install_package libjsonrpccpp-dev

echo -ne  "Done!"

echo "[29%] Installing dependency: libsnappy-dev... "

install_package libsnappy-dev

echo -ne  "Done!"

echo "[30%] Installing dependency: libbenchmark-dev... "

install_package libbenchmark-dev

echo -ne  "Done!"

echo "[31%] Installing dependency: libgtest-dev... "

install_package libgtest-dev

echo -ne  "Done!"

echo "[32%] Configuring GTest... "

cd /usr/src/googletest
sudo cmake .
sudo cmake --build . --target install
cd -

echo "Done!"

echo "[32%] Checking Berkeley DB... "

uninstall_package libdb-dev

uninstall_package libdb++-dev

echo -ne  "Done!"

echo "[33%] Installing dependency: libprotobuf-dev... "

install_package libprotobuf-dev

echo -ne  "Done!"

echo "[34%] Installing dependency: protobuf-compiler... "

install_package protobuf-compiler

echo -ne  "Done!"

echo "[35%] Installing dependency: libqrencode-dev... "

install_package libqrencode-dev

echo -ne  "Done!"

echo "[36%] Installing dependency: libpng-dev... "

install_package libpng-dev

echo -ne  "Done!"

echo "[39%] Installing QT Components. "

echo "[40%] Installing QT dependency: libqt5gui5... "

install_package libqt5gui5

echo -ne  "Done!"

echo "[41%] Installing QT dependency: libqt5core5a... "

install_package libqt5core5a

echo -ne  "Done!"

echo "[42%] Installing QT dependency: libqt5dbus5... "

install_package libqt5dbus5

echo -ne  "Done!"

echo "[43%] Installing QT dependency: qttools5-dev... "

install_package qttools5-dev

echo -ne  "Done!"

echo "[44%] Installing QT dependency: qttools5-dev-tools... "

install_package qttools5-dev-tools

echo -ne  "Done!"

echo "[45%] Installing QT dependency: libqt5svg5-dev... "

install_package libqt5svg5-dev

echo -ne  "Done!"

echo "[46%] Installing QT dependency: libqt5charts5-dev... "

install_package libqt5charts5-dev

echo -ne  "Done!"

echo "[47%] All QT Components has been installed. "

echo "[50%] Checking is folder the git repository... "
if [ -d .git ]; then
echo -ne  "yes"
    if [ "$1" = "update" ]
    then
    echo "[50%] Updating current version of the BTCU"
    git checkout master 

    if [ -s "versions.txt" ]
        then
            file="versions.txt"
            l=""

            while IFS= read line
            do
            l=$line
            done <"$file"

            my_var="$( cut -d ' ' -f 2 <<< "$l" )";
            echo "[51%] Working branch: release_$my_var"
            git checkout "release_$my_var"
        else
            echo "[51%] Working branch: master"
        fi

    git pull
    echo  "Done!"

    else 
    echo "[50%] Updating current version of the BTCU"
    echo "[51%] Working branch: master"
    git checkout master 
    git pull
    echo  "Done!"
    fi
else
    echo -ne  "no"
    echo "[50%] Downloading latest version of the BTCU... "
    git clone https://github.com/btcu-ultimatum/btcu
    cd btcu
    echo  "Done!"
fi;

echo "[60%] Installing Berkeley DB... "

# Since as of 5th March 2020 the Oracle moved Barkeley DB 
# to login-protected tarball for 18.1.32 version 
# we added the dependency as a static file included in the repository.
# You can check the details in depends/packages/static/berkeley-db-18.1.32/README.MD

tar zxvf depends/packages/static/berkeley-db-18.1.32/berkeley-db-18.1.32.tar.gz -C ./
cd  db-18.1.32/build_unix
../dist/configure --enable-cxx --disable-shared --disable-replication --with-pic --prefix=/opt
make

if [ -f /opt/lib/libdb-18.1.a ]
then
    sudo make uninstall
fi;

sudo make install
cd -

echo  "Done!"


echo "[65%] Running CMake configuring... "

cmake -G "CodeBlocks - Unix Makefiles" .

echo  "Done!"

echo "[75%] Building BTCU... "

make

echo  "Done!"

echo "[100%] Build is completed!"

echo ""
echo ""
echo ""

echo "=========================================================="
echo "The built binaries was placed in ./bin folder"
echo "For start daemon please run:"
echo "./bin/btcud -daemon"
echo "Outputs a list of command-line options:"
echo "./bin/btcu-cli --help"
echo "Outputs a list of RPC commands when the daemon is running:"
echo "./bin/btcu-cli help"
echo "Start GUI:"
echo "./src/qt/btcu-qt"
echo "=========================================================="