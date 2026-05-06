# fzf shell integration: ctrl+t (file picker), ctrl+r (history), and global defaults.

if (( $+commands[fzf] )); then
  # Prefer `fzf --zsh` (single-command integration, fzf >= 0.48).
  # Probe explicitly because older fzf prints to stderr but exits 0 from
  # `source <(fzf --zsh)` after sourcing an empty stream.
  if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
  else
    # Fallbacks for older / distro-packaged fzf.
    for _f in \
      /usr/share/doc/fzf/examples/key-bindings.zsh \
      /usr/share/fzf/key-bindings.zsh \
      "$HOME/.fzf/shell/key-bindings.zsh"
    do
      [[ -f "$_f" ]] && { source "$_f"; break }
    done
    for _f in \
      /usr/share/doc/fzf/examples/completion.zsh \
      /usr/share/fzf/completion.zsh \
      "$HOME/.fzf/shell/completion.zsh"
    do
      [[ -f "$_f" ]] && { source "$_f"; break }
    done
    unset _f
  fi

  # Use fd if available — respects .gitignore, fast.
  if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  fi

  # Layout + Catppuccin Mocha colors. Smart preview for ctrl+t when bat is around.
  export FZF_DEFAULT_OPTS="
    --height=60% --layout=reverse --border --info=inline
    --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
    --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
    --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
    --color=selected-bg:#45475a
  "
  if (( $+commands[bat] )); then
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:300 {}'"
  elif (( $+commands[batcat] )); then
    export FZF_CTRL_T_OPTS="--preview 'batcat --color=always --style=numbers --line-range=:300 {}'"
  fi

  # `fzf --zsh` binds Tab to its own fzf-completion widget, which bypasses
  # fzf-tab. Re-enable fzf-tab so it owns Tab again.
  (( $+functions[enable-fzf-tab] )) && enable-fzf-tab
fi

# fzf-git.sh provides the ctrl+g chord — loaded as a Zap plug in plugins.zsh.
