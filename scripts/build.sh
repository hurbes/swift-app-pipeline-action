#!/bin/bash
set -e

echo "Building app..."

# Get input variables
PROJECT_NAME="${INPUT_PROJECT_NAME}"
SCHEME_NAME="${INPUT_SCHEME_NAME}"
REMOVE_QUARANTINE="${INPUT_REMOVE_QUARANTINE}"
SIGN_APP="${INPUT_SIGN_APP}"
TEAM_ID="${INPUT_TEAM_ID}"
PROVISIONING_PROFILE_SPECIFIER="Dev"

# Print Xcode path and version
echo "Xcode path: $DEVELOPER_DIR"
echo "Xcode version:"
xcodebuild -version

# List available schemes
echo "Available schemes:"
xcodebuild -list -project "${PROJECT_NAME}.xcodeproj"

# Build flags
BUILD_FLAGS=()
BUILD_FLAGS+=(-project "${PROJECT_NAME}.xcodeproj")
BUILD_FLAGS+=(-scheme "${SCHEME_NAME}")
BUILD_FLAGS+=(-configuration Release)
BUILD_FLAGS+=(-derivedDataPath "./build")
BUILD_FLAGS+=(ONLY_ACTIVE_ARCH=NO)
BUILD_FLAGS+=(LIBRARY_VALIDATION=NO)
BUILD_FLAGS+=(OTHER_CODE_SIGN_FLAGS="--verbose --deep")

if [ "${SIGN_APP}" = "true" ]; then
    echo "Code signing enabled for build"
    BUILD_FLAGS+=(CODE_SIGN_STYLE=Manual)
    BUILD_FLAGS+=(DEVELOPMENT_TEAM="${TEAM_ID}")
    BUILD_FLAGS+=(CODE_SIGN_IDENTITY="Mac App Distribution")
    if [ -n "${PROVISIONING_PROFILE_SPECIFIER}" ]; then
        BUILD_FLAGS+=(PROVISIONING_PROFILE_SPECIFIER="Dev")
    else
        BUILD_FLAGS+=(PROVISIONING_PROFILE_SPECIFIER="Dev")
    fi
else
    echo "Code signing disabled for build"
    BUILD_FLAGS+=(CODE_SIGN_IDENTITY=-)
    BUILD_FLAGS+=(CODE_SIGNING_REQUIRED=NO)
    BUILD_FLAGS+=(CODE_SIGNING_ALLOWED=NO)
fi

if [ "${REMOVE_QUARANTINE}" = "true" ]; then
    echo "Adding REMOVE_QUARANTINE flag"
    BUILD_FLAGS+=(GCC_PREPROCESSOR_DEFINITIONS="REMOVE_QUARANTINE=1")
fi

# Build app
echo "Running xcodebuild..."
set -x  # Enable command echoing
xcodebuild build "${BUILD_FLAGS[@]}" | tee xcodebuild.log
set +x  # Disable command echoing

# Check if build was successful
if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "Build failed. Full xcodebuild log:"
    cat xcodebuild.log
    echo "Last 50 lines of xcodebuild log:"
    tail -n 50 xcodebuild.log
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