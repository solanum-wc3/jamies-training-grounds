"""Measure MPEG Layer III frame duration without relying on player metadata."""
import sys
from pathlib import Path

data = Path(sys.argv[1]).read_bytes()
position = 0
if data[:3] == b"ID3":
    position = 10 + sum((data[6 + i] & 127) << (21 - 7 * i) for i in range(4))
frames = 0
duration = 0
rates = set()
bitrates = set()
while position + 4 <= len(data):
    header = int.from_bytes(data[position:position + 4], "big")
    version = (header >> 19) & 3
    layer = (header >> 17) & 3
    bitrate_index = (header >> 12) & 15
    rate_index = (header >> 10) & 3
    if (header >> 21 != 2047 or version == 1 or layer != 1
            or bitrate_index in (0, 15) or rate_index == 3):
        position += 1
        continue
    rate = [44100, 48000, 32000][rate_index] // (
        1 if version == 3 else 2 if version == 2 else 4)
    table = ([0, 32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320]
             if version == 3 else
             [0, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160])
    bitrate = table[bitrate_index]
    size = (144000 if version == 3 else 72000) * bitrate // rate + ((header >> 9) & 1)
    if position + size > len(data):
        break
    duration += (1152 if version == 3 else 576) / rate
    frames += 1
    rates.add(rate)
    bitrates.add(bitrate)
    position += size
print(f"frames={frames}, duration={duration:.6f}s, rates={sorted(rates)}, bitrates={sorted(bitrates)}")
print(f"Xing offset={data.find(b'Xing')}, Info offset={data.find(b'Info')}")
