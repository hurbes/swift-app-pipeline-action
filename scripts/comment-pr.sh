#!/bin/bash
set -e

echo "Commenting on PR..."

# Check if running on a PR
if [ -z "$GITHUB_EVENT_NAME" ] || [ "$GITHUB_EVENT_NAME" != "pull_request" ]; then
    echo "This action is not running on a pull request. Skipping PR comment."
    exit 0
fi

# Get input variables
GITHUB_TOKEN="${INPUT_GITHUB_TOKEN}"
ARTIFACT_PATH="${INPUT_ARTIFACT_PATH}"
BUILD_NUMBER="${INPUT_BUILD_NUMBER}"
APP_NAME="${INPUT_APP_NAME}"
PR_COMMENT_TEMPLATE="${INPUT_PR_COMMENT_TEMPLATE:-New build available: {release-url}}"

# Check required variables
if [ -z "$GITHUB_TOKEN" ] || [ -z "$ARTIFACT_PATH" ] || [ -z "$BUILD_NUMBER" ] || [ -z "$APP_NAME" ]; then
    echo "Error: Missing required input variables"
    exit 1
fi

# Get PR number
PR_NUMBER=$(jq -r ".pull_request.number" "$GITHUB_EVENT_PATH")

# Set default values for ARTIFACT_NAME and ARTIFACT_SIZE.
ARTIFACT_NAME=""
ARTIFACT_SIZE=""

# Check if INPUT_CREATE_DMG is set to true
if [ -n "$INPUT_CREATE_DMG" ] && [ "$INPUT_CREATE_DMG" = "true" ]; then
    # Check required variables
    if [ -z "$ARTIFACT_PATH" ]; then
        echo "Error: Missing required input variables"
        exit 1
    fi

    # Get latest release URL
    RELEASE_URL=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$GITHUB_REPOSITORY/releases/latest" | \
    jq -r '.html_url')

    # Get artifact details
    ARTIFACT_NAME=$(basename "$ARTIFACT_PATH")
    ARTIFACT_SIZE=$(du -sh "$ARTIFACT_PATH" | cut -f1)
fi

# Prepare comment body
COMMENT_BODY=$(echo "$PR_COMMENT_TEMPLATE" | \
    sed "s|{app-name}|$APP_NAME|g" | \
    sed "s|{build-number}|$BUILD_NUMBER|g" | \
    sed "s|{artifact-name}|$ARTIFACT_NAME|g" | \
    sed "s|{artifact-size}|$ARTIFACT_SIZE|g" | \
    sed "s|{release-url}|$RELEASE_URL|g")

# Post comment to PR
COMMENT_URL="https://api.github.com/repos/$GITHUB_REPOSITORY/issues/$PR_NUMBER/comments"
curl -s -X POST -H "Authorization: token $GITHUB_TOKEN" -H "Content-Type: application/json" \
    -d "{\"body\": \"$COMMENT_BODY\"}" "$COMMENT_URL"

echo "Successfully commented on the pull request"
