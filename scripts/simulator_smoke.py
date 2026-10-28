#!/usr/bin/env python3
"""Launch the actual companion app on a cloud Simulator and capture its first screen.

This does not enable the custom keyboard or establish real extension behavior.
"""
from pathlib import Path
import json
import subprocess
import sys
import time


def run(*args):
    return subprocess.run(args, check=True, text=True, capture_output=True).stdout.strip()


def sim(*args):
    return run('xcrun', 'simctl', *args)


app = Path(sys.argv[1]).resolve()
output = Path(sys.argv[2]).resolve()
output.mkdir(parents=True, exist_ok=True)
runtimes = json.loads(sim('list', 'runtimes', '--json'))['runtimes']
available = [r for r in runtimes if r.get('isAvailable') and '.iOS-' in r['identifier']]
if not available:
    raise SystemExit('No installed iOS Simulator runtime')
runtime = max(available, key=lambda r: tuple(int(n) for n in r['version'].split('.')))
device = sim('create', 'Flubber cloud smoke', 'com.apple.CoreSimulator.SimDeviceType.iPhone-SE-3rd-generation', runtime['identifier'])
try:
    # Simulator ad hoc signatures need no Apple account or provisioning profile.
    for bundle in [*app.glob('PlugIns/*.appex'), app]:
        run('codesign', '--force', '--sign', '-', '--timestamp=none', str(bundle))
    sim('boot', device)
    sim('bootstatus', device, '-b')
    sim('status_bar', device, 'override', '--time', '9:41', '--batteryState', 'charged', '--batteryLevel', '100')
    sim('install', device, str(app))
    print(sim('launch', '--terminate-running-process', device, 'com.example.Flubber'))
    time.sleep(3)
    sim('io', device, 'screenshot', str(output / 'companion-light.png'))
    sim('ui', device, 'appearance', 'dark')
    time.sleep(1)
    sim('io', device, 'screenshot', str(output / 'companion-dark.png'))
    (output / 'scope.txt').write_text(
        f"Runtime: {runtime['name']}\nDevice: iPhone SE (3rd generation)\n"
        'Companion app install/launch and screenshots only.\n'
        'The custom keyboard was not enabled or exercised. Physical iPhone checks are pending.\n'
    )
    print('Companion launch and screenshot capture completed. Extension interaction is untested.')
finally:
    subprocess.run(['xcrun', 'simctl', 'shutdown', device], capture_output=True)
    subprocess.run(['xcrun', 'simctl', 'delete', device], capture_output=True)
