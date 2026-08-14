#!/bin/bash
set -euo pipefail
xcodebuild -project ApneaTrainer.xcodeproj -scheme ApneaTrainer -configuration Release -destination 'generic/platform=iOS' -derivedDataPath build CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
APP="build/Build/Products/Release-iphoneos/ApneaTrainer.app"
rm -rf Payload && mkdir Payload && cp -R "$APP" Payload/
rm -f ApneaTrainer.ipa && zip -qr ApneaTrainer.ipa Payload && rm -rf Payload
