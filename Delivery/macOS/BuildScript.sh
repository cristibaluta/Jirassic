#!/bin/sh

#if [ ${CONFIGURATION} == "Release" ]; then

    COMMIT_COUNT=$(git rev-list HEAD --count);
    BUNDLE_VERSION="$COMMIT_COUNT"

    now="$(date +'%y.%m.%d')"
    SHORT_VERSION_STRING="$now"

    echo "APP VERSION: $SHORT_VERSION_STRING - BUILD: $COMMIT_COUNT"

    /usr/libexec/Plistbuddy -c "Set :CFBundleShortVersionString $SHORT_VERSION_STRING" "${INFOPLIST_FILE}"
    /usr/libexec/Plistbuddy -c "Set :CFBundleVersion $BUNDLE_VERSION" "${INFOPLIST_FILE}"

#fi;
