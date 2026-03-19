# Deploy - Arcas

This document outlines the requirements for deploying Arcas to Google Play and iOS App Store.

## Google Play Setup

### 1. Signing Key (Keystore)

Generate a keystore for release signing:

```bash
keytool -genkey -v -keystore arcas-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias arcas
```

**Required GitHub Secrets:**

| Secret Name | Description |
|------------|-------------|
| `ANDROID_SIGNING_KEYSTORE` | Base64 encoded `.jks` file |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_ALIAS` | Key alias name |
| `ANDROID_KEY_PASSWORD` | Key password |

Encode keystore for GitHub:
```bash
base64 -i arcas-release.jks
```

### 2. Service Account

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable **Google Play Android Developer API**
4. Create a Service Account:
   - IAM & Admin > Service Accounts > Create
   - Grant `Service Account User` role
5. Create JSON key:
   - Click on service account > Keys > Add Key > JSON
   - Download the JSON file

**Required GitHub Secret:**

| Secret Name | Description |
|------------|-------------|
| `PLAY_SERVICE_ACCOUNT_JSON` | Full JSON content of service account key |

### 3. Files in Repository

- `android/key.properties` (template):

```properties
storePassword=
keyPassword=
keyAlias=
storeFile=
```

### 4. Release Workflow

See `.github/workflows/release-play-store.yml` (template for future implementation).

---

## iOS Setup

### 1. Certificates

1. Go to [Apple Developer Portal](https://developer.apple.com/)
2. Create certificates:
   - **Apple Development Certificate** (for development)
   - **Apple Distribution Certificate** (for App Store)

### 2. Provisioning Profile

1. Go to Certificates, Identifiers & Profiles
2. Create App Store provisioning profile for `com.arcas.app`
3. Download the `.mobileprovision` file

### 3. Required GitHub Secrets

| Secret Name | Description |
|------------|-------------|
| `IOS_CERTIFICATE` | Base64 encoded `.p12` certificate file |
| `IOS_CERTIFICATE_PASSWORD` | Password for the certificate |
| `IOS_PROVISIONING_PROFILE` | Base64 encoded `.mobileprovision` file |

Export certificate to `.p12`:
```bash
openssl pkcs12 -export -inkey Certificates.p12 -in Certificates.p12 -out ios_distribution.p12
```

Encode for GitHub:
```bash
base64 -i ios_distribution.p12
```

### 4. Files in Repository

- `ios/Runner/ExportOptions.plist` (template):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamId</key>
    <string>YOUR_TEAM_ID</string>
    <key>signingStyle</key>
    <string>manual</string>
    <key>signingCertificate</key>
    <string>Apple Distribution</string>
    <key>provisioningProfile</key>
    <string>YOUR_PROFILE_NAME</string>
</dict>
</plist>
```

### 5. Release Workflow

See `.github/workflows/release-app-store.yml` (template for future implementation).

---

## Quick Reference

### Secrets Summary

**Android:**
- `ANDROID_SIGNING_KEYSTORE`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`
- `PLAY_SERVICE_ACCOUNT_JSON`

**iOS:**
- `IOS_CERTIFICATE`
- `IOS_CERTIFICATE_PASSWORD`
- `IOS_PROVISIONING_PROFILE`

### Bundle ID
- Android: `com.arcas.app`
- iOS: `com.arcas.app`

### Current Version
- `1.0.0+1`
