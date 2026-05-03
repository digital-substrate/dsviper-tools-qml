from __future__ import annotations
from dsviper import *
import os


# Expects a local clone of https://github.com/digital-substrate/dsm-samples
# at /Volumes/DigitalSubstrate/dsm-samples (override as needed).
FILENAME = "/Volumes/DigitalSubstrate/dsm-samples/Re"
#FILENAME = "/Volumes/DigitalSubstrate/dsm-samples/Ge"
report, dsm_defs, defs = DSMBuilder.assemble(FILENAME).parse()

if report.has_error():
    for error in report.errors():
        print(error)

defs.to_dsm_definitions().to_dsm()