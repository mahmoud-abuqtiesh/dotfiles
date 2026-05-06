# Plugins via Zap (https://www.zapzsh.com/).
# Bootstrap is the user's responsibility — bootstrap-remote.sh installs Zap if missing.

[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] || return
source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"

# Order: prompt early, completions before fzf-tab, syntax-highlighting last.
plug "romkatv/powerlevel10k"
plug "zsh-users/zsh-completions"
plug "Aloxaf/fzf-tab"
plug "zsh-users/zsh-autosuggestions"
plug "MichaelAquilina/zsh-you-should-use"
plug "hlissner/zsh-autopair"
plug "junegunn/fzf-git.sh"
plug "zsh-users/zsh-history-substring-search"
plug "zdharma-continuum/fast-syntax-highlighting"

# History substring search keybinds (after the plugin is loaded).
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
# Same for vim mode if used:
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
