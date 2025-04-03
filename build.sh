#!/bin/bash
set -eo pipefail # Exit on error, catch pipe failures

# --- Configuration ---
# Expected directory name inside the C source zip (adjust if needed)
# Usually 'ta-lib-<version>' but GitHub might use 'ta-lib-<git-sha>' or just 'ta-lib' on some tags/branches
# Let's assume it's predictable based on the tag for simplicity here.
EXPECTED_C_SRC_DIR="ta-lib-$TALIB_C_VER"
# Expected directory name inside the Python source zip
EXPECTED_PY_SRC_DIR="ta-lib-python-TA_Lib-$TALIB_PY_VER"

# --- Check required environment variables ---
if [ -z "$TALIB_C_VER" ]; then
    echo "ERROR: TALIB_C_VER environment variable not set" >&2 # Redirect errors to stderr
    exit 1
fi
if [ -z "$TALIB_PY_VER" ]; then
    echo "ERROR: TALIB_PY_VER environment variable not set" >&2
    exit 1
fi

echo "Building with TA-Lib C version: $TALIB_C_VER"
echo "Building for TA-Lib Python version: $TALIB_PY_VER"
echo "Working directory: $(pwd)"

# --- Download C Source ---
C_ZIP_FILE="talib-c-v${TALIB_C_VER}.zip"
echo "Downloading TA-Lib C source code (v$TALIB_C_VER)..."
curl -L -o "$C_ZIP_FILE" "https://github.com/TA-Lib/ta-lib/archive/refs/tags/v$TALIB_C_VER.zip"

# --- Extract C Source ---
echo "Extracting TA-Lib C source ($C_ZIP_FILE)..."
unzip -o "$C_ZIP_FILE"
# Verify the expected directory exists
if [ ! -d "$EXPECTED_C_SRC_DIR" ]; then
    echo "ERROR: Extracted C source directory '$EXPECTED_C_SRC_DIR' not found!" >&2
    echo "Contents of current directory:"
    ls -la
    # Attempt to find the actual directory name (common pattern)
    ACTUAL_C_SRC_DIR=$(find . -maxdepth 1 -type d -name 'ta-lib*' ! -name "$EXPECTED_PY_SRC_DIR" -print -quit)
    if [ -n "$ACTUAL_C_SRC_DIR" ] && [ -d "$ACTUAL_C_SRC_DIR" ; then
         echo "Found potential directory: $ACTUAL_C_SRC_DIR. Please adjust EXPECTED_C_SRC_DIR in the script." >&2
    fi
    exit 1
fi
echo "Found C source directory: $EXPECTED_C_SRC_DIR"

# --- Build TA-Lib C library (Locally) ---
echo "Building TA-Lib C library inside $EXPECTED_C_SRC_DIR..."
# Store the absolute path before changing directory
C_BUILD_DIR="$(pwd)/$EXPECTED_C_SRC_DIR/build/lib" # Assuming make puts libs here
C_INCLUDE_DIR="$(pwd)/$EXPECTED_C_SRC_DIR/include" # Assuming configure puts headers here

pushd "$EXPECTED_C_SRC_DIR" # Change into C source directory

# Configure to build without installing globally
# Common practice is to build within the source tree
# Adjust configure flags if needed (e.g., --prefix=$(pwd)/build to install locally if desired)
./configure --prefix=$(pwd)/build # Configure to install into a local 'build' subdirectory

# Build the library
make

# Install into the local prefix specified above (no sudo needed)
make install

popd # Return to the original directory

# --- Export Environment Variables for Python Build ---
# These variables tell the TA-Lib Python setup.py where to find the C library
# The exact names (TA_LIBRARY_PATH, TA_INCLUDE_PATH) depend on TA-Lib Python's setup.py logic. Verify them!
export TA_INCLUDE_PATH="${C_INCLUDE_DIR}"
export TA_LIBRARY_PATH="${C_BUILD_DIR}"
echo "Exported TA_INCLUDE_PATH=${TA_INCLUDE_PATH}"
echo "Exported TA_LIBRARY_PATH=${TA_LIBRARY_PATH}"

# --- Download Python Source ---
PY_ZIP_FILE="talib-py-v${TALIB_PY_VER}.zip"
echo "Downloading TA-Lib Python source code (v$TALIB_PY_VER)..."
curl -L -o "$PY_ZIP_FILE" "https://github.com/TA-Lib/ta-lib-python/archive/refs/tags/TA_Lib-$TALIB_PY_VER.zip"

# --- Extract Python Source ---
echo "Extracting TA-Lib Python source ($PY_ZIP_FILE)..."
# Extract into its own directory for clarity
unzip -o "$PY_ZIP_FILE"
# Verify the expected directory exists
if [ ! -d "$EXPECTED_PY_SRC_DIR" ]; then
    echo "ERROR: Extracted Python source directory '$EXPECTED_PY_SRC_DIR' not found!" >&2
    exit 1
fi
echo "Found Python source directory: $EXPECTED_PY_SRC_DIR"

# --- Prepare for Python Build ---
# The next step in the CI workflow should typically 'cd' into $EXPECTED_PY_SRC_DIR
# and run the Python build command (e.g., 'pip wheel .' or 'python setup.py bdist_wheel')
# The exported TA_LIBRARY_PATH and TA_INCLUDE_PATH will be used by setup.py
echo "TA-Lib C build complete. Environment prepared for Python build."
echo "Next step should 'cd $EXPECTED_PY_SRC_DIR' and run the Python build."

# --- Optional Cleanup ---
# echo "Cleaning up downloads..."
# rm -f "$C_ZIP_FILE" "$PY_ZIP_FILE"
# Consider removing the extracted C source directory if space is critical
# rm -rf "$EXPECTED_C_SRC_DIR"

exit 0