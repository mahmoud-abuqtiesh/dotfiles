#!/usr/bin/env bash
# Print today's or this-month's ccusage spend, e.g. "Daily: $53.70".
# Usage: ccusage-spend.sh {daily|monthly}
# Cached for 60s in ~/.cache so the status line skips bunx cold-start.
set -euo pipefail

mode="${1:-daily}"
case "$mode" in
  daily)   label="Daily";   period=$(date +%Y-%m-%d); key="daily"   ;;
  monthly) label="Monthly"; period=$(date +%Y-%m);    key="monthly" ;;
  *) echo "usage: $0 {daily|monthly}" >&2; exit 2 ;;
esac

cache="${XDG_CACHE_HOME:-$HOME/.cache}/ccusage-${mode}.txt"
mkdir -p "$(dirname "$cache")"

if [[ -f "$cache" ]] && (( $(date +%s) - $(stat -c %Y "$cache") < 60 )); then
  cat "$cache"
  exit 0
fi

out=$(bunx -y ccusage@latest "$mode" --json 2>/dev/null \
  | jq -r --arg d "$period" --arg k "$key" --arg l "$label" '
      [.[$k][] | select(.period==$d)][0].totalCost // 0
      | (. * 100 + 0.5 | floor | tostring
         | if length < 3 then ("0" * (3 - length)) + . else . end
         | .[:-2] + "." + .[-2:])
      | "\($l): $\(.)"
    ' 2>/dev/null) || out=""

if [[ -n "$out" ]]; then
  printf '%s' "$out" > "$cache"
  printf '%s' "$out"
elif [[ -f "$cache" ]]; then
  cat "$cache"
else
  printf '%s: ?' "$label"
fi
