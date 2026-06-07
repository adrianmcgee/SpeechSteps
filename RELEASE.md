# Release runbook — Tadpole Talk

A repeatable checklist for shipping a build to TestFlight / the App Store. Mirrors the
flow already used for the author's other apps (App Store Connect API key + scripted upload).

## Prerequisites (one-time)
- Apple Developer account + an app record in App Store Connect (bundle id
  `com.adrianmcgee.tadpoletalk`).
- App Store Connect API key (`.p8`) with App Manager access. **Never commit it.** Store it
  outside the repo and point the upload step at it (the same key used for the author's other
  apps — see local notes for the key id / issuer id / path).
- Tools: `xcodegen`, `swiftlint`, Xcode 16+ (`xcrun altool` / `xcodebuild -exportArchive`).

## 1. Pre-flight
```sh
xcodegen generate
swiftlint lint            # warnings OK; zero errors required
xcodebuild test -project TadpoleTalk.xcodeproj -scheme TadpoleTalk \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```
Green tests + clean build. CI (`.github/workflows/ci.yml`) enforces the same on every PR.

## 2. Bump the version
Edit `project.yml` → `MARKETING_VERSION` (e.g. `1.0`) and bump `CURRENT_PROJECT_VERSION`
(the build number — must always increase). Then `xcodegen generate`.

## 3. Archive
```sh
xcodebuild -project TadpoleTalk.xcodeproj -scheme TadpoleTalk \
  -configuration Release -archivePath build/TadpoleTalk.xcarchive \
  -destination 'generic/platform=iOS' archive
```
(Requires a signing team; set `DEVELOPMENT_TEAM` / automatic signing locally.)

## 4. Export & upload
Export an App Store ipa, then upload with the ASC API key:
```sh
xcodebuild -exportArchive -archivePath build/TadpoleTalk.xcarchive \
  -exportOptionsPlist build/ExportOptions.plist -exportPath build/export

xcrun altool --upload-app -f build/export/TadpoleTalk.ipa -t ios \
  --apiKey "$ASC_KEY_ID" --apiIssuer "$ASC_ISSUER_ID"
```
`build/` is git-ignored. Keep `ExportOptions.plist` and any `.p8` out of version control.

## 5. App Store Connect
- Confirm the build appears under TestFlight; add it to a test group.
- Fill in metadata from `STORE_LISTING.md` (description, keywords, support/privacy URLs).
- Complete the **App Privacy** questionnaire as **Data Not Collected** (see `STORE_LISTING.md`).
- Upload iPhone + iPad screenshots (see `STORE_LISTING.md` for the shot list).
- Submit for review.

## 6. Tag the release
```sh
git tag v1.0 && git push --tags
```
