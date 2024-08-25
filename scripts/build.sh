#!/bin/bash
set -e

echo "Building app..."

# Get input variables
PROJECT_NAME="${INPUT_PROJECT_NAME}"
SCHEME_NAME="${INPUT_SCHEME_NAME}"
INCREMENT_BUILD_VERSION="${INPUT_INCREMENT_BUILD_VERSION}"
BUILD_VERSION_INCREMENT="${INPUT_BUILD_VERSION_INCREMENT}"
REMOVE_QUARANTINE="${INPUT_REMOVE_QUARANTINE}"

# Increment build version
if [ "${INCREMENT_BUILD_VERSION}" = "true" ]; then
    if [ -n "${BUILD_VERSION_INCREMENT}" ]; then
        BUILD_NUMBER="${BUILD_VERSION_INCREMENT}"
    else
        BUILD_NUMBER=$(($(git rev-list --count HEAD) + 1000))
    fi
    echo "Incrementing build number to ${BUILD_NUMBER}"
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUMBER" "${PROJECT_NAME}/Info.plist"
    echo "build-number=${BUILD_NUMBER}" >> $GITHUB_OUTPUT
fi

# Build flags
BUILD_FLAGS="CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO"
BUILD_FLAGS="${BUILD_FLAGS} ONLY_ACTIVE_ARCH=NO ARCHS='x86_64 arm64' VALID_ARCHS='x86_64 arm64'"
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

# Create app bundle
echo "Creating app bundle..."
mkdir -p artifacts
cp -R build/Release/*.app artifacts/

echo "artifact-path=artifacts/${PROJECT_NAME}.app" >> $GITHUB_OUTPUT
echo "Build completed successfully."