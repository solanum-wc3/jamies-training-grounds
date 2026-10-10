"""Synthetic-data tests; these do not measure the game."""
import csv
import io
import runpy
from pathlib import Path

analyze = runpy.run_path(str(Path(__file__).with_name('analyze-dodge-timing.py')))['analyze']
header = ['run', 'danger', 'dodger', 'stage', 'time_s', 'event', 'role', 'unit',
          'ability_or_item', 'detail', 'quality', 'sample_period_s', 'truncated', 'conditions', 'unit_handle']
data = []


def event(time, name, role, ability='', quality='native_event', handle='1'):
    data.append([1, 'spell.AHtb', 'dodge.18', 1, time, name, role, 'Hmkg', ability,
                 'a,"quote"', quality, .01, 'false', 'synthetic', handle])


event(.1, 'cast_start', 'enemy', 'AHtb')
event(.5, 'ability_effect', 'enemy', 'AHtb')
event(.6, 'cast_start', 'target', 'AEbl', handle='2')
event(.7, 'ability_effect', 'target', 'AEbl', handle='2')
event(.71, 'state_invisible', 'target', quality='sampled_transition', handle='2')
event(.8, 'training_launch_confirmation', 'enemy', quality='training_inference')
event(.9, 'attack_start', 'enemy')
event(.55, 'batch_dodge_request', '', quality='automation', handle='')
event(.56, 'setup_snapshot', 'target', quality='native_snapshot', handle='2')
event(.75, 'replacement_discovered', 'replacement', quality='sampled_transition', handle='3')
stream = io.StringIO()
writer = csv.writer(stream)
writer.writerow(header)
writer.writerows(data)
rows, summary = analyze(stream.getvalue())
run = summary['runs'][0]
assert abs(run['casts'][0]['start_to_effect_s']-.4) < 1e-10
assert abs(run['casts'][1]['start_to_effect_s']-.1) < 1e-10
assert run['damage_events'] == []
assert 'flight_time' not in run and 'dodge_success' not in run
assert rows[0]['detail'] == 'a,"quote"'
assert run['dodge_request_s']==.55 and len(run['setup_snapshots'])==1
assert abs(next(e for e in run['player_timeline'] if e['event']=='ability_effect')['relative_to_dodge_request_s']-.15)<1e-10
assert abs(next(e for e in run['player_timeline'] if e['event']=='replacement_discovered')['relative_to_dodge_request_s']-.2)<1e-10
pld = '\n'.join('//JTG_TIMING,'+line for line in stream.getvalue().splitlines())
assert analyze(pld)[1] == summary
chunked = [f'//JTG_ROWS,{len(stream.getvalue().splitlines())}']
for index, line in enumerate(stream.getvalue().splitlines(), 1):
    parts = [line[pos:pos+160] for pos in range(0, len(line), 160)]
    for part, payload in enumerate(parts, 1):
        chunked.append(f'//JTG_PART,{index},{part},{len(parts)},{payload}')
assert analyze('\n'.join(chunked))[1] == summary
try:
    analyze('\n'.join(chunked[:-1]))
    raise AssertionError('Missing export chunk was accepted')
except ValueError:
    pass
event(1, 'cast_start', 'enemy', 'AHtb')
event(1.1, 'cast_end', 'enemy', 'AHtb')
event(1.2, 'ability_effect', 'enemy', 'AHtb')
stream = io.StringIO(); writer = csv.writer(stream); writer.writerow(header); writer.writerows(data)
assert analyze(stream.getvalue())[1]['runs'][0]['casts'][-1]['start_to_effect_s'] is None
print('Passed: raw/preload CSV parsing, native cast intervals, escaping, cancellation and no manufactured impact/flight/success.')
