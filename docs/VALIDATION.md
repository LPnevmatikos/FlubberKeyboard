# Validation status

Recorded 2026-10-28 in a Debian 13 Linux workspace. There was no existing Xcode skeleton or installed Swift toolchain. A temporary official Swift 6.0.3 Ubuntu 24.04 toolchain was downloaded outside the project to execute portable tests. No toolchain binaries or runtime dependencies are bundled with the deliverable.

## Passed here

- `swift test`: **9 XCTest tests, 0 failures**. Shared Swift source compiles and the bundled resource is found through SwiftPM. Coverage includes sanitization/deduplication, 120 curated entries and required examples, deterministic small-bag exhaustion/refill, full-deck exhaustion, 30 synchronous insertions in exact order with one trailing space, 10,000 replacement iterations across two deck sizes with unchanged other slots and distinct words, missing/invalid/unreadable-as-UTF8 resource fallback, and invalid slot handling.
- `python3 scripts/validate_project.py`: 120 unique lowercase ASCII word entries, extension point/principal class/open-access attributes, and expected source/resource/embedding declarations pass. The script uses Python's standard library.
- Swift frontend syntax parsing of SwiftUI app and UIKit keyboard source passes. This does **not** resolve Apple SDK types or compile the native targets.
- Project YAML was parsed locally and inspected for both target definitions, shared resource membership, embedding, and extension-safe API settings. This does not establish that XcodeGen generation or Xcode builds succeed.

## Pending — requires Mac/Xcode

- XcodeGen generation, generated-project inspection, and SDK type checking/linking of both iOS targets.
- Simulator build/launch, installed extension discovery, actual extension embedding and resource lookup at runtime, and principal-class loading.
- Real `textDocumentProxy` insertion/deletion, event delivery for rapid taps, system globe picker, and switching among enabled keyboards.
- Layout/constraint behavior in narrow portrait and landscape, safe-area insets, light/dark appearance, full rendering of long words, Dynamic Type, VoiceOver, and target-size measurements.
- Developer-team signing, physical iPhone installation, Notes and Messages checks, no-Full-Access operation, airplane mode, lifecycle restarts, and restricted fields/apps.

The pure-logic 30-tap test establishes returned insertion strings, not delivery of 30 real touches to a host draft. Static embedding declarations do not establish a working embedded extension. The [iPhone checklist](IPHONE_CHECKLIST.md) is the acceptance gate, and every box remains unchecked until someone performs it. Version 1 is **not device-validated or complete** until those checks pass. App Store release is a separate decision and readiness pass.

## Cloud-build preparation (2026-10-28)

Added a GitHub Actions macOS workflow for portable tests, XcodeGen generation, Simulator compilation, unsigned iPhone archive, and real archive inspection. Workflow YAML parses and supporting Python scripts pass syntax checks locally. No cloud build has run yet.

Attempting to create a private `LPnevmatikos/FlubberKeyboard` repository returned GitHub's `Resource not accessible by integration (createRepository)`. The connected integration can access repositories but cannot create this one. The user must create a repository or identify an existing authorized destination before we can push and run the macOS build. No repository was created and no code was uploaded in that attempt.

Apple signing credentials, paid membership status, and an iPhone installation route have not yet been established. None of the previously pending native/device checks can be marked passed from these preparations.
