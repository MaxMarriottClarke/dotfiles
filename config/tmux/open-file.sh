#!/usr/bin/env bash
# ~/.config/tmux/open-file.sh
#
# Open a file:line spec in $EDITOR (vim), with CMSSW-aware path resolution.
#
# Handles:
#   RecoHGCal/TICL/interface/Foo.h        C++ include path  → CMSSW_BASE/src/...
#   src/RecoHGCal/TICL/interface/Foo.h    same with leading src/ stripped
#   RecoHGCal.TICL.iterative              Python module     → CMSSW_BASE/src/RecoHGCal/TICL/python/iterative.py
#   /absolute/path/to/file.cc:42          absolute path
#
# CMSSW_BASE is inferred by walking up the directory tree when not already set.

spec="$1"
file="${spec%%:*}"
line="${spec##*:}"
[[ "$file" = "$line" ]] && line=""

# Strip a leading src/ to prevent CMSSW_BASE/src/src/ doubling
file="${file#src/}"

# Infer CMSSW_BASE from directory tree when not already exported
if [[ -z "$CMSSW_BASE" ]]; then
  dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -d "$dir/.SCRAM" && -d "$dir/src" ]]; then
      CMSSW_BASE="$dir"
      break
    fi
    dir="$(dirname "$dir")"
  done
fi

# Detect Python module path: has dots, no slashes, "extension" is not a source file type
# e.g. RecoHGCal.TICL.iterative — dots are package separators, not a file extension
ext="${file##*.}"
if [[ "$file" != */* && "$file" == *.* ]] \
   && ! [[ "$ext" =~ ^(h|hh|hpp|cc|cpp|cxx|c|py|lua|sh|json|yaml|yml|xml|txt|cfg|md)$ ]]; then
  module="${file##*.}"         # last segment, e.g. iterative
  pkg_path="${file%.*}"        # everything before last dot, e.g. RecoHGCal.TICL
  pkg_path="${pkg_path//.//}"  # replace dots with slashes: RecoHGCal/TICL
  if [[ -n "$CMSSW_BASE" ]]; then
    if [[ -f "$CMSSW_BASE/src/$pkg_path/python/$module.py" ]]; then
      file="$CMSSW_BASE/src/$pkg_path/python/$module.py"
    elif [[ -f "$CMSSW_BASE/src/$pkg_path/$module.py" ]]; then
      file="$CMSSW_BASE/src/$pkg_path/$module.py"
    else
      found=$(find "$CMSSW_BASE/src/$pkg_path" -name "$module.py" 2>/dev/null | head -1)
      [[ -n "$found" ]] && file="$found"
    fi
  fi
elif [[ ! -f "$file" && -n "$CMSSW_BASE" ]]; then
  file="$CMSSW_BASE/src/$file"
fi

if [[ -n "$line" ]]; then
  exec "${EDITOR:-vim}" +"$line" "$file"
else
  exec "${EDITOR:-vim}" "$file"
fi
