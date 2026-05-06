# Sourced from ~/.zshrc by install.sh.
# Only meaningful inside a kitty terminal (kitten ships with kitty).

if (( $+commands[kitten] )); then
  alias ssh='kitten ssh'
fi
