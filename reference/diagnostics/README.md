# Surround collision diagnostics archive

These development-only tests were removed from the playable map for v0.0.11.

- Contact pairs compared Euclidean distance with `max(abs(dx), abs(dy))` for Footman/Grunt, Huntress/Grunt, Peasant/Peasant, Peasant/Meat Wagon, Abomination/Abomination, and Knight/Abomination.
- The diagonal shape test drove Wisps into Mountain Giants from the four cardinal and four diagonal directions.
- The automated calibration tested regular racial units and neutral heroes twice from opposite diagonal directions and exported `JamiesTrainingGrounds-square-calibration.txt`.

The retained calibration source contains the tested unit list, measurement procedure, report format, and the category formula derived from the results. The release map uses that formula through `JTG.UnitObstructionHalfSize` and contains no diagnostics menu entry.

## Preserved exports

`data/` contains the original Warcraft III `PreloadGen` text exports used in the research:

- `JamiesTrainingGrounds-square-calibration.txt` — 63 unit types measured twice;
- `JamiesTrainingGrounds-collision-footprints.txt` — 256 forced-movement cases;
- `JamiesTrainingGrounds-collision-orders.txt` — 512 Move/Smart order cases;
- `JamiesTrainingGrounds-collision-placement.txt` — 640 collision-aware placement cases.

Warcraft wraps exported payload lines in a generated JASS `PreloadFiles` function. The data rows are the lines between `call Preload( "")` and the following `//" )` marker. These files are preserved verbatim rather than normalized so the research input remains auditable.

SHA-256 checksums:

```text
C4CBA63380072035401D50FA696231C8B596E71150408B8ADF8541F19FE67173  JamiesTrainingGrounds-square-calibration.txt
28BE9F570DC0A88ABA8A64A21751D3B0C855D106669224B8FF2E0BABAE109329  JamiesTrainingGrounds-collision-footprints.txt
1DEF5B6F23915A981664DF88E04B601F9B4584FD9D65B6376008394CB92772BE  JamiesTrainingGrounds-collision-orders.txt
A08A1731A18EC432EA5935AD30232CEE6F00E13EF842BCC34A6909FA248D783F  JamiesTrainingGrounds-collision-placement.txt
```
