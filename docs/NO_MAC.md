# Getting onto an iPhone without your own Mac

The native app and keyboard extension now compile on GitHub's cloud Mac. [The first successful build](https://github.com/LPnevmatikos/FlubberKeyboard/actions/runs/40743841766) used Xcode 16.4 and passed all nine shared-deck tests. The device archive contains both executables and both word resources. Physical iPhone behavior remains untested.

## Free Apple account + Windows PC

A Windows signing installer is a possible route without your Mac. [AltStore Classic supports free accounts](https://faq.altstore.io/altstore-classic/your-altstore) and [documents Windows installation](https://faq.altstore.io/altstore-classic/how-to-install-altstore-windows). This is a third-party development installation route, not TestFlight. Flubber has not yet been installed through it, so signing and keyboard registration still need to be verified on your device.

1. Follow AltStore's Windows instructions to install AltServer, the required Apple desktop components, and AltStore Classic on your connected iPhone. Use the project's official links. Unlock/trust the iPhone when prompted. Enter your Apple credentials only in the signing tool on your own computer, never into this repository or chat.
2. Enable Developer Mode on the iPhone under Settings → Privacy & Security if requested, then complete the restart/confirmation. Trust your developer entry under Settings → General → VPN & Device Management if requested.
3. Download `Flubber-unsigned-IPA-REQUIRES-SIGNING` from a successful [Actions run](https://github.com/LPnevmatikos/FlubberKeyboard/actions). Extract the artifact ZIP; the file inside is `Flubber-unsigned.ipa`. The first build's older archive-only artifact is not the IPA artifact.
4. Transfer the IPA to Files on your iPhone, then open AltStore Classic → My Apps → + and select it. Let the installer sign and install the app **and its keyboard extension**. If an installer offers to remove extensions, keep them: `FlubberKeyboardExtension.appex` is the actual keyboard.
5. Open Flubber. Then enable the real keyboard via Settings → General → Keyboard → Keyboards → Add New Keyboard → Flubber. Do not enable Full Access; it is unnecessary.
6. Open Notes, place the cursor in a draft, and choose Flubber using the globe picker. Tap one word and use the globe to leave it. Then follow [the full acceptance checklist](IPHONE_CHECKLIST.md), including Messages and rapid taps.

Free-account installations expire after seven days unless refreshed. AltStore documents refresh and active-app limits. [Each extension consumes an App ID](https://faq.altstore.io/altstore-classic/app-ids); Flubber needs two (app + keyboard), in addition to the installer's own usage. If installation fails, save the error message with personal details removed so we can diagnose it. This route does not establish that the keyboard works until the actual device checks pass.

[Sideloadly](https://sideloadly.io/) is another Windows signing installer that supports free accounts and IPA files. It can remove app extensions, so keep the keyboard extension if using it. We have not validated either installer with Flubber yet. No signing installer or third-party runtime code is added to Flubber itself.

## Only an iPhone available

An unsigned IPA cannot be installed simply by tapping it in Safari or Files. We do not have an on-device signing setup or an authenticated remote Mac/device connection. With a free account and only your iPhone, installation remains blocked until a suitable computer/signing setup is available. Access to a Windows PC may be enough for the route above; your own Mac is not the only possible computer.

## When your Mac is available

Use the Xcode instructions in `README.md`, select your Personal Team for both targets, and install directly to your iPhone. This is Apple's personal-device testing route. See [Apple's developer account guidance](https://developer.apple.com/help/account/basics/about-your-developer-account/).

## Paid membership option

[Apple's distribution methods](https://help.apple.com/xcode/mac/current/en.lproj/dev31de635e5.html) include TestFlight/App Store Connect and ad hoc profiles for registered devices. These need an Apple Developer Program membership. A cloud Mac can handle compilation and signing once signing assets are configured; TestFlight internal testing does not require a public App Store release. Enrollment, signing setup, and Apple processing are separate steps and have not been performed.

## Build artifacts and scope

The cloud workflow runs Swift tests, XcodeGen, Simulator compilation, an unsigned device archive, actual archive inspection, and unsigned IPA packaging. The [second successful run](https://github.com/LPnevmatikos/FlubberKeyboard/actions/runs/40744632353) also installed/launched the companion app in Simulator, captured light/dark screenshots, and published the unsigned IPA. It did not enable or exercise the real keyboard extension.

`Flubber-unsigned.ipa` is a package for a signing installer. It has no provisioning profiles or developer signature. `Flubber-unsigned.xcarchive.zip` is a developer archive. Neither installs directly from Safari. Artifacts expire after seven days; rerun the workflow if needed. GitHub Actions usage is subject to your account's allowance/billing settings.
