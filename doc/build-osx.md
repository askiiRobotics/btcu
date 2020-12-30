# macOS Build Instructions and Notes

The commands in this guide should be executed in a Terminal application.
The built-in one is located in
```
/Applications/Utilities/Terminal.app
```

## Prerequisites
In order to build BTCU on Mac it is required to have a MacOS computer, with at least 3GB of free disk space (some of the dependencies will require more space, but you may have these installed already) without the database.

## Preparation
The next step is required only if you don't have an already instaled XCode. Otherwise you may skip it.
Install the macOS command line tools:

```shell
xcode-select --install
```

When the popup appears, click `Install`.
You can check the [detailed installation guide](https://www.ics.uci.edu/~pattis/common/handouts/macmingweclipse/allexperimental/macxcodecommandlinetools.html) for a proper explanation.

Then you will need to install the [Homebrew](https://brew.sh). If you already have it on a computer you may skip it.

To check it you can run the followed command:

```shell
brew --version
```

If it throws an error, you don't have homebrew. In that case, install homebrew using the following command.
```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/ install.sh)"
```

It is important:  Even if you had homebrew installed beforehand, update your version of homebrew and upgrade all the packages it installed by running the following command.
```shell
brew update && brew upgrade
```

If you run into issues, please check [Homebrew's Troubleshooting page](https://docs.brew.sh/Troubleshooting).

## Dependencies
```shell
brew install automake libtool miniupnpc pkg-config python qt libevent qrencode jsoncpp protobuf rocksdb snappy zeromq openssl libjson-rpc-cpp google-benchmark googletest
# libscrypt from local since we need a version with cmake support but you still can get it via brew

# since brew has been removed the required version of the boost
curl https://raw.githubusercontent.com/Homebrew/homebrew-core/8d748e26ccc9afc8ea0d0201ae234fda35de721e/Formula/boost.rb -o boost.rb
brew install ./boost.rb
```

OpenSSL has it's uniq way to organize a folder structure so we have to try this command at first:
```shell
brew link openssl --force
```
If you'll get a refuse result such as "Warning: Refusing to link macOS provided/shadowed software: openssl", you'll have to call this command instead:
```shell
( brew --prefix openssl && echo '/include/openssl'; ) | tr -d "[:space:]" | xargs -I '{}' ln -s {} /usr/local/include
```

Also it may be usefull to add openssl bin folder to PATH as it recommended by result of the command "brew link openssl --force".

See [dependencies.md](dependencies.md) for a complete overview.

If you want to build the disk image with `make deploy` (.dmg / optional), you need RSVG:
```shell
brew install librsvg
```
NOTE: The option is currently unavailable.

Also it is important to have the exact version of the icu4c:
```shell
brew uninstall --ignore-dependencies icu4c
curl https://raw.githubusercontent.com/Homebrew/homebrew-core/a806a621ed3722fb580a58000fb274a2f2d86a6d/Formula/icu4c.rb -o icu4c.rb
brew install ./icu4c.rb
```

### Libscrypt
As a prerequisite it is also required to make libscrypt.a file. In order to do this you have to run followed commands:

```shell
cd src/libscrypt
cmake .
make
```

### Ethash
As an another prerequisite it is required to make libethash.a file. In order to do this you have to run followed commands:

```shell
cd src/cpp-ethereum/ethash
cmake .
make
```

### Cryptopp
And an another prerequisite that is also required is a libcryptopp.a file. In order to do this you have to run followed commands:

```shell
cd src/cryptopp
cmake .
make
```

### Secp256k1
And for a libunivalue.a file:

```shell
cd src/secp256k1
make
```

### Univalue
And for a libsecp256k1.a file:

```shell
cd src/univalue
make
```

#### SQLite

Usually, macOS installation already has a suitable SQLite installation.
In order to check is there an installed SQLite you may run a command:

```shell
sqlite3 --version
```

If you haven't SQLite installed it can be solved by the Homebrew package:

```shell
brew install sqlite
```

In that case the Homebrew package will prevail.

#### Berkeley DB

It is recommended to use Berkeley DB 18.1.32. If you have to build it yourself,
you can use [this](/contrib/install_db4.sh) script to install it
like so:

```shell
./contrib/install_db4.sh .
```

from the root of the repository.

Also, the Homebrew package could be installed:

```shell
brew install berkeley-db@18
```

The project is configured with the dependency Berkeley DB v18.1.32. In order to check the version you can run:
```shell
brew info berkeley-db 
```

If the brew installed a different version run the followed command:
```shell
# since brew switch is depreceted it is required to use workaround
brew uninstall berkeley-db@18
# since brew prohibited to use Git commits urls in install command
curl https://raw.githubusercontent.com/Homebrew/homebrew-core/f325e0637fbf513819129744dc107382de028fc5/Formula/berkeley-db.rb -o berkeley-db.rb
brew install ./berkeley-db.rb
```

## Build BTCU

1. Clone the BTCU source code:
    ```shell
    git clone https://github.com/btcu-ultimatum/btcu
    cd btcu
    ```
2.  Make the Homebrew OpenSSL headers visible to the configure script  (do ```brew info openssl``` to find out why this is necessary, or if you use Homebrew with installation folders different from the default).

        export LDFLAGS="$LDFLAGS -L/usr/local/opt/openssl/lib"
        export CPPFLAGS="$CPPFLAGS -I/usr/local/opt/openssl/include"

    Same applied for jsoncpp but with a slight difference: the result of a command ```brew  --prefix jsoncpp ``` will be placed to LDFLAGS with '/lib' prefix and to CPPFLAGS with '/include' prefix. The common result will be like that:

        export LDFLAGS="$LDFLAGS -L/usr/local/opt/jsoncpp/lib"
        export CPPFLAGS="$CPPFLAGS -I/usr/local/opt/jsoncpp/include"

3.  Build BTCU

    Configure and build the headless BTCU binaries as well as the GUI (if Qt is found).

    You can disable the GUI build by passing `--without-gui` to configure.

    The wallet support requires one or both of the dependencies ([*SQLite*](#sqlite) and [*Berkeley DB*](#berkeley-db)) from the previous section.
    To build BTCU without wallet, see [*Disable-wallet mode*](#disable-wallet-mode).

    To build the project run followed commands:
    ```shell
    ./autogen.sh
    ./configure
    cmake .
    make
    ```

4.  It is recommended to build and run the unit tests:
    ```shell
    make check
    ```

## Disable-wallet mode
When the intention is to run only a P2P node without a wallet, BTCU may be
compiled in disable-wallet mode with:
```shell
./configure --disable-wallet
```

In this case there is no dependency on [*Berkeley DB*](#berkeley-db) and [*SQLite*](#sqlite).

Mining is also possible in disable-wallet mode using the `getblocktemplate` RPC call.

## Running
BTCU is now available at `./btcud`

Before running, you may create an empty configuration file:
```shell
mkdir -p "/Users/${USER}/Library/Application Support/BTCU"

touch "/Users/${USER}/Library/Application Support/BTCU/btcu.conf"

chmod 600 "/Users/${USER}/Library/Application Support/BTCU/btcu.conf"
```

The first time you run btcud, it will start downloading the blockchain. This process could
take many hours, or even days on slower than average systems.

You can monitor the download process by looking at the debug.log file:
```shell
tail -f $HOME/Library/Application\ Support/BTCU/debug.log
```

## Other commands:
```shell
btcud -daemon      # Starts the btcu daemon.
btcu-cli --help    # Outputs a list of command-line options.
btcu-cli help      # Outputs a list of RPC commands when the daemon is running.
./src/qt/btcu-qt   # Start GUI
```

## Notes
* Tested on OS X 11.1 Big Sur on 64-bit Intel processors only.
* Note: `.dmg` build is currently unsupported
