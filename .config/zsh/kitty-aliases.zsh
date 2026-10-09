# Sourced from ~/.zshrc.
# $KITTY_PID is set by kitty locally and is NOT forwarded over SSH, so we use
# its presence to distinguish "running in a local kitty window" from "running
# in a remote shell that was reached via kitten ssh".

if (( $+commands[kitten] )) && [[ -n "$KITTY_PID" ]]; then
  # Local kitty: use kitten ssh so terminfo + dotfiles are copied to the remote.
  alias ssh='kitten ssh'
elif [[ "$TERM" == "xterm-kitty" ]]; then
  # Remote shell reached via kitten ssh (so TERM=xterm-kitty was forwarded and
  # terminfo was installed here), but kitten itself isn't on this host. When
  # SSH'ing further we'd otherwise forward TERM=xterm-kitty to a host that has
  # no matching terminfo, which breaks clear/vim/tput with "unknown terminal
  # type". Downgrade TERM for outgoing ssh.
  ssh() { TERM=xterm-256color command ssh "$@"; }
fi
