# Getting onto an iPhone without your own Mac

The project can compile on a GitHub-hosted macOS runner. Installation still requires Apple signing. A ZIP of source, an unsigned archive, or a Simulator build cannot be installed on an ordinary iPhone from Safari.

## First: compile on a cloud Mac

Put this project at the root of your chosen GitHub repository. The included `.github/workflows/ios-build.yml` runs on pushes to `main`, pull requests, or manually via Actions → iOS cloud build → Run workflow.

It runs the shared tests, generates the Xcode project, builds both native targets for Simulator, archives both for an iPhone without signing, and inspects the actual archive for the embedded extension and matching bundled word resources. Logs and a clearly labeled unsigned archive are saved as Actions artifacts for seven days. GitHub-hosted macOS usage is subject to your account's Actions allowance and billing settings.

No Apple credentials are needed for this compile check. It does not install on your phone, launch Simulator, or exercise the keyboard. If a build fails, use its log to fix the native source and repeat before setting up signing.

## Then: choose an install route

**Active paid Apple Developer Program membership:** a cloud Mac can create a signed build using your developer team's signing assets. TestFlight internal testing is a convenient route when only an iPhone is available: create the app record and identifiers, configure signing for both app and keyboard extension, archive/upload on the cloud Mac, then install the processed build in TestFlight. Add yourself as an internal tester in App Store Connect. External testers can require beta review; a public App Store release is not needed for internal testing. Apple's processing and any compliance requirements still apply.

Alternatively, ad hoc distribution uses a registered iPhone UDID and matching provisioning profiles for both app and extension. A signed IPA then needs a supported installation channel; downloading it from GitHub in Safari alone does not install it. We have not provisioned a signing/distribution service or an OTA host.

**No paid membership:** Apple's Personal Team route uses an Apple Account signed in to Xcode for personal-device installation. We do not have that authenticated Mac/device setup in this Linux workspace. We cannot produce a phone-installable build from only source plus this workspace. Regaining access to a Mac (or arranging appropriate remote Mac/device access) is the next practical step; paid enrollment plus cloud distribution is another option, chosen by you.

Do not paste Apple passwords, private keys, signing certificates with private keys, or API keys into chat or commit them. Once an install route is selected, configure required credentials through that service's secrets/signing interface. Cloud build and TestFlight setup are not yet executed for this project.

After installing through the selected route, follow Settings → General → Keyboard → Keyboards → Add New Keyboard → Flubber, then select it from the globe picker in Notes. Start with one insertion and keyboard switching; then complete `IPHONE_CHECKLIST.md` in Notes and Messages.

References:

- [Apple: developer account and Personal Team](https://developer.apple.com/help/account/basics/about-your-developer-account/)
- [Apple: distribution methods](https://help.apple.com/xcode/mac/current/en.lproj/dev31de635e5.html)
- [Apple: TestFlight overview](https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview/)
- [GitHub: signing Xcode applications on macOS runners](https://docs.github.com/en/actions/how-tos/deploy/deploy-to-third-party-platforms/sign-xcode-applications)
