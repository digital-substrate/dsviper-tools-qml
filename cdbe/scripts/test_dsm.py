from __future__ import annotations
from dsviper import *
import os


# Expects a local clone of https://github.com/digital-substrate/dsm-samples.
# Set DSM_SAMPLES_PATH to its location, then invoke this script.
SAMPLES = os.environ.get("DSM_SAMPLES_PATH", ".")
FILENAME = os.path.join(SAMPLES, "Re")
#FILENAME = os.path.join(SAMPLES, "Ge")
report, dsm_defs, defs = DSMBuilder.assemble(FILENAME).parse()

if report.has_error():
    for error in report.errors():
        print(error)

defs.to_dsm_definitions().to_dsm()