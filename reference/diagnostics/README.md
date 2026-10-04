# Surround collision diagnostics archive

These development-only tests were removed from the playable map for v0.0.11.

- Contact pairs compared Euclidean distance with `max(abs(dx), abs(dy))` for Footman/Grunt, Huntress/Grunt, Peasant/Peasant, Peasant/Meat Wagon, Abomination/Abomination, and Knight/Abomination.
- The diagonal shape test drove Wisps into Mountain Giants from the four cardinal and four diagonal directions.
- The automated calibration tested regular racial units and neutral heroes twice from opposite diagonal directions and exported `JamiesTrainingGrounds-square-calibration.txt`.

The retained calibration source contains the tested unit list, measurement procedure, report format, and the category formula derived from the results. The release map uses that formula through `JTG.UnitObstructionHalfSize` and contains no diagnostics menu entry.
