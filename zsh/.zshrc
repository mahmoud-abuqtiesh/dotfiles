# ~/.zshrc — managed by dotfiles. Per-machine overrides go in ~/.zshrc.local.

# --- Powerlevel10k instant prompt (must be first) ---
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --- Modular sources (order matters) ---
ZSH_CFG="$HOME/.config/zsh"
for _f in exports plugins completion tools fzf aliases kitty-aliases; do
  [[ -f "$ZSH_CFG/$_f.zsh" ]] && source "$ZSH_CFG/$_f.zsh"
done
unset _f

# --- p10k prompt config ---
[[ -f $HOME/.p10k.zsh ]] && source $HOME/.p10k.zsh

# --- Per-machine overrides (gitignored) ---
[[ -f $HOME/.zshrc.local ]] && source $HOME/.zshrc.local
