#!/bin/sh

curl -F "file=@build/${APP_NAME}.ipa" -F "token=${DEPLOYGATE_API_KEY}" https://deploygate.com/api/users/${DEPLOYGATE_USER_NAME}/apps

