#!/usr/bin/env python3
"""Package our device archive for a separate, user-operated signing installer."""
from pathlib import Path
from zipfile import ZipFile, ZipInfo, ZIP_DEFLATED
import plistlib
import stat
import sys

from verify_archive import verify


def package(archive, output):
    verify(archive)
    app = archive / 'Products/Applications/Flubber.app'
    executables = set()
    for bundle in [app, *app.glob('PlugIns/*.appex')]:
        with (bundle / 'Info.plist').open('rb') as file:
            executables.add(bundle / plistlib.load(file)['CFBundleExecutable'])
    output.parent.mkdir(parents=True, exist_ok=True)
    with ZipFile(output, 'w', ZIP_DEFLATED) as ipa:
        for path in sorted(app.rglob('*')):
            if path.is_dir():
                continue
            if path.is_symlink():
                raise ValueError('Unexpected symlink in dependency-free app bundle')
            name = str(Path('Payload/Flubber.app') / path.relative_to(app))
            info = ZipInfo.from_file(path, name)
            # Also works after an archive was extracted by a tool that drops Unix modes.
            mode = 0o755 if path in executables else 0o644
            info.create_system = 3
            info.external_attr = (stat.S_IFREG | mode) << 16
            info.compress_type = ZIP_DEFLATED
            ipa.writestr(info, path.read_bytes())
    print(f'Created {output}: UNSIGNED. Use a signing installer; Safari cannot install this file.')


if __name__ == '__main__':
    if len(sys.argv) != 3:
        raise SystemExit('Usage: package_unsigned_ipa.py path/to/archive.xcarchive path/to/output.ipa')
    package(Path(sys.argv[1]), Path(sys.argv[2]))
