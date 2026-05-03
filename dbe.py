#!/usr/bin/env python3
"""dbe — Database Editor (QML port).

Thin entry-point shim. The actual implementation lives in
dbe/main.py alongside its Main.qml and assets.

Run from the repo root:

    python3 dbe.py [database.rap]

Mirrors the graph_editor.py shim in ge-qml.
"""
from __future__ import annotations

import runpy
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
TARGET = HERE / "dbe" / "main.py"

# Make `dsviper_components_qml` importable, plus dbe's own
# sibling modules.
sys.path.insert(0, str(HERE / "dbe"))
sys.path.insert(0, str(HERE))

runpy.run_path(str(TARGET), run_name="__main__")
