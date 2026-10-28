#!/usr/bin/env python3
"""Check resource quality and native project wiring without pretending to compile iOS."""
from pathlib import Path
import plistlib
import re

ROOT = Path(__file__).resolve().parent.parent
words = (ROOT / "Shared/Resources/words.txt").read_text().splitlines()
assert len(words) >= 100
assert len(words) == len(set(words))
assert all(re.fullmatch(r"[a-z]+", word) for word in words)
assert {"cooking", "vibing", "discombobulating", "flabbergasting"} <= set(words)
with (ROOT / "Keyboard/Info.plist").open("rb") as file:
    extension = plistlib.load(file)["NSExtension"]
assert extension["NSExtensionPointIdentifier"] == "com.apple.keyboard-service"
assert extension["NSExtensionPrincipalClass"] == "$(PRODUCT_MODULE_NAME).KeyboardViewController"
attrs = extension["NSExtensionAttributes"]
assert attrs["RequestsOpenAccess"] is False
assert attrs["IsASCIICapable"] is False
assert attrs["PrimaryLanguage"] == "en"
# Check declarative wiring; actual XcodeGen generation/build is a separate Mac check.
project = (ROOT / "project.yml").read_text()
assert project.count("- path: Shared/WordDeck.swift") == 2
assert project.count("- path: Shared/Resources/words.txt\n        buildPhase: resources") == 2
assert "- target: FlubberKeyboardExtension\n        embed: true" in project
assert "APPLICATION_EXTENSION_API_ONLY: YES" in project
print(f"PASS: {len(words)} unique curated words, extension metadata, shared target membership, embedding declaration.")
print("This check does not compile or run the iOS targets.")
