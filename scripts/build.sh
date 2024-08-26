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
if [ -d "build/Release/${SCHEME_NAME}.app" ]; then
    cp -R "build/Release/${SCHEME_NAME}.app" artifacts/
    echo "App bundle created successfully."
else
    echo "Error: App bundle not found at expected location: build/Release/${SCHEME_NAME}.app"
    echo "Contents of build/Release directory:"
    ls -la build/Release
    exit 1
fi

echo "Build completed successfully."