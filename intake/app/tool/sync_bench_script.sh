#!/bin/sh
# Copies the bench script (the single source of truth) into the app's assets.
# A test fails if the copy drifts; run this after editing bench/references.json.
cd "$(dirname "$0")/.." && cp ../../bench/references.json assets/bench/references.json
