# Plugins via Zap (https://www.zapzsh.com/).
# Bootstrap is bootstrap-remote.sh's job — install Zap if missing.

[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] || return
source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"

# IMPORTANT: fzf-tab requires compinit to have run *before* it is loaded,
# otherwise the completion widget isn't registered and Tab does nothing.
autoload -Uz compinit
() {
  local zcd="${ZDOTDIR:-$HOME}/.zcompdump"
  # Re-run compinit fully once a day; otherwise use cached.
  if [[ -n "$zcd"(#qN.mh+24) ]]; then
    compinit
  else
    compinit -C
  fi
}

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
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
