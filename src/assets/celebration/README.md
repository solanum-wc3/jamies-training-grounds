# Gargoyle Surround celebration

The user supplied `HotDiggedyDog.mp3` (17,996 bytes) and five transparent GIF
frames with a 0.1-second frame interval. The supplied compressed MP3 is preserved
as `design/celebration/HotDiggedyDog-source.mp3`; the earlier, larger MP3 is not imported.
The packaged clip is re-encoded to 44.1 kHz mono, constant 64 kb/s, without
ID3 or Info/Xing metadata. This avoids the original mixed-bitrate header, which
is a suspected cause of Warcraft truncating playback. The output is about 35 KB.

Editable GIF frames live under `design/celebration/`. Regenerate their 256×256
DXT5 textures with `tools/prepare-gargoyle-celebration.py`. The UI restores the
original 220:252 aspect ratio and aligns the animation's bottom-left corner with
the end card's bottom-left corner. It loops for 15 seconds at the original
0.1-second frame interval, independently of audio playback.

The supplied clip decodes to approximately 4.4 seconds. Playback explicitly
supplies 5,000 ms to Warcraft and sets normal pitch. Re-encoding preserves the
whole decoded clip; full playback remains an in-game check. SetSoundDuration
does not manufacture missing samples or repair an incompatible MP3 header.

Re-encoding command (FFmpeg):
`ffmpeg -i design/celebration/HotDiggedyDog-source.mp3 -ar 44100 -ac 1 -c:a libmp3lame -b:a 64k -write_xing 0 -id3v2_version 0 -map_metadata -1 src/assets/celebration/HotDiggedyDog.mp3`

Only successful rounds using four Gargoyles with no other units trigger the celebration.
Resetting or exiting stops playback and disposes the activity-owned resources.
