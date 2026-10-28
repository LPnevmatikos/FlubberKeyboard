# Validation status

Updated 2026-10-28. Implementation started on Debian 13; native compilation now also runs on GitHub-hosted macOS.

## Passed

[Cloud build 40743841766](https://github.com/LPnevmatikos/FlubberKeyboard/actions/runs/40743841766), commit `d4bc24c59516871df8fa5b0c6097e0d5a279923b`:

- Xcode 16.4 (16F6), Apple Swift 6.1.2. XcodeGen generated the actual project.
- Nine shared-deck XCTest tests passed with zero failures on macOS. The same suite previously passed on Linux Swift 6.0.3.
- Both native targets compiled/linked for iOS Simulator.
- Both native targets compiled/linked into a Release iPhone archive without signing. Xcode validated the embedded extension.
- The actual archive passed inspection: app and keyboard executables, resolved principal class, correct extension point, no requested Full Access or full ASCII capability, matching identifier prefixes, and both bundled 120-word resources.
- Portable resource and project-declaration checks passed.

[Cloud build 40744632353](https://github.com/LPnevmatikos/FlubberKeyboard/actions/runs/40744632353), commit `eec92d727c4dd2c56a0814fb926d96644c7c94d1`, also passed all compilation, archive inspection and nine tests, then:

- Installed/launched the actual companion app on an iPhone SE (3rd generation) Simulator, iOS 26.2.
- Captured light/dark screenshots, visually inspected: the demo grid, accent, text editor, and demo disclaimer render. This is the companion screen, not the keyboard extension.
- Generated an unsigned IPA in the cloud, published as an Actions artifact. Its downloaded ZIP contents were checked for the embedded keyboard, both 120-word resources, executable permissions, and absence of bundled provisioning profiles. A local copy is available as `Flubber-unsigned.ipa`.

The IPA still needs a signing installer before an iPhone can install it. Screenshots are in the run's `companion-simulator-smoke` artifact; IPA is in `Flubber-unsigned-IPA-REQUIRES-SIGNING`.

The deck suite covers sanitization/deduplication; required examples and 120 curated entries; deterministic small-bag and full-deck exhaustion/refill; 30 synchronous insertion strings in exact order; 10,000 replacement iterations across two deck sizes with stable other slots and distinct words; missing/invalid/invalid-UTF8 resource fallback; and invalid slots. The 30-tap test checks returned strings, not actual touches delivered to a host draft.

## Pending

- Real extension loading, `textDocumentProxy` insertion/deletion, rapid touches, globe switching and picker behavior.
- Keyboard layout and constraints in narrow portrait/landscape, long words, light/dark mode, Dynamic Type, VoiceOver, and measured touch targets.
- Signing and physical iPhone installation. User reports a free Apple developer account; paid TestFlight/ad hoc signing is unavailable under that account. The user prefers an iPhone-only route. Paid hosted signing through Signulous is documented as a candidate OTA route; retaining/provisioning Flubber's keyboard extension has not been verified there. Ubuntu direct import through iloader remains an alternative. Neither route has been tested on the user's phone.
- Notes and Messages, no-Full-Access operation, airplane mode, lifecycle restarts, restricted fields/apps.

The [iPhone checklist](IPHONE_CHECKLIST.md) remains the acceptance gate. Its boxes stay unchecked until performed; compiling on a cloud Mac does not complete device validation. App Store release remains a separate decision/readiness pass.

## Known build warnings

The first build reported UIKit deprecations for `traitCollectionDidChange` and legacy button `contentEdgeInsets`, an app orientation warning, and Xcode's skipped AppIntents metadata extraction (no AppIntents dependency is used). These did not fail compilation. No physical-device behavior is inferred from the build result.
