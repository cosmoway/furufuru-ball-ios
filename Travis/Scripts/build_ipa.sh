if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
exit 0
fi
# if [[ "$TRAVIS_BRANCH" != "develop" ]]; then
# exit 0
# fi
if [[ "$TRAVIS_BRANCH" != "master" ]]; then
exit 0
fi

rm -rf ./build/*
xcodebuild -workspace ${APP_NAME}.xcworkspace -scheme ${APP_NAME} -sdk iphoneos -configuration Release CODE_SIGN_IDENTITY="${DEVELOPER_NAME}" archive -archivePath ./build/${APP_NAME}.xcarchive
xcodebuild -exportArchive -exportFormat IPA -archivePath ./build/${APP_NAME}.xcarchive -exportPath ./build/${APP_NAME}.ipa -exportProvisioningProfile "${PROFILE_NAME}"

