# Aliases. All guarded — silent no-op if the binary is absent (e.g. on a
# fresh dev box before bootstrap-remote.sh runs).

# --- bat → cat (handles both binary names: `bat` and Debian's `batcat`) ---
if (( $+commands[bat] )); then
  alias cat='bat --paging=never --style=plain'
elif (( $+commands[batcat] )); then
  alias cat='batcat --paging=never --style=plain'
fi

# --- eza → ls family ---
if (( $+commands[eza] )); then
  alias ls='eza --icons=auto --group-directories-first'
  alias ll='eza -l --icons=auto --group-directories-first --git'
  alias la='eza -la --icons=auto --group-directories-first --git'
  alias lt='eza --tree --icons=auto --level=2'
fi

# --- lazygit ---
(( $+commands[lazygit] )) && alias lg='lazygit'

# --- safety nets (interactive confirm on destructive ops in the home dir) ---
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

# --- minor quality of life ---
alias mkdir='mkdir -p'
alias h='history'
alias reload='exec zsh'

# Suppress you-should-use reminder for interactive `rm -i` etc. (otherwise it
# nags every time). We ignore aliases prefixed with shell builtins. `reload`
# is also ignored so YSU doesn't suggest it every time we type `exec zsh`.
export YSU_IGNORED_ALIASES=("rm" "mv" "cp" "mkdir" "reload")
