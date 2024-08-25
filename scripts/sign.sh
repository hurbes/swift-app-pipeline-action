#!/bin/bash
set -e

echo "Signing app..."

# Get input variables
PROJECT_NAME="${INPUT_PROJECT_NAME}"
CODE_SIGNING_IDENTITY="${INPUT_CODE_SIGNING_IDENTITY}"
PROVISIONING_PROFILE="${INPUT_PROVISIONING_PROFILE}"

# Check if required variables are set
if [ -z "${CODE_SIGNING_IDENTITY}" ] || [ -z "${PROVISIONING_PROFILE}" ]; then
    echo "Error: CODE_SIGNING_IDENTITY and PROVISIONING_PROFILE must be set for app signing."
    exit 1
fi

# Path to the app bundle
APP_PATH="artifacts/${PROJECT_NAME}.app"

# Check if the app bundle exists
if [ ! -d "${APP_PATH}" ]; then
    echo "Error: App bundle not found at ${APP_PATH}"
    exit 1
fi

# Sign the app
echo "Signing app with identity: ${CODE_SIGNING_IDENTITY}"
codesign --force --options runtime --sign "${CODE_SIGNING_IDENTITY}" --entitlements "${PROJECT_NAME}/${PROJECT_NAME}.entitlements" "${APP_PATH}"

# Verify the signature
echo "Verifying signature..."
codesign --verify --verbose "${APP_PATH}"

# Embed provisioning profile
echo "Embedding provisioning profile..."
cp "${PROVISIONING_PROFILE}" "${APP_PATH}/Contents/embedded.provisionprofile"

echo "App signing completed successfully."