#!/bin/sh
# Prints every boundary violation. No output means clean. See ARCHITECTURE.md.
cd "$(dirname "$0")/.."

# Sides
grep -rlE "package:intake/(physician|internal)/" lib/worker
grep -rlE "package:intake/(worker|internal)/" lib/physician
grep -rlE "package:intake/(worker|physician)/" lib/internal
grep -rlE "package:intake/(worker|physician|internal|app)/" lib/shared

# Layers
grep -rl "/data/" lib/*/features/*/presentation 2>/dev/null             # presentation never imports data
grep -rl "package:flutter" lib/*/features/*/domain 2>/dev/null           # domain is pure Dart

# Features: none reaches into another's data/ or presentation/
for dir in lib/*/features/*/; do
  feature=${dir#lib/}; feature=${feature%/}                              # e.g. worker/features/speech
  grep -rHE "package:intake/[a-z_]+/features/[a-z_]+/(data|presentation)/" "$dir" \
    | grep -v "package:intake/$feature/"
done

# Routing
grep -rl "go_router" lib/*/features                                      # features don't know URLs
grep -rnE "context\.(go|push|pushReplacement|replace)\(" lib --include='*.dart' --exclude='*.g.dart'   # no string paths

# Design system
grep -rlE "package:(flutter/material|flutter/cupertino|material_ui|cupertino_ui)" lib   # no Material or Cupertino
grep -rl "package:shadcn_ui" lib | grep -vE "^lib/(shared/ui|app)/"                  # the kit stays behind shared/ui
grep -rnE "Color\(0x|Colors\.|TextStyle\(" lib --include='*.dart' | grep -v "^lib/shared/ui/"   # colors and type come from the theme

# Data: only the composition root imports data/
grep -rlE "package:intake/[a-z_]+/features/[a-z_]+/data/" lib --include='*.dart' \
  | grep -vE "^lib/bootstrap\.dart$|^lib/[a-z_]+/features/[a-z_]+/data/"
exit 0
