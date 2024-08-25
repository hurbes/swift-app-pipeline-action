#!/bin/bash
set -e

echo "Creating DMG..."

# Get input variables
APP_NAME="${INPUT_APP_NAME}"
PROJECT_NAME="${INPUT_PROJECT_NAME}"
DMG_BACKGROUND="${INPUT_DMG_BACKGROUND}"
DMG_WINDOW_SIZE="${INPUT_DMG_WINDOW_SIZE:-600x400}"
DMG_ICON_SIZE="${INPUT_DMG_ICON_SIZE:-128}"
BUILD_NUMBER="${BUILD_NUMBER}"

# Set paths
APP_PATH="artifacts/${PROJECT_NAME}.app"
DMG_NAME="${APP_NAME}-${BUILD_NUMBER}.dmg"
DMG_PATH="artifacts/${DMG_NAME}"

# Check if the app bundle exists
if [ ! -d "${APP_PATH}" ]; then
    echo "Error: App bundle not found at ${APP_PATH}"
    exit 1
fi

# Install create-dmg if not available
if ! command -v create-dmg &> /dev/null; then
    echo "Installing create-dmg..."
    brew install create-dmg
fi

# Parse window size
IFS='x' read -ra WINDOW_SIZE <<< "$DMG_WINDOW_SIZE"
WINDOW_WIDTH=${WINDOW_SIZE[0]}
WINDOW_HEIGHT=${WINDOW_SIZE[1]}

# Calculate positions
ICON_POSITION_X=$((WINDOW_WIDTH / 4))
ICON_POSITION_Y=$((WINDOW_HEIGHT / 3))
APPS_LINK_X=$((WINDOW_WIDTH * 3 / 4))
APPS_LINK_Y=$((WINDOW_HEIGHT / 3))

# Create DMG
if [ -n "${DMG_BACKGROUND}" ]; then
    create-dmg \
        --volname "${APP_NAME}" \
        --window-pos 200 120 \
        --window-size ${WINDOW_WIDTH} ${WINDOW_HEIGHT} \
        --icon-size ${DMG_ICON_SIZE} \
        --icon "${APP_NAME}.app" ${ICON_POSITION_X} ${ICON_POSITION_Y} \
        --hide-extension "${APP_NAME}.app" \
        --app-drop-link ${APPS_LINK_X} ${APPS_LINK_Y} \
        --background "${DMG_BACKGROUND}" \
        "${DMG_PATH}" \
        "${APP_PATH}"
else
    create-dmg \
        --volname "${APP_NAME}" \
        --window-pos 200 120 \
        --window-size ${WINDOW_WIDTH} ${WINDOW_HEIGHT} \
        --icon-size ${DMG_ICON_SIZE} \
        --icon "${APP_NAME}.app" ${ICON_POSITION_X} ${ICON_POSITION_Y} \
        --hide-extension "${APP_NAME}.app" \
        --app-drop-link ${APPS_LINK_X} ${APPS_LINK_Y} \
        "${DMG_PATH}" \
        "${APP_PATH}"
fi

echo "DMG created successfully at ${DMG_PATH}"
echo "dmg-path=${DMG_PATH}" >> $GITHUB_OUTPUT