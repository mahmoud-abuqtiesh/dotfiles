# fzf shell integration: ctrl+t (file picker), ctrl+r (history), and global defaults.
# Requires fzf >= 0.48 for `fzf --zsh`. bootstrap-remote.sh installs from upstream
# git to ensure that.

if (( $+commands[fzf] )); then
  # Native zsh integration (key-bindings + completions).
  source <(fzf --zsh) 2>/dev/null

  # Fall back to distro paths if `fzf --zsh` isn't supported (older fzf).
  if [[ $? -ne 0 ]]; then
    [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] && \
      source /usr/share/doc/fzf/examples/key-bindings.zsh
    [[ -f /usr/share/doc/fzf/examples/completion.zsh ]] && \
      source /usr/share/doc/fzf/examples/completion.zsh
  fi

  # Use fd if available — respects .gitignore and is fast.
  if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  fi

  # Layout + colors. Smart preview for ctrl+t (files) when bat is around.
  export FZF_DEFAULT_OPTS="
    --height=60% --layout=reverse --border --info=inline
    --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
    --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
    --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
    --color=selected-bg:#45475a
  "
  if (( $+commands[bat] )); then
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:300 {}'"
  fi
fi

# --- fzf-git.sh provides the ctrl+g chord (branches, hashes, files, tags, stashes, remotes).
# It's loaded as a Zap plug in plugins.zsh; nothing to source here.
