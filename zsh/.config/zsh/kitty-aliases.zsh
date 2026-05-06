# Sourced from ~/.zshrc.
# Only alias `ssh` -> `kitten ssh` when actually running inside a local kitty
# window. Detected via $KITTY_PID, which kitty sets locally and which is NOT
# forwarded to remote shells. This means SSH'ing from the dev box to another
# host falls back to plain ssh (kitten ssh errors out on a remote since
# there's no kitty IPC to talk to).

if (( $+commands[kitten] )) && [[ -n "$KITTY_PID" ]]; then
  alias ssh='kitten ssh'
fi
