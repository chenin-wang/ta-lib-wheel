#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status.

# Check required environment variables
if [ -z "$TALIB_C_VER" ]; then
    echo "ERROR: TALIB_C_VER environment variable not set"
    exit 1
fi
if [ -z "$TALIB_PY_VER" ]; then
    echo "ERROR: TALIB_PY_VER environment variable not set"
    exit 1
fi

echo "Building with TA-Lib C version: $TALIB_C_VER"
echo "Building for TA-Lib Python version: $TALIB_PY_VER"

# Download TA-Lib C source code
echo "Downloading TA-Lib C source code (v$TALIB_C_VER)..."
curl -L -o talib-c.zip "https://github.com/TA-Lib/ta-lib/archive/refs/tags/v$TALIB_C_VER.zip"

# Extract TA-Lib C source code
echo "Extracting TA-Lib C source..."
unzip -o talib-c.zip

# Download TA-Lib Python source code
echo "Downloading TA-Lib Python source code (v$TALIB_PY_VER)..."
curl -L -o talib-python.zip "https://github.com/TA-Lib/ta-lib-python/archive/refs/tags/TA_Lib-$TALIB_PY_VER.zip"

# Extract TA-Lib Python source code directly into the current directory
echo "Extracting TA-Lib Python source..."
unzip -o talib-python.zip -d .

# Build TA-Lib C library
echo "Building TA-Lib C library..."
pushd "ta-lib-$TALIB_C_VER"

# Create ta-lib subdirectory and copy header files (if necessary)
mkdir -p include/ta-lib
cp -r include/* include/ta-lib

# Create build directory
mkdir -p _build
pushd _build

# Configure and build (adjust these commands as needed for TA-Lib on Linux)
./configure --prefix="$PWD/install"  # Example: Install to a local directory
make
make install # install to the local directory

# Copy the library and headers to standard location
# Assuming install was successful in the previous command
cp install/lib/* ../_build/
cp -r install/include/* ../include/

popd
popd

echo "TA-Lib build completed successfully."
echo "TA-Lib C library: ta-lib-$TALIB_C_VER/_build/libta-lib.so" #  Linux shared library
echo "TA-Lib Include: ta-lib-$TALIB_C_VER/include"

exit 0