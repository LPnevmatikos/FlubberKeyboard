# Getting onto an iPhone without your own Mac

The native app and keyboard extension now compile on GitHub's cloud Mac. [The first successful build](https://github.com/LPnevmatikos/FlubberKeyboard/actions/runs/40743841766) used Xcode 16.4 and passed all nine shared-deck tests. The device archive contains both executables and both word resources. Physical iPhone behavior remains untested.

## iPhone-only over-the-air option: paid hosted signing

A computer is not universally required. [Signulous](https://www.signulous.com/) advertises custom IPA uploads and device-side installation. Its [registration page](https://www.signulous.com/register) currently lists **$19.99 per iOS device for one year**, with an automatic-renewal option. This is a separate third-party signing service; your own free Apple account does not need to become a paid Apple Developer membership to use the service's device registration/signing route.

On the iPhone:

1. Save `Flubber-unsigned.ipa` from the ChatGPT attachment to Files.
2. Open Signulous in Safari, register/link that iPhone through its official device-registration flow, and purchase its iOS signing option if you choose this route. No purchase has been made on your behalf.
3. Once signing access is active, open its signing dashboard, upload the IPA, and preserve the bundled `FlubberKeyboardExtension.appex` when configuring signing. The keyboard requires that extension to remain embedded, signed and provisioned; installing only the companion app is insufficient.
4. Sign the app and follow the service's Install prompts on that iPhone. Complete any system developer-trust/Developer Mode prompts if requested.
5. Enable Flubber under Settings → General → Keyboard → Keyboards → Add New Keyboard, then try one insertion and keyboard switching in Notes.

[Signulous's install guide](https://www.signulous.com/sign-apps) confirms the sign/install flow; its homepage confirms custom IPA uploads. Public documentation does not demonstrate Flubber's specific keyboard extension working. The backend named by the service, [iOS App Signer](https://www.iosappsigner.com/), supports `.appex` processing in its [source](https://github.com/DanTheMan827/ios-app-signer/blob/master/AppSigner/MainView.swift), but that does not prove the hosted service's configuration or Flubber compatibility. Before purchasing solely for this keyboard, the useful support question is: “Can your custom IPA signing retain and provision an embedded com.apple.keyboard-service .appex? This app has no App Groups or push entitlement.”

This is a candidate route, not a completed phone test. [The provider's support page](https://www.signulous.com/support) discusses certificate revocations and activation/migration delays; its registration page also notes certificates may be revoked. Do not treat advertised instant access or a year of service as a guarantee of uninterrupted app operation. The user must choose/pay for the service and perform its device-linking steps; we have neither registered their iPhone nor installed a profile.

## Free Apple account + Ubuntu ThinkPad (computer alternative)

Use [iloader's official desktop installer](https://iloader.app/) to sign/import the compiled Flubber IPA directly. Its official site supports Linux and custom IPA import; [SideStore's Linux prerequisites](https://docs.sidestore.io/docs/installation/prerequisites) also document the Ubuntu DEB and usbmuxd requirement. This route still needs real-device verification with Flubber.

On the ThinkPad:

1. Download **Ubuntu/Debian (.deb)** from the official iloader site. For a typical Intel/AMD ThinkPad this is `iloader-linux-amd64.deb`; `uname -m` should show `x86_64`. ARM (`aarch64`) requires the corresponding ARM release instead.
2. Open Terminal and run:

   ```sh
   cd ~/Downloads
   sudo apt update
   sudo apt install usbmuxd ./iloader-linux-amd64.deb
   ```

3. Download `Flubber-unsigned.ipa` from the ChatGPT attachment, or extract it from the `Flubber-unsigned-IPA-REQUIRES-SIGNING` artifact in [the successful cloud build](https://github.com/LPnevmatikos/FlubberKeyboard/actions/runs/40744632353).
4. Connect the unlocked iPhone with a USB data cable and accept **Trust This Computer** on the phone. Launch iloader from Ubuntu's application launcher and sign into your Apple account locally, including 2FA if prompted.
5. Choose the phone and **Import IPA**, select `Flubber-unsigned.ipa`, and let iloader sign/install it. Preserve `FlubberKeyboardExtension.appex` if offered an extension-removal choice. Flubber's native keyboard must be installed as an actual app extension.
6. On iPhone, trust your developer entry under Settings → General → VPN & Device Management if prompted. Enable Developer Mode under Settings → Privacy & Security if requested, completing the restart/confirmation.
7. Open Flubber. Then Settings → General → Keyboard → Keyboards → Add New Keyboard → Flubber. Choose it with the globe picker in a Notes draft. First verify one word insertion and the ability to switch away, then follow `IPHONE_CHECKLIST.md`.

Free-account signing expires after seven days. For this direct-install route, plan to reconnect to the ThinkPad and re-sign/reinstall using the same account and IPA before expiry. Apple account/app-ID limits and signing-tool errors can still block installation; send the exact error with personal details removed if that happens. Do not send passwords, 2FA codes, pairing files, or signing keys to chat. If Ubuntu cannot install the DEB, send the dependency error before attempting other package changes.

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

An unsigned IPA cannot be installed simply by tapping it in Safari or Files. We do not have an on-device signing setup or an authenticated remote Mac/device connection. With only a free account and no existing on-device/hosted signing setup, we have not verified a free first-install route. The paid hosted-signing option above is a phone-only alternative; the limitation is not a universal ban on OTA installation. Access to a Windows PC may be enough for the route above; your own Mac is not the only possible computer.

## When your Mac is available

Use the Xcode instructions in `README.md`, select your Personal Team for both targets, and install directly to your iPhone. This is Apple's personal-device testing route. See [Apple's developer account guidance](https://developer.apple.com/help/account/basics/about-your-developer-account/).

## Paid membership option

[Apple's distribution methods](https://help.apple.com/xcode/mac/current/en.lproj/dev31de635e5.html) include TestFlight/App Store Connect and ad hoc profiles for registered devices. These need an Apple Developer Program membership. A cloud Mac can handle compilation and signing once signing assets are configured; TestFlight internal testing does not require a public App Store release. Enrollment, signing setup, and Apple processing are separate steps and have not been performed.

## Build artifacts and scope

The cloud workflow runs Swift tests, XcodeGen, Simulator compilation, an unsigned device archive, actual archive inspection, and unsigned IPA packaging. The [second successful run](https://github.com/LPnevmatikos/FlubberKeyboard/actions/runs/40744632353) also installed/launched the companion app in Simulator, captured light/dark screenshots, and published the unsigned IPA. It did not enable or exercise the real keyboard extension.

`Flubber-unsigned.ipa` is a package for a signing installer. It has no provisioning profiles or developer signature. `Flubber-unsigned.xcarchive.zip` is a developer archive. Neither installs directly from Safari. Artifacts expire after seven days; rerun the workflow if needed. GitHub Actions usage is subject to your account's allowance/billing settings.
