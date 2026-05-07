#!/usr/bin/env bash
# Idempotent installer for this dotfiles repo.
# Stows packages into $HOME, with backups for any pre-existing real files at
# the target paths. Safe to rerun.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(kitty zsh git claude)
TS="$(date +%Y%m%d-%H%M%S)"

if ! command -v stow >/dev/null 2>&1; then
  echo "error: GNU stow is not installed. install with: sudo apt install stow" >&2
  exit 1
fi

# 1. Back up any pre-existing real (non-symlink) files that stow would replace.
for pkg in "${PACKAGES[@]}"; do
  pkg_dir="$REPO/$pkg"
  [[ -d "$pkg_dir" ]] || continue
  while IFS= read -r src; do
    rel="${src#$pkg_dir/}"
    # Skip the .example template — never stowed; user copies it manually.
    [[ "$rel" == *.example ]] && continue
    target="$HOME/$rel"
    # Skip if the target already resolves to the source (e.g. a parent dir
    # is a stow symlink into this repo) — otherwise mv would rename the
    # real file inside the repo.
    if [[ -e "$target" && ! -L "$target" \
          && "$(readlink -f -- "$target")" != "$(readlink -f -- "$src")" ]]; then
      backup="$target.pre-dotfiles.$TS"
      echo "backing up $target -> $backup"
      mv "$target" "$backup"
    fi
  done < <(find "$pkg_dir" -mindepth 1 -type f)
done

# 2. Stow each package. --ignore filters the .example file out of the link set.
cd "$REPO"
stow --target="$HOME" --restow --ignore='\.example$' "${PACKAGES[@]}"

# 3. Create per-machine override stubs (gitignored) if absent.
KITTY_CUSTOM="$HOME/.config/kitty/kitty-custom.conf"
if [[ ! -e "$KITTY_CUSTOM" ]]; then
  echo "creating $KITTY_CUSTOM"
  cat > "$KITTY_CUSTOM" <<'EOF'
# Per-machine kitty overrides. Gitignored — local to this machine only.
# Last-loaded, so anything here wins over the tracked configs.
#
# Examples:
# font_size 13.5
# background_opacity 0.95
# font_family Iosevka Nerd Font
EOF
fi

ZSHRC_LOCAL="$HOME/.zshrc.local"
if [[ ! -e "$ZSHRC_LOCAL" ]]; then
  echo "creating $ZSHRC_LOCAL"
  cat > "$ZSHRC_LOCAL" <<'EOF'
# Per-machine zsh overrides. Gitignored. Sourced last by ~/.zshrc.
#
# Examples:
# export GOPATH="$HOME/go"
# alias work='cd ~/work/main-project'
EOF
fi

GITCONFIG_LOCAL="$HOME/.gitconfig.local"
if [[ ! -e "$GITCONFIG_LOCAL" ]]; then
  echo "creating $GITCONFIG_LOCAL (edit it to add your name/email)"
  cp "$REPO/git/.gitconfig.local.example" "$GITCONFIG_LOCAL"
fi

cat <<EOF

✔ install complete
   repo:    $REPO
   stowed:  ${PACKAGES[*]}
   stubs:   $KITTY_CUSTOM, $ZSHRC_LOCAL, $GITCONFIG_LOCAL  (all gitignored)

next steps:
  - put your name/email in ~/.gitconfig.local
  - install MesloLGS NF font (see README)
  - if zsh isn't your default shell yet:  chsh -s "\$(which zsh)"  then re-login
  - in zsh, run:  p10k configure   to pick a prompt style (writes through symlink to repo)
  - reload kitty: ctrl+shift+f5
  - on a new dev box, run ./bootstrap-remote.sh first to install required binaries
EOF
