#!/bin/bash
set -e

echo "Notarizing app..."

# Get input variables
PROJECT_NAME="${INPUT_PROJECT_NAME}"
SCHEME_NAME="${INPUT_SCHEME_NAME}"
KEYCHAIN_PROFILE="${INPUT_KEYCHAIN_PROFILE}"
APPLE_ID="${INPUT_APPLE_ID}"
APPLE_PASSWORD="${INPUT_APPLE_PASSWORD}"
TEAM_ID="${INPUT_TEAM_ID}"
STAPLE="${INPUT_STAPLE}"

# Find the app bundle
APP_PATH=$(find artifacts -name "*.app" -print -quit)

if [ -z "$APP_PATH" ]; then
    echo "Error: App bundle not found in artifacts directory"
    exit 1
fi

echo "Found app bundle at: $APP_PATH"

# Create temporary keychain
KEYCHAIN_PATH=$RUNNER_TEMP/notarization.keychain-db
KEYCHAIN_PASS=$(uuidgen)
security create-keychain -p "${KEYCHAIN_PASS}" ${KEYCHAIN_PATH}
security set-keychain-settings -lut 900 ${KEYCHAIN_PATH}
security unlock-keychain -p "${KEYCHAIN_PASS}" ${KEYCHAIN_PATH}

# Store notarization credentials
xcrun notarytool store-credentials "${KEYCHAIN_PROFILE}" --apple-id "${APPLE_ID}" --password "${APPLE_PASSWORD}" --team-id "${TEAM_ID}" --keychain "${KEYCHAIN_PATH}"

# Create a ZIP archive of the app bundle
ZIP_PATH="${APP_PATH}.zip"
ditto -c -k --keepParent "${APP_PATH}" "${ZIP_PATH}"

# Submit app for notarization
echo "Submitting app for notarization..."
xcrun notarytool submit "${ZIP_PATH}" --keychain-profile "${KEYCHAIN_PROFILE}" --keychain "${KEYCHAIN_PATH}" --wait

if [ "${STAPLE}" = "true" ]; then
    echo "Stapling app..."
    xcrun stapler staple "${APP_PATH}"
fi

# Cleanup
security delete-keychain ${KEYCHAIN_PATH}
rm "${ZIP_PATH}"

echo "Notarization completed successfully."