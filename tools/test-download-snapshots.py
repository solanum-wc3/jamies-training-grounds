"""Check route classification and cumulative snapshots without network access."""
import importlib.util
from pathlib import Path

spec = importlib.util.spec_from_file_location('snapshots', Path(__file__).with_name('snapshot-downloads.py'))
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


def release(tag, counts, draft=False):
    return {'tag_name': tag, 'draft': draft, 'assets': [
        {'id': tag + name, 'name': name, 'download_count': count,
         'browser_download_url': 'https://example.test/' + tag + '/' + name}
        for name, count in counts.items()]}


result = module.summarize([
    release('v0.2.1', {'Jamies-Training-Grounds-Hive.w3x': 3, 'Jamies-Training-Grounds.w3x': 4}),
    release('v0.2.0', {'Jamies-Training-Grounds-Hive.w3x': 5, 'Jamies-Training-Grounds.w3x': 6,
                       'Jamies-Training-Grounds-v0.2.0.w3x': 7}),
    release('v0.1.2-beta1', {'Jamies-Training-Grounds-v0.1.2-beta1.w3x': 8, 'unclassified.zip': 2}),
    release('draft', {'Jamies-Training-Grounds-Hive.w3x': 100}, True),
])
assert result['totals'] == {'Hive': 8, 'Generic / Warcraft3Gym': 10, 'Versioned': 15, 'Other': 2}
assert result['total'] == 35 and len(result['assets']) == 7
snapshot = dict(result, release='v0.2.2', phase='before-publication', capturedUtc='2026-10-17T00:00:00+00:00')
rendered = module.render({'snapshots': [snapshot]})
assert 'before-publication' in rendered and '| 8 | 10 | 15 | 2 | 35 |' in rendered
assert 'unique players' in rendered
assert '| v0.2.0 | 5 | 6 | 7 | 0 | 18 |' in rendered
assert '| v0.1.2-beta1 | 0 | 0 | 8 | 2 | 10 |' in rendered
try:
    module.summarize([release('same', {'same.w3x': 1})] * 2)
    raise AssertionError('Duplicate asset accepted')
except ValueError:
    pass
print('Passed: cumulative per-route counters, legacy/prerelease inclusion, draft exclusion, asset evidence and readable history.')
