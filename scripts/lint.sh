#!/bin/bash
set -e

echo "Running SwiftLint..."

if ! command -v swiftlint &> /dev/null; then
    echo "SwiftLint not found. Installing..."
    brew install swiftlint
fi

swiftlint lint --reporter github-actions-logging

echo "SwiftLint completed."