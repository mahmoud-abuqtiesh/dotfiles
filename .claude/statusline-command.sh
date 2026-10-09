#!/bin/sh
# Claude Code statusLine — mirrors Powerlevel10k classic layout
# Segments: user@host  dir  git  model  context%

input=$(cat)

# --- data extraction ---
cwd=$(echo "$input"       | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input"     | jq -r '.model.display_name // ""')
used=$(echo "$input"      | jq -r '.context_window.used_percentage // empty')

# --- user@host ---
user=$(whoami)
host=$(hostname -s)

# --- short dir (replace $HOME with ~) ---
home_dir="$HOME"
short_dir="${cwd/#$home_dir/\~}"

# --- git branch (skip optional locks so we never block) ---
git_branch=""
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  git_branch=$(git -C "$cwd" -c core.hooksPath=/dev/null symbolic-ref --short HEAD 2>/dev/null \
               || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

# --- context bar ---
ctx_str=""
if [ -n "$used" ]; then
  used_int=$(printf '%.0f' "$used")
  ctx_str=" | ctx:${used_int}%"
fi

# --- git segment ---
git_str=""
if [ -n "$git_branch" ]; then
  git_str=" | ${git_branch}"
fi

# --- model segment ---
model_str=""
if [ -n "$model" ]; then
  model_str=" | ${model}"
fi

printf '%s@%s  %s%s%s%s' \
  "$user" "$host" "$short_dir" "$git_str" "$model_str" "$ctx_str"
