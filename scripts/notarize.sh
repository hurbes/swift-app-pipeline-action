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

# Submit app for notarization
echo "Submitting app for notarization..."
NOTARIZATION_OUTPUT=$(xcrun notarytool submit "${APP_PATH}" --keychain-profile "${KEYCHAIN_PROFILE}" --keychain "${KEYCHAIN_PATH}" --wait)

echo "Notarization output:"
echo "$NOTARIZATION_OUTPUT"

# Check if notarization was successful
if echo "$NOTARIZATION_OUTPUT" | grep -q "status: Accepted"; then
    echo "Notarization successful!"
    
    if [ "${STAPLE}" = "true" ]; then
        echo "Stapling app..."
        if xcrun stapler staple "${APP_PATH}"; then
            echo "Stapling completed successfully."
        else
            echo "Warning: Stapling failed, but notarization was successful."
            echo "You may need to manually staple the app or distribute it with the notarization ticket."
        fi
    fi
else
    echo "Error: Notarization failed."
    echo "Please check the notarization output above for more details."
    echo "You may need to address code signing issues or other requirements from Apple."
    exit 1
fi

# Cleanup
security delete-keychain ${KEYCHAIN_PATH}

echo "Notarization process completed."