#!/usr/bin/env bash

rootProject=$1
certFileName=$2

cd $rootProject

# Add certificate info to user-secrets
dotnet user-secrets set Certificate:Path:Absolute "${TRAVIS_BUILD_DIR}/$certFileName"
dotnet user-secrets set Certificate:Password $BRING_CERTIFICATE_PASSWORD >/dev/null 2>&1
