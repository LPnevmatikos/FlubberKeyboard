#!/usr/bin/env python3
"""Inspect a real Xcode archive. Does not establish signing or device usability."""
from pathlib import Path
import plistlib
import sys


def load(path):
    with path.open('rb') as file:
        return plistlib.load(file)


def verify(archive):
    app = archive / 'Products/Applications/Flubber.app'
    extension = app / 'PlugIns/FlubberKeyboardExtension.appex'
    app_info = load(app / 'Info.plist')
    ext_info = load(extension / 'Info.plist')
    assert ext_info['CFBundleIdentifier'].startswith(app_info['CFBundleIdentifier'] + '.')
    config = ext_info['NSExtension']
    assert config['NSExtensionPointIdentifier'] == 'com.apple.keyboard-service'
    assert config['NSExtensionPrincipalClass'].endswith('.KeyboardViewController')
    assert '$(' not in config['NSExtensionPrincipalClass']
    assert config['NSExtensionAttributes']['RequestsOpenAccess'] is False
    assert config['NSExtensionAttributes']['IsASCIICapable'] is False
    expected = (Path(__file__).resolve().parent.parent / 'Shared/Resources/words.txt').read_bytes()
    for bundle, info in [(app, app_info), (extension, ext_info)]:
        executable = bundle / info['CFBundleExecutable']
        assert executable.is_file() and executable.stat().st_size > 0
        assert (bundle / 'words.txt').read_bytes() == expected
        assert float(info['MinimumOSVersion']) >= 17
    print('PASS: app executable, embedded keyboard executable, resolved extension metadata, and both word resources.')
    print('Signing, installation, and real keyboard operation remain separate checks.')


if __name__ == '__main__':
    if len(sys.argv) != 2:
        raise SystemExit('Usage: python3 scripts/verify_archive.py path/to/Flubber.xcarchive')
    verify(Path(sys.argv[1]))
