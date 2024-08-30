#!/bin/bash
set -e

echo "Notarizing app..."

# Get input variables
APP_PATH="${INPUT_APP_PATH}"
KEYCHAIN_PROFILE="${INPUT_KEYCHAIN_PROFILE}"
APPLE_ID="${INPUT_APPLE_ID}"
APPLE_PASSWORD="${INPUT_APPLE_PASSWORD}"
TEAM_ID="${INPUT_TEAM_ID}"
STAPLE="${INPUT_STAPLE}"

# Create temporary keychain
KEYCHAIN_PATH=$RUNNER_TEMP/notarization.keychain-db
KEYCHAIN_PASS=$(uuidgen)
security create-keychain -p "${KEYCHAIN_PASS}" ${KEYCHAIN_PATH}
security set-keychain-settings -lut 900 ${KEYCHAIN_PATH}
security unlock-keychain -p "${KEYCHAIN_PASS}" ${KEYCHAIN_PATH}

# Store notarization credentials
xcrun notarytool store-credentials "${KEYCHAIN_PROFILE}" --apple-id "${APPLE_ID}" --password "${APPLE_PASSWORD}" --team-id "${TEAM_ID}" --keychain "${KEYCHAIN_PATH}"

# Submit app for notarization
echo "Submitting app for notarization..."
xcrun notarytool submit "${APP_PATH}" --keychain-profile "${KEYCHAIN_PROFILE}" --keychain "${KEYCHAIN_PATH}" --wait

if [ "${STAPLE}" = "true" ]; then
    echo "Stapling app..."
    xcrun stapler staple "${APP_PATH}"
fi

# Cleanup
security delete-keychain ${KEYCHAIN_PATH}

echo "Notarization completed successfully."