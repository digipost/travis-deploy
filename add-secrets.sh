cd Digipost.Signature.Api.Client.Core

# Add certificate info to user-secrets
dotnet user-secrets set Certificate:Path:Absolute "${TRAVIS_BUILD_DIR}/Bring_Digital_Signature_Key_Encipherment_Data_Encipherment.p12"
dotnet user-secrets set Certificate:Password $BRING_CERTIFICATE_PASSWORD >/dev/null 2>&1