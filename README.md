# One Tap Lock

A minimal one-tap screen lock app for **Android 9 or newer (API 28+)**. Built with Flutter for setup and Kotlin for fast locking. Despite the repository name, Android 8 and older are not supported.

No ads, accounts, analytics, overlays, or release internet permission.

## Build and install

With Flutter and the Android SDK installed:
```sh
git clone https://github.com/zzenish/One-Tap-Lock-on-any-Android.git
cd One-Tap-Lock-on-any-Android
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter build apk --release --split-per-abi
adb install -r build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

Choose an APK from the repository's [Releases page](https://github.com/zzenish/One-Tap-Lock-on-any-Android/releases):

| Device architecture | APK |
| --- | --- |
| arm64-v8a (64-bit ARM) | app-arm64-v8a-release.apk |
| armeabi-v7a (32-bit ARM) | app-armeabi-v7a-release.apk |
| x86_64 (compatible emulators/devices) | app-x86_64-release.apk |

Check the connected device with `adb shell getprop ro.product.cpu.abilist`.
If it reports `armeabi-v7a,armeabi`, install the **armeabi-v7a** APK.
`INSTALL_FAILED_NO_MATCHING_ABIS` means the selected APK has the wrong architecture.
Use `adb devices` to check USB authorization; with multiple devices, use
`adb -s DEVICE_SERIAL install -r PATH_TO_APK`.

 Enable USB debugging and authorize your
computer before using adb. Alternatively copy the APK to the phone and open it,
allowing installation from that source. The release build uses the local Android
debug signing key for personal installation; retain that key for compatible
updates. Configure your own release signing key before distribution.

## First use

1. Add One Tap Lock from the app drawer to the home screen.
2. Open it and select Open Accessibility settings.
3. In Installed services / Installed apps, select One Tap Lock and enable it.
4. Return to setup. Status refreshes without locking. If Android has not connected
   the service yet, press Refresh status. Close setup or press Home.
5. Tap the home-screen icon to lock.

If disabled or disconnected, another icon tap shows setup. Toggle the service
off/on if needed. There is no delayed lock queued for when it connects.

## Files and design

- lib/main.dart: responsive, scrollable setup UI; refreshes status on resume.
- MainActivity.kt: setup-only Flutter activity and MethodChannel for status,
  settings, and closing setup. There is deliberately no Flutter lock method.
- LauncherActivity.kt: tiny native entry point in a separate task. Attempts one
  global lock action per fresh launch/new intent, then finishes. It never locks
  on resume or recreation. It ignores taps while keyguard is already locked.
- LockService.kt: Android-managed connection and GLOBAL_ACTION_LOCK_SCREEN.
  Connection/disconnection does not trigger actions.
- res/xml/lock_service.xml: no event subscription (omitted eventTypes defaults
  to zero), content retrieval, gesture capability, or extra flags.
- AndroidManifest.xml: launcher, private setup activity, protected service.
- test/widget_test.dart: setup status changes without lock requests.

Normal taps do not initialize a Flutter engine. Android keeps the accessibility
service process available; it is idle without polling, wake locks, overlays, or
notifications. This uses some process memory, but requests no event stream or
continuous work. Battery use and latency must be measured on the actual phone.
Flutter adds significant APK size despite the native fast path. Debug/profile
manifests contain Flutter development internet permission; the release manifest
does not request internet. No Device Administrator or DevicePolicyManager is used.

Accessibility locking does not deliberately demand a PIN. Android may require
one after reboot, lockdown, timeout, or other normal security conditions.
Reference: https://developer.android.com/reference/android/accessibilityservice/AccessibilityService#GLOBAL_ACTION_LOCK_SCREEN

## Physical Note 8 verification (not yet performed)

- [ ] Fresh install: first launch shows setup and does not lock.
- [ ] Enable service and return: status updates, no unexpected lock.
- [ ] Home icon: display turns off and phone locks with one tap.
- [ ] Unlock: prior screen returns, no Flutter screen or relock loop.
- [ ] Repeat rapid icon taps and several lock/unlock cycles: no crashes/loop.
- [ ] Disable service: icon opens help; re-enable and verify recovery.
- [ ] Fingerprint unlock works when normal Android policy permits it.
- [ ] Reboot: enter PIN once as Android requires; verify service and icon.
- [ ] If service reconnects late after reboot, setup appears without delayed lock.
- [ ] Rotate setup, enlarge font, and return from settings: no lock.
- [ ] Check idle battery usage and tap latency over real use.

See CHECKS.md for checks actually performed in the build environment.

## Publishing releases

1. Update the version in `pubspec.yaml` (increase the build number for updates).
2. Run formatting, analysis, tests, and the release build above.
3. Commit and push the source.
4. On GitHub, open **Releases → Draft a new release**.
5. Create a version tag such as `v1.0.0` targeting the intended commit.
6. Add release notes and attach all three APKs from
   `build/app/outputs/flutter-apk/`, plus SHA256SUMS.txt if provided.
7. Publish the release. Mark early builds as pre-release until device verification.

With GitHub CLI installed and authenticated, the equivalent is:
```sh
gh release create v1.0.0 build/app/outputs/flutter-apk/*.apk \
  --title "One Tap Lock 1.0.0" --notes-file RELEASE_NOTES.md --prerelease
```

The initial APKs use a development signing key. Keep the same signing key for
in-place updates; changing it requires uninstalling the old app first. Do not
commit signing keys, local SDK paths, or credentials.
