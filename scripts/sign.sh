#!/bin/bash
set -e

echo "Signing app..."

# Get input variables
PROJECT_NAME="${INPUT_PROJECT_NAME}"
SCHEME_NAME="${INPUT_SCHEME_NAME}"

# Path to the app bundle
APP_PATH="artifacts/${SCHEME_NAME}.app"

# Check if the app bundle exists
if [ ! -d "${APP_PATH}" ]; then
    echo "Error: App bundle not found at ${APP_PATH}"
    exit 1
fi

# Determine the code signing identity
if [ -n "${INPUT_CODE_SIGN_IDENTITY}" ]; then
    CODE_SIGN_IDENTITY="${INPUT_CODE_SIGN_IDENTITY}"
else
    # Extract the first available signing identity
    CODE_SIGN_IDENTITY=$(security find-identity -v -p codesigning | grep -m 1 '"' | sed -n 's/.*"\(.*\)".*/\1/p')
fi

if [ -z "${CODE_SIGN_IDENTITY}" ]; then
    echo "Error: No code signing identity found"
    exit 1
fi

echo "Using code signing identity: ${CODE_SIGN_IDENTITY}"

# Sign the app
echo "Signing app bundle"
codesign --force --options runtime --sign "${CODE_SIGN_IDENTITY}" "${APP_PATH}"

# Verify the signature
echo "Verifying signature..."
codesign --verify --verbose "${APP_PATH}"

# Check if entitlements file exists
ENTITLEMENTS_PATH="${PROJECT_NAME}/${PROJECT_NAME}.entitlements"
if [ -f "${ENTITLEMENTS_PATH}" ]; then
    echo "Applying entitlements from: ${ENTITLEMENTS_PATH}"
    codesign --force --options runtime --sign "${CODE_SIGN_IDENTITY}" --entitlements "${ENTITLEMENTS_PATH}" "${APP_PATH}"
else
    echo "No entitlements file found at ${ENTITLEMENTS_PATH}. Skipping entitlements."
fi

echo "App signing completed successfully."