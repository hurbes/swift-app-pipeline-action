#!/bin/bash
set -e

echo "Building app..."

# Get input variables
PROJECT_NAME="${INPUT_PROJECT_NAME}"
SCHEME_NAME="${INPUT_SCHEME_NAME}"
REMOVE_QUARANTINE="${INPUT_REMOVE_QUARANTINE}"

# Build flags
BUILD_FLAGS="CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO"
BUILD_FLAGS="${BUILD_FLAGS} ONLY_ACTIVE_ARCH=NO"
BUILD_FLAGS="${BUILD_FLAGS} LIBRARY_VALIDATION=NO OTHER_CODE_SIGN_FLAGS=--deep"

if [ "${REMOVE_QUARANTINE}" = "true" ]; then
    echo "Adding REMOVE_QUARANTINE flag"
    BUILD_FLAGS="${BUILD_FLAGS} GCC_PREPROCESSOR_DEFINITIONS='${GCC_PREPROCESSOR_DEFINITIONS} REMOVE_QUARANTINE=1'"
fi

# Build app
echo "Running xcodebuild..."
xcodebuild build -project "${PROJECT_NAME}.xcodeproj" -scheme "${SCHEME_NAME}" \
    -configuration Release \
    ${BUILD_FLAGS} \
    BUILD_DIR="./build" | xcpretty --color --simple

# Check if build was successful
if [ $? -ne 0 ]; then
    echo "Build failed."
    exit 1
fi

# Create app bundle
echo "Creating app bundle..."
mkdir -p artifacts

# Check build directory structure
echo "Build directory contents:"
ls -R build

# Try to find the .app file
APP_PATH=$(find build -name "*.app" -print -quit)

if [ -n "$APP_PATH" ]; then
    echo "Found app bundle at: $APP_PATH"
    cp -R "$APP_PATH" artifacts/
    echo "App bundle copied to artifacts directory."
else
    echo "Error: App bundle not found in the build directory."
    echo "Contents of build directory:"
    ls -R build
    exit 1
fi

echo "Build completed successfully."