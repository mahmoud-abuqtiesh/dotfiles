# External tool init. Each guarded so a missing binary on the dev box is a no-op.

# --- rbenv (Ruby version manager) ---
if [[ -d "$HOME/.rbenv" ]]; then
  export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"
  eval "$(rbenv init - zsh)"
fi

# --- zoxide (smart cd) ---
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi

# --- direnv (per-directory env) ---
if (( $+commands[direnv] )); then
  eval "$(direnv hook zsh)"
fi

# --- pay-respects / thefuck (typo corrector) ---
# Prefer pay-respects (Rust, fast, no Python deps). Fall back to thefuck.
# thefuck is broken on Python 3.12 (uses removed `imp` module) — wrap defensively
# so a broken install doesn't kill shell startup.
if (( $+commands[pay-respects] )); then
  eval "$(pay-respects zsh --alias)"
elif (( $+commands[thefuck] )); then
  if _tf="$(thefuck --alias 2>/dev/null)" && [[ -n "$_tf" ]]; then
    eval "$_tf"
  fi
  unset _tf
fi
