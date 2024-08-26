#!/bin/bash
set -e

echo "Incrementing version..."

# Get input variables
PROJECT_NAME="${INPUT_PROJECT_NAME}"
INCREMENT_BUILD_VERSION="${INPUT_INCREMENT_BUILD_VERSION}"
BUILD_VERSION_INCREMENT="${INPUT_BUILD_VERSION_INCREMENT}"
CUSTOM_VERSION="${INPUT_CUSTOM_VERSION}"

# Path to Info.plist
INFO_PLIST_PATH="${PROJECT_NAME}/Info.plist"

# Check if Info.plist exists
if [ ! -f "${INFO_PLIST_PATH}" ]; then
    echo "Info.plist not found. Creating a default one."
    mkdir -p "$(dirname "${INFO_PLIST_PATH}")"
    /usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string com.example.${PROJECT_NAME}" "${INFO_PLIST_PATH}"
    /usr/libexec/PlistBuddy -c "Add :CFBundleName string ${PROJECT_NAME}" "${INFO_PLIST_PATH}"
    /usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string 1.0.0" "${INFO_PLIST_PATH}"
    /usr/libexec/PlistBuddy -c "Add :CFBundleVersion string 1" "${INFO_PLIST_PATH}"
fi

# Function to increment version
increment_version() {
    local version=$1
    local position=$2
    local new_version=$(echo "${version}" | awk -F. -v OFS=. -v p="${position}" '{$p = $p + 1; for(i=p+1; i<=NF; i++) $i=0; print}')
    echo "${new_version}"
}

# Get current version
CURRENT_VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "${INFO_PLIST_PATH}")
echo "Current version: ${CURRENT_VERSION}"

# Determine new version
if [ -n "${CUSTOM_VERSION}" ]; then
    NEW_VERSION="${CUSTOM_VERSION}"
    echo "Using custom version: ${NEW_VERSION}"
elif [ "${INCREMENT_BUILD_VERSION}" = "true" ]; then
    if [ -n "${BUILD_VERSION_INCREMENT}" ]; then
        NEW_VERSION=$(increment_version "${CURRENT_VERSION}" "${BUILD_VERSION_INCREMENT}")
    else
        # Default to incrementing the last component
        NEW_VERSION=$(increment_version "${CURRENT_VERSION}" 3)
    fi
    echo "Incrementing to version: ${NEW_VERSION}"
else
    NEW_VERSION="${CURRENT_VERSION}"
    echo "Version remains unchanged: ${NEW_VERSION}"
fi

# Update CFBundleShortVersionString in Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${NEW_VERSION}" "${INFO_PLIST_PATH}"

# Update CFBundleVersion (build number)
BUILD_NUMBER=$(($(git rev-list --count HEAD) + 1000))
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${BUILD_NUMBER}" "${INFO_PLIST_PATH}"

echo "Updated CFBundleShortVersionString to ${NEW_VERSION}"
echo "Updated CFBundleVersion to ${BUILD_NUMBER}"

# Set output variables
echo "version=${NEW_VERSION}" >> $GITHUB_OUTPUT
echo "build-number=${BUILD_NUMBER}" >> $GITHUB_OUTPUT

echo "Version increment completed successfully."