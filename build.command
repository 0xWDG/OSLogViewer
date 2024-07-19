#/usr/bin/env bash

function build_for {
    PRODUCT_NAME=`cat Package.swift | grep -m1 "name" | awk -F'"' '{print $2}'`
    
    /bin/echo -n "Building \"$PRODUCT_NAME\" for $1..."
    
    xcrun xcodebuild clean build -quiet -scheme "$PRODUCT_NAME" -destination generic/platform="$1"
    
    if [ $? -eq 0 ]; then
        echo -e "\rBuild \"$PRODUCT_NAME\" for $1... succeeded."
    else
        echo -e "\rBuild \"$PRODUCT_NAME\" for $1... failed."
        exit 1
    fi
}

build_for "iOS"
build_for "tvOS"
build_for "xrOS"
build_for "watchOS"
build_for "macOS"

exit 0