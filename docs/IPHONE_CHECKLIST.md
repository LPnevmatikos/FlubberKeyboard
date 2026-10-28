# Manual acceptance — Mac, Simulator, and physical iPhone

Cloud build checks performed so far are marked below; device checks remain unchecked. Record device/model, iOS version, Xcode version, tester, and date with results. A simulator run does not satisfy the physical iPhone requirement.

## Build and installation

- [x] Run `swift test` on a Mac and generate with XcodeGen — passed on the [cloud Mac](https://github.com/LPnevmatikos/FlubberKeyboard/actions/runs/40743841766).
- [x] Build both native targets for an iOS Simulator; inspect embedding/resources — Simulator compilation and device-archive inspection passed on the cloud Mac. Actual extension activation remains unchecked below.
- [ ] Confirm extension principal class resolves, `com.apple.keyboard-service` is the extension point, `RequestsOpenAccess` and `IsASCIICapable` are false, and extension-safe API checks are enabled.
- [ ] Configure both targets' signing with your developer account; install containing app on a physical iPhone.
- [ ] Launch containing app; try word preview and editable demo draft; read setup and limitations. Confirm there is no enabled-status claim.
- [ ] Enable Flubber via Settings. Do not grant Full Access. Open a Notes draft; select Flubber using the system picker.
- [ ] **Prove insertion first:** tap one word; check displayed word plus space appears in Notes. Use Flubber's globe to leave it; touch and hold the globe to verify the system keyboard picker. Repeat in Messages without sending.

## Actual extension in Notes and Messages (repeat for each)

- [ ] Start a new draft. Record the displayed word before each of 30 deliberate rapid taps, mostly top-right and some other slots. Compare the draft against the recorded sequence: exactly 30 words, one trailing ASCII space per tap, correct order, no double/dropped insertions. A screen recording can help compare states.
- [ ] Only the tapped slot changes. Other words do not move. Visible words stay distinct. No immediate same-slot repeats.
- [ ] Press and hold a word; verify no automatic repeated insertion.
- [ ] Type a partial word using another keyboard, then tap a Flubber word; confirm literal concatenation with no replacement, punctuation, or automatic leading space.
- [ ] At the end and in the middle of a draft, Space inserts one ordinary space and Delete performs exactly one ordinary proxy deletion per tap. Neither submits the draft. No Return/Send key appears.
- [ ] Keep tapping beyond 120 insertions to cross refill boundaries; no blanks or stalled buttons. Portable deterministic tests separately verify exhaustion order.
- [ ] Globe switches among enabled keyboards; touch and hold offers the picker. The host app remains open.
- [ ] Turn on airplane mode and repeat insertion. Full Access remains unnecessary.
- [ ] Leave/reenter the keyboard and terminate/relaunch the host app; a fresh shuffled deck is acceptable and all slots are populated.

## Layout and accessibility

- [ ] Test narrow portrait (including 320pt simulator if available), ordinary portrait, and landscape. Utilities and the top-right key remain reachable. Landscape has two word rows and no scrolling.
- [ ] Check `discombobulating` and `flabbergasting` at narrow width in light/dark mode and the largest accessibility text size. Use a local temporary two-word-position fixture in `viewWillAppear` if random draws are impractical; remove it before final build. Words must show completely in at most two lines, with no truncation.
- [ ] Use Xcode's view debugger or Accessibility Inspector to verify every interactive keyboard target is at least 44 × 44pt and there are no unsatisfiable Auto Layout constraints.
- [ ] Test VoiceOver word labels ("Insert …"), Space, Delete, and Next keyboard. Double-tap inserts once and announces the updated word when revisited. Globe accessibility activation advances keyboards.
- [ ] Verify keyboard text/background contrast, restrained top-right accent, and immediate pressed state in light and dark appearances.
- [ ] Exercise largest Dynamic Type sizes: word labels, Next keyboard, and Delete remain readable/reachable. Companion app content scrolls and demo buttons remain usable.
- [ ] Verify password and phone fields fall back to the system keyboard. Where available, check an app that disallows extensions.

## Finish

- [ ] Save observed results and failures in `docs/VALIDATION.md`. Resolve layout/behavior failures and repeat affected checks on physical iPhone.
- [ ] Use the installed keyboard for a day before deciding whether switching friction warrants a later full-keyboard phase.

Store distribution, app icon/marketing assets, store privacy declarations, and App Review are separate release work and are not approved by completing this checklist.
