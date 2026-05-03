from __future__ import annotations
from dsviper import *


def inspect_selection():
    """Return (key, attachment, path) of the current document selection."""
    return _documents_panel._document_model.getSelectedInspection()

print("** CDBEditor: Hello from main_init.py **")
print("")
