#!/bin/bash
set -e

echo "Preparing release..."

# Get input variables
PROJECT_NAME="${INPUT_PROJECT_NAME}"
APP_NAME="${INPUT_APP_NAME:-$PROJECT_NAME}"
CREATE_DMG="${INPUT_CREATE_DMG}"
DMG_BACKGROUND="${INPUT_DMG_BACKGROUND}"
BUILD_NUMBER="${BUILD_NUMBER}"
GITHUB_TOKEN="${GITHUB_TOKEN}"

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

# Create GitHub Release
echo "Creating GitHub Release..."
RELEASE_NOTES="Release ${BUILD_NUMBER} of ${APP_NAME}"
RELEASE_TAG="v${BUILD_NUMBER}"

RELEASE_DATA=$(jq -n \
    --arg tag "${RELEASE_TAG}" \
    --arg name "${APP_NAME} ${RELEASE_TAG}" \
    --arg body "${RELEASE_NOTES}" \
    '{tag_name: $tag, name: $name, body: $body, draft: false, prerelease: false}')

RELEASE_RESPONSE=$(curl -s -X POST \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/${GITHUB_REPOSITORY}/releases" \
    -d "${RELEASE_DATA}")

RELEASE_ID=$(echo "${RELEASE_RESPONSE}" | jq -r .id)
UPLOAD_URL=$(echo "${RELEASE_RESPONSE}" | jq -r .upload_url | sed -e "s/{?name,label}//")

curl -s -X POST \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    -H "Content-Type: application/octet-stream" \
    "${UPLOAD_URL}?name=$(basename ${ARTIFACT_PATH})" \
    --data-binary "@${ARTIFACT_PATH}"

echo "Release created successfully."