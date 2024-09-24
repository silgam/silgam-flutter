#!/bin/sh

set -e
set -x

curl -o ./silgam_private_files.zip $1
unzip silgam_private_files.zip

mv silgam_private_files/announcements ./assets/announcements
mv silgam_private_files/noises ./assets/noises
mv silgam_private_files/app_env.dart ./lib/app_env.dart
mv silgam_private_files/firebase_options.dart ./lib/firebase_options.dart
mv silgam_private_files/GoogleService-Info.plist ./ios/Runner/GoogleService-Info.plist
mv silgam_private_files/google-services.json ./android/app/google-services.json
mv silgam_private_files/firebase-messaging-sw.js ./web/firebase-messaging-sw.js

flutter pub run build_runner build --delete-conflicting-outputs
