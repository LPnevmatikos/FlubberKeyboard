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

An unsigned IPA was packaged locally from that exact cloud-built archive. ZIP contents were checked for the embedded keyboard, both 120-word resources, executable permissions, and absence of bundled provisioning profiles. It still needs a signing installer before any iPhone can install it.

The deck suite covers sanitization/deduplication; required examples and 120 curated entries; deterministic small-bag and full-deck exhaustion/refill; 30 synchronous insertion strings in exact order; 10,000 replacement iterations across two deck sizes with stable other slots and distinct words; missing/invalid/invalid-UTF8 resource fallback; and invalid slots. The 30-tap test checks returned strings, not actual touches delivered to a host draft.

## Pending

- The newly added cloud Simulator companion install/launch/screenshots step must complete before it can be reported as passed. It does not enable or test the real keyboard extension.
- Real extension loading, `textDocumentProxy` insertion/deletion, rapid touches, globe switching and picker behavior.
- Keyboard layout and constraints in narrow portrait/landscape, long words, light/dark mode, Dynamic Type, VoiceOver, and measured touch targets.
- Signing and physical iPhone installation. User reports a free Apple developer account; paid TestFlight/ad hoc signing is unavailable under that account. Windows free-account signing is a candidate installation route, not yet verified with this app.
- Notes and Messages, no-Full-Access operation, airplane mode, lifecycle restarts, restricted fields/apps.

The [iPhone checklist](IPHONE_CHECKLIST.md) remains the acceptance gate. Its boxes stay unchecked until performed; compiling on a cloud Mac does not complete device validation. App Store release remains a separate decision/readiness pass.

## Known build warnings

The first build reported UIKit deprecations for `traitCollectionDidChange` and legacy button `contentEdgeInsets`, an app orientation warning, and Xcode's skipped AppIntents metadata extraction (no AppIntents dependency is used). These did not fail compilation. No physical-device behavior is inferred from the build result.
