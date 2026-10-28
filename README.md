# Flubber Keyboard

Native iPhone app and word-only custom keyboard, targeting iOS 17+. The SwiftUI app offers a demo and setup instructions; the UIKit extension inserts words into the host draft. Everything is local. No Full Access, network, accounts, App Groups, or third-party runtime packages.

**Status:** implementation prepared on Linux. This is not yet a verified iPhone build. See [validation status](docs/VALIDATION.md) and complete the [physical iPhone checklist](docs/IPHONE_CHECKLIST.md) before treating v1 as complete.

## Without your own Mac

See [cloud build and iPhone installation options](docs/NO_MAC.md). The included GitHub Actions workflow compiles both native targets on macOS and checks the actual archived extension. Apple signing is still required to install on an iPhone.

## Generate and build on a Mac

Prerequisites: Xcode 16 or newer, its command-line tools selected, and [XcodeGen](https://github.com/yonaskolb/XcodeGen) 2.42 or newer (`brew install xcodegen`). XcodeGen is a development tool only.

```sh
cd FlubberKeyboard
swift test
xcodegen generate
xcodebuild -project FlubberKeyboard.xcodeproj -scheme Flubber \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath DerivedData CODE_SIGNING_ALLOWED=NO build
open FlubberKeyboard.xcodeproj
```

`project.yml` is the project source of truth. It shares `WordDeck.swift` and `words.txt` with both targets, embeds the keyboard extension in the app, and enables extension-safe APIs. Generated projects are ignored. Do not edit the generated project and then regenerate expecting those edits to persist.

For your own device, choose unique bundle identifiers in `project.yml` (the extension identifier must start with the containing app identifier), regenerate, then select your developer Team for **both** targets in Xcode. Use the Flubber scheme, select your iPhone, and Run. Follow Xcode's device trust and Developer Mode prompts if needed. Do not commit signing credentials or provisioning profiles. Free provisioning restrictions vary; resolve signing on the Mac with your account.

After installing: Settings → General → Keyboard → Keyboards → Add New Keyboard → Flubber. Open Notes and an editable field; touch and hold the globe to select Flubber. Full Access is not requested. This app does not attempt to detect whether the keyboard is enabled.

The first device check is intentionally small: tap any word in Notes and verify insertion, then use the globe to leave Flubber. Continue with the full acceptance checklist only once those work. Use the same steps for Messages. The extension scheme is not required for ordinary installation; running the containing app installs its embedded extension.

## Interaction

Nine distinct words appear in portrait; compact landscape shows two word rows. All word buttons insert their displayed lowercase word and one ASCII space, then refresh only their own slot. The top-right button is muted purple. There are no repeat timers or queued animations. Space adds one space. Delete calls the proxy once; it does not undo a word. No Return or Send control is provided.

Globe uses Apple's input-mode list handler (including the system picker); VoiceOver activation advances to the next enabled keyboard. It does not specifically select Apple's keyboard. Password/phone fields and apps that reject third-party keyboards use the system keyboard.

The keyboard never reads the draft, clipboard, host identity, or network. It leaves partial words alone. Use Space before inserting if the existing draft needs a separator. A recreated extension starts with a fresh deck.

## Source layout

- `App/`: SwiftUI containing app, demo, setup/privacy copy.
- `Keyboard/`: UIKit input controller, adaptive word rows, supported globe handling, utility keys.
- `Shared/`: portable shuffled-bag logic and 120 curated verbs. Both native targets compile these files directly; the Swift package exposes the same source to tests.
- `Tests/`: XCTest checks for sanitization, fallback, exact insertion text, stable slots, distinct words, bag exhaustion, refill, and thousands of replacements.
- `scripts/validate_project.py`: portable resource and project-wiring checks; these supplement compilation.

The deck keeps undrawn words in a shuffled bag. Drawing excludes every occupied slot, including the word being replaced. Only after no eligible entry remains does it refill from the curated deck, excluding the occupied words. Input is trimmed, lowercased, deduplicated, and restricted to ASCII word entries. Missing, unreadable, or too-small resources use a built-in 24-word fallback. State is in memory only.

## Portable tests

With Swift 5.9+ installed (Mac or a supported Linux Swift toolchain):

```sh
swift test
python3 scripts/validate_project.py
```

Portable tests do not exercise UIKit, input-mode switching, touch delivery, real text proxies, VoiceOver, or signing. The companion demo appends to its own draft and is not evidence that the extension works. Local development installation comes before any distribution decision. App Store submission requires a separate readiness and review pass.
