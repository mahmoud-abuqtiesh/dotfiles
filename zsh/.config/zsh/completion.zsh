# Completion system + fzf-tab styles.

autoload -Uz compinit
# -C: skip security check (faster); cache for the day
() {
  local zcd="${ZDOTDIR:-$HOME}/.zcompdump"
  if [[ -n "$zcd"(#qN.mh+24) ]]; then
    compinit
  else
    compinit -C
  fi
}

# Case-insensitive, then partial-word, then substring matching.
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu no
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '[%d]'

# fzf-tab integrations (only meaningful if the plugin loaded).
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' switch-group '<' '>'
# cd: tree preview of target dir
zstyle ':fzf-tab:complete:cd:*' fzf-preview \
  'eza -1 --color=always --icons=auto $realpath 2>/dev/null || ls -1 $realpath'
# Generic file/dir preview
zstyle ':fzf-tab:complete:*:*' fzf-preview \
  '[[ -d $realpath ]] && (eza --tree --color=always --level=2 --icons=auto $realpath 2>/dev/null || ls -la $realpath) || (bat --color=always --style=numbers --line-range=:200 $realpath 2>/dev/null || cat $realpath)'
# git checkout / switch: preview branch tip
zstyle ':fzf-tab:complete:git-(checkout|switch):argument-1' fzf-preview \
  'git log --color=always --oneline --graph -20 $word 2>/dev/null'
# kill: preview the process command line
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
  'ps -p $word -o cmd --no-headers 2>/dev/null'
