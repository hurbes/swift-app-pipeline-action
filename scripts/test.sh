#!/bin/bash
set -e

echo "Running tests..."

# Get input variables
PROJECT_NAME="${INPUT_PROJECT_NAME}"
SCHEME_NAME="${INPUT_SCHEME_NAME}"

# Run tests
xcodebuild test -project "${PROJECT_NAME}.xcodeproj" -scheme "${SCHEME_NAME}" \
    -destination 'platform=macOS' \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    ONLY_ACTIVE_ARCH=YES | xcpretty --color --simple

# Check if tests passed
if [ $? -ne 0 ]; then
    echo "Tests failed."
    exit 1
fi

echo "Tests completed successfully."