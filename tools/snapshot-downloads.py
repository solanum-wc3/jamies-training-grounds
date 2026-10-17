"""Append GitHub release-asset counters and refresh the readable download ledger.

Counts describe link routes, not unique people or verified referring websites.
No credentials are read or written. Historical counters are never backdated.
"""
import argparse
import json
from datetime import datetime, timezone
from pathlib import Path
from urllib.request import Request, urlopen

ROOT = Path(__file__).resolve().parent.parent
REPOSITORY = 'solanum-wc3/jamies-training-grounds'
SOURCES = ('Hive', 'Generic / Warcraft3Gym', 'Versioned', 'Other')


def classify(name):
    if name == 'Jamies-Training-Grounds-Hive.w3x':
        return 'Hive'
    if name == 'Jamies-Training-Grounds.w3x':
        return 'Generic / Warcraft3Gym'
    if name.startswith('Jamies-Training-Grounds-v') and name.endswith('.w3x'):
        return 'Versioned'
    return 'Other'


def summarize(releases):
    totals = dict.fromkeys(SOURCES, 0)
    assets = []
    seen = set()
    for release in releases:
        if release['draft']:
            continue
        for asset in release['assets']:
            if asset['id'] in seen:
                raise ValueError('Duplicate release asset in snapshot')
            seen.add(asset['id'])
            count = asset['download_count']
            if not isinstance(count, int) or count < 0:
                raise ValueError('Invalid download counter')
            source = classify(asset['name'])
            totals[source] += count
            assets.append({'release': release['tag_name'], 'id': asset['id'],
                           'name': asset['name'], 'source': source,
                           'downloads': count, 'url': asset['browser_download_url']})
    return {'totals': totals, 'total': sum(totals.values()), 'assets': assets}


def fetch_releases():
    releases = []
    page = 1
    while True:
        request = Request(f'https://api.github.com/repos/{REPOSITORY}/releases?per_page=100&page={page}',
                          headers={'User-Agent': 'JTG-download-snapshot',
                                   'Accept': 'application/vnd.github+json'})
        with urlopen(request, timeout=30) as response:
            batch = json.load(response)
        releases.extend(batch)
        if len(batch) < 100:
            return releases
        page += 1


def render(history):
    lines = ['# Download snapshots', '',
             'Release-time snapshots of cumulative GitHub asset download counters across all public releases, including prereleases. Drafts are excluded. Historical releases continue to contribute to later totals.', '',
             'These are downloads through attachment routes, not unique players or proven referring sites. The generic route is used by Warcraft3Gym; before the separate Hive attachment existed it may also have been shared elsewhere. Versioned links likewise cannot identify the referring site. Verification/test downloads also count, and GitHub counter updates may lag.', '',
             'No earlier release-time totals have been reconstructed. The JSON retains every asset ID, release, URL and count observed at each timestamp.', '',
             '| Release checkpoint | Captured UTC | Hive | Generic / Warcraft3Gym | Versioned | Other | Total |',
             '| --- | --- | ---: | ---: | ---: | ---: | ---: |']
    for snapshot in history['snapshots']:
        counts = [str(snapshot['totals'][source]) for source in SOURCES]
        lines.append('| ' + ' | '.join([snapshot['release'] + ' (' + snapshot['phase'] + ')',
                     snapshot['capturedUtc'], *counts, str(snapshot['total'])]) + ' |')
    lines += ['', '## Counts for each version at every snapshot', '',
              'The Versioned column counts only the explicitly versioned file. Total includes that version\'s Hive and generic attachments too. Rows from different snapshots must not be added together.', '',
              '| Captured UTC | Version | Hive | Generic / Warcraft3Gym | Versioned | Other | Total |',
              '| --- | --- | ---: | ---: | ---: | ---: | ---: |']
    for snapshot in history['snapshots']:
        versions = {}
        for asset in snapshot['assets']:
            counts = versions.setdefault(asset['release'], dict.fromkeys(SOURCES, 0))
            counts[asset['source']] += asset['downloads']
        for version, counts in versions.items():
            lines.append('| ' + ' | '.join([snapshot['capturedUtc'], version,
                         *(str(counts[source]) for source in SOURCES), str(sum(counts.values()))]) + ' |')
    lines += ['', 'Detailed source: [DOWNLOAD-COUNTS.json](DOWNLOAD-COUNTS.json).', '',
              'At each public release, run `python tools/snapshot-downloads.py --release vX.Y.Z --phase before-publication`, then repeat with `--phase after-verification` after all public links are checked. Commit both records; never replace old snapshots. For current live numbers, take a new snapshot rather than presenting these historical values as current.', '']
    return '\n'.join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--release', required=True)
    parser.add_argument('--phase', required=True)
    args = parser.parse_args()
    started = datetime.now(timezone.utc).isoformat(timespec='seconds')
    snapshot = summarize(fetch_releases())
    snapshot.update(release=args.release, phase=args.phase, capturedUtc=started,
                    completedUtc=datetime.now(timezone.utc).isoformat(timespec='seconds'))
    path = ROOT / 'docs/DOWNLOAD-COUNTS.json'
    history = json.loads(path.read_text(encoding='utf-8')) if path.exists() else {
        'schemaVersion': 1, 'repository': REPOSITORY, 'snapshots': []}
    if history['schemaVersion'] != 1 or history['repository'] != REPOSITORY:
        raise ValueError('Unexpected download history format or repository')
    history['snapshots'].append(snapshot)
    # Fetch and validate everything before touching the existing history.
    path.write_text(json.dumps(history, indent=2) + '\n', encoding='utf-8')
    path.with_suffix('.md').write_text(render(history), encoding='utf-8')
    print(json.dumps({key: value for key, value in snapshot.items() if key != 'assets'}, indent=2))


if __name__ == '__main__':
    main()
