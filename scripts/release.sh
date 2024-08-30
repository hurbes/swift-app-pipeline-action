#!/bin/bash
set -e

echo "Preparing release..."

# Get input variables
PROJECT_NAME="${INPUT_PROJECT_NAME}"
APP_NAME="${INPUT_APP_NAME:-$PROJECT_NAME}"
CREATE_DMG="${INPUT_CREATE_DMG}"
DMG_BACKGROUND="${INPUT_DMG_BACKGROUND}"
BUILD_NUMBER="${BUILD_NUMBER}"

# Set artifact name and path
ARTIFACT_NAME="${APP_NAME}-${BUILD_NUMBER}"
APP_PATH="artifacts/${PROJECT_NAME}.app"

if [ "${CREATE_DMG}" = "true" ]; then
    echo "Creating DMG..."
    DMG_PATH="${ARTIFACT_NAME}.dmg"

    if [ -n "${DMG_BACKGROUND}" ]; then
        create-dmg \
            --volname "${APP_NAME}" \
            --background "${DMG_BACKGROUND}" \
            --window-pos 200 120 \
            --window-size 600 400 \
            --icon-size 100 \
            --icon "${APP_NAME}.app" 175 120 \
            --hide-extension "${APP_NAME}.app" \
            --app-drop-link 425 120 \
            "${DMG_PATH}" \
            "${APP_PATH}"
    else
        create-dmg \
            --volname "${APP_NAME}" \
            --volicon "${APP_PATH}/Contents/Resources/AppIcon.icns" \
            "${DMG_PATH}" \
            "${APP_PATH}"
    fi

    ARTIFACT_PATH="${DMG_PATH}"
else
    echo "Creating ZIP..."
    ZIP_PATH="${ARTIFACT_NAME}.zip"
    ditto -c -k --keepParent "${APP_PATH}" "${ZIP_PATH}"
    ARTIFACT_PATH="${ZIP_PATH}"
fi

echo "artifact-path=${ARTIFACT_PATH}" >> $GITHUB_OUTPUT
echo "release-name=${APP_NAME} v${BUILD_NUMBER}" >> $GITHUB_OUTPUT
echo "release-tag=v${BUILD_NUMBER}" >> $GITHUB_OUTPUT

echo "Release preparation completed."