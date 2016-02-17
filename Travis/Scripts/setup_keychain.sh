#!/bin/sh

# Decode certs
openssl aes-256-cbc -k ${ENCRYPTION_TOKEN} -in Travis/Certs/Certificates.cer.encrypted -d -a -out Travis/Certs/Certificates.cer
openssl aes-256-cbc -k ${ENCRYPTION_TOKEN} -in Travis/Certs/Certificates.p12.encrypted -d -a -out Travis/Certs/Certificates.p12
openssl aes-256-cbc -k ${ENCRYPTION_TOKEN} -in Travis/Profiles/${PROFILE_NAME}.mobileprovision.encrypted -d -a -out Travis/Profiles/${PROFILE_NAME}.mobileprovision

# Create default keychain on VM
# http://docs.travis-ci.com/user/common-build-problems/#Mac%3A-Code-Signing-Errors
security create-keychain -p travis ios-build.keychain
security default-keychain -s ios-build.keychain
security unlock-keychain -p travis ios-build.keychain
security set-keychain-settings -t 3600 -l ~/Library/Keychains/ios-build.keychain

# Add certs to keychain
security import ./Travis/Certs/AppleWorldwideDeveloperRelationsCertificationAuthority.cer -k ~/Library/Keychains/ios-build.keychain -T /usr/bin/codesign
security import ./Travis/Certs/Certificates.cer -k ~/Library/Keychains/ios-build.keychain -T /usr/bin/codesign
security import ./Travis/Certs/Certificates.p12 -k ~/Library/Keychains/ios-build.keychain -P ${KEY_PASSWORD} -T /usr/bin/codesign

# save profile
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
cp "./Travis/Profiles/${PROFILE_NAME}.mobileprovision" ~/Library/MobileDevice/Provisioning\ Profiles/
