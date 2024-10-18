#!/bin/bash

PBXPROJ="Electricity Prices.xcodeproj/project.pbxproj"

if [ "$#" -eq 1 ]; then
    NEW_VERSION=$1
else
    echo "Usage: $0 <new_version>"
    exit 1
fi

sed -i '' -E "s/(MARKETING_VERSION = )[0-9]+\.[0-9]+;/\1$NEW_VERSION;/g" "$PBXPROJ"

echo "Version updated: $NEW_VERSION"
