# Environment variables and shell options.

# --- PATH ---
typeset -U path PATH
path=(
  $HOME/.local/bin
  $HOME/bin
  $path
)
export PATH

# --- Editor ---
export EDITOR="${EDITOR:-nvim}"
(( ! $+commands[nvim] )) && export EDITOR=vim
export VISUAL="$EDITOR"

# --- History ---
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY            # share history across sessions
setopt HIST_IGNORE_DUPS         # collapse adjacent dupes
setopt HIST_IGNORE_ALL_DUPS     # remove older dup when new one added
setopt HIST_IGNORE_SPACE        # commands starting with space aren't recorded
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY              # don't auto-execute !! expansions
setopt EXTENDED_HISTORY         # timestamps in history file

# --- Misc shell options ---
setopt AUTO_CD                  # `dirname` alone cd's into it
setopt AUTO_PUSHD               # cd builds a dir stack
setopt PUSHD_IGNORE_DUPS
setopt INTERACTIVE_COMMENTS     # # comments allowed at the prompt
setopt NO_BEEP

# --- Locale ---
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

# --- bat / less ---
export PAGER="${PAGER:-less}"
# -R: pass through ANSI color escapes (delta needs this).
# No --mouse: letting less grab mouse events breaks click-drag selection in
# kitty for git log/diff. Use shift+scroll for scrollback if desired.
export LESS='-R'
export MANPAGER="sh -c 'col -bx | bat -l man -p'"  # if bat exists, syntax-highlights man pages
