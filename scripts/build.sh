#!/bin/bash
set -e

echo "Building app..."

# Get input variables
PROJECT_NAME="${INPUT_PROJECT_NAME}"
SCHEME_NAME="${INPUT_SCHEME_NAME}"
REMOVE_QUARANTINE="${INPUT_REMOVE_QUARANTINE}"
SIGN_APP="${INPUT_SIGN_APP}"

# Print Xcode version
echo "Xcode version:"
xcodebuild -version

# List available schemes
echo "Available schemes:"
xcodebuild -list -project "${PROJECT_NAME}.xcodeproj"

# Build flags
BUILD_FLAGS="ONLY_ACTIVE_ARCH=NO"
BUILD_FLAGS="${BUILD_FLAGS} LIBRARY_VALIDATION=NO OTHER_CODE_SIGN_FLAGS=--deep"

if [ "${SIGN_APP}" = "true" ]; then
    echo "Code signing enabled for build"
    BUILD_FLAGS="${BUILD_FLAGS} CODE_SIGN_STYLE=Manual"
else
    echo "Code signing disabled for build"
    BUILD_FLAGS="${BUILD_FLAGS} CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO"
fi

if [ "${REMOVE_QUARANTINE}" = "true" ]; then
    echo "Adding REMOVE_QUARANTINE flag"
    BUILD_FLAGS="${BUILD_FLAGS} GCC_PREPROCESSOR_DEFINITIONS='${GCC_PREPROCESSOR_DEFINITIONS} REMOVE_QUARANTINE=1'"
fi

# Build app
echo "Running xcodebuild..."
set -x  # Enable command echoing
xcodebuild build -project "${PROJECT_NAME}.xcodeproj" -scheme "${SCHEME_NAME}" \
    -configuration Release \
    ${BUILD_FLAGS} \
    BUILD_DIR="./build" | xcpretty --color --simple
set +x  # Disable command echoing

# Check if build was successful
if [ $? -ne 0 ]; then
    echo "Build failed."
    echo "xcodebuild output:"
    xcodebuild build -project "${PROJECT_NAME}.xcodeproj" -scheme "${SCHEME_NAME}" \
        -configuration Release \
        ${BUILD_FLAGS} \
        BUILD_DIR="./build"
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

    # Sign the app if signing is enabled
    if [ "${SIGN_APP}" = "true" ]; then
        echo "Signing app bundle..."
        codesign --force --options runtime --sign - "artifacts/$(basename "$APP_PATH")"
        
        echo "Verifying signature..."
        codesign --verify --verbose "artifacts/$(basename "$APP_PATH")"
    fi
else
    echo "Error: App bundle not found in the build directory."
    echo "Contents of build directory:"
    ls -R build
    exit 1
fi

echo "Build completed successfully."