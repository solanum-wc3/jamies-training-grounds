"""Read extracted Warcraft SYLK tables for mechanics audits."""
import json
import re
import sys
from pathlib import Path


def read_slk(path):
    cells = {}
    x = y = 1
    for line in Path(path).read_text(encoding="utf-8-sig", errors="replace").splitlines():
        if not line.startswith("C;"):
            continue
        fields = re.findall(r'(?:[^;"\n]|"(?:[^"]|"")*")+', line)
        value = None
        for field in fields[1:]:
            if field.startswith("X"):
                x = int(field[1:])
            elif field.startswith("Y"):
                y = int(field[1:])
            elif field.startswith("K"):
                value = field[1:]
                if value.startswith('"'):
                    value = value[1:-1].replace('""', '"')
        if value is not None:
            cells.setdefault(y, {})[x] = value
    header = cells[1]
    return {row[1]: {header.get(col, f"column{col}"): value for col, value in row.items()}
            for index, row in cells.items() if index != 1 and 1 in row}


if __name__ == "__main__":
    table = read_slk(sys.argv[1])
    print(json.dumps({key: table.get(key) for key in sys.argv[2:]}
                     if len(sys.argv) > 2 else table, indent=2))
