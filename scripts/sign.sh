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

# Sign the app
echo "Signing app bundle"
codesign --force --options runtime --sign "Apple Distribution" "${APP_PATH}"

# Verify the signature
echo "Verifying signature..."
codesign --verify --verbose "${APP_PATH}"

# Check if entitlements file exists
ENTITLEMENTS_PATH="${PROJECT_NAME}/${PROJECT_NAME}.entitlements"
if [ -f "${ENTITLEMENTS_PATH}" ]; then
    echo "Applying entitlements from: ${ENTITLEMENTS_PATH}"
    codesign --force --options runtime --sign "Apple Distribution" --entitlements "${ENTITLEMENTS_PATH}" "${APP_PATH}"
else
    echo "No entitlements file found at ${ENTITLEMENTS_PATH}. Skipping entitlements."
fi

echo "App signing completed successfully."