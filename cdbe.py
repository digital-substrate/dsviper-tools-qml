#!/usr/bin/env python3
"""cdbe — Commit Database Editor (QML port).

Thin entry-point shim. The actual implementation lives in
cdbe/main.py alongside its Main.qml and assets.

Run from the repo root:

    python3 cdbe.py [database.cdb]

Mirrors the graph_editor.py shim in ge-qml.
"""
from __future__ import annotations

import runpy
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
TARGET = HERE / "cdbe" / "main.py"

# Make `dsviper_components_qml` importable, plus cdbe's own
# sibling modules.
sys.path.insert(0, str(HERE / "cdbe"))
sys.path.insert(0, str(HERE))

runpy.run_path(str(TARGET), run_name="__main__")
