#!/bin/sh
# Create a custom keychain
security create-keychain -p travis macos-build.keychain

# Make the custom keychain default, so xcodebuild will use it for signing
security default-keychain -s macos-build.keychain

# Unlock the keychain
security unlock-keychain -p travis macos-build.keychain

# Set keychain timeout to 1 hour for long builds
# see http://www.egeek.me/2013/02/23/jenkins-and-xcode-user-interaction-is-not-allowed/
security set-keychain-settings -t 3600 -l ~/Library/Keychains/macos-build.keychain

# Add certificates to keychain and allow codesign to access them
security import ./scripts/certs/MacDeveloper.p12 -k ~/Library/Keychains/macos-build.keychain -P $PASSWORD -T /usr/bin/codesign

# Put the provisioning profile in place
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
cp "./scripts/profile/jirassic_dev.provisionprofile" ~/Library/MobileDevice/Provisioning\ Profiles/
cp "./scripts/profile/jirassic_launcher_dev.provisionprofile" ~/Library/MobileDevice/Provisioning\ Profiles/