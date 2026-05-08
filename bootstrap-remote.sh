#!/usr/bin/env bash
# Idempotent installer for the binaries the zsh + git + kitty configs expect.
# Targets Debian / Ubuntu (apt). Comments below show equivalents for other
# distros — adapt by hand if needed. Safe to rerun.
#
# Run this once on a fresh machine (laptop, PC, dev box) BEFORE ./install.sh.

set -euo pipefail

if [[ "$EUID" -eq 0 ]]; then
  echo "don't run as root — sudo will be invoked when needed." >&2
  exit 1
fi

if ! command -v apt-get >/dev/null; then
  cat >&2 <<EOF
This script targets apt-based systems. For other distros, install equivalents:
  pacman:  zsh git curl stow base-devel openssl readline zlib fzf bat fd ripgrep zoxide direnv tldr eza lazygit git-delta
  dnf:     zsh git curl stow @development-tools openssl-devel readline-devel zlib-devel fzf bat fd-find ripgrep zoxide direnv tldr eza lazygit git-delta
  brew:    zsh git curl stow openssl readline fzf bat fd ripgrep zoxide direnv tldr eza lazygit git-delta tldr
EOF
  exit 1
fi

echo "==> updating apt index"
sudo apt-get update -y

echo "==> installing apt packages"
APT_PKGS=(
  zsh git curl wget unzip stow
  build-essential libssl-dev libreadline-dev zlib1g-dev libffi-dev libyaml-dev
  bat fd-find ripgrep tldr direnv
  python3-pip
)
sudo apt-get install -y "${APT_PKGS[@]}"

# Node.js + npx (needed for ccstatusline statusline). If an existing Node
# install (NodeSource, nvm, asdf) already provides npx, do nothing.
# Otherwise install Ubuntu's nodejs+npm pair together — installing only
# `npm` against a NodeSource nodejs would conflict.
if ! command -v npx >/dev/null; then
  echo "==> installing nodejs + npm"
  sudo apt-get install -y nodejs npm
fi

# eza: in Ubuntu 24.04+, available via apt. Otherwise add the eza repo.
if ! command -v eza >/dev/null; then
  if apt-cache show eza >/dev/null 2>&1; then
    sudo apt-get install -y eza
  else
    echo "==> adding eza apt repo"
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | \
      sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | \
      sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null
    sudo apt-get update -y
    sudo apt-get install -y eza
  fi
fi

# fzf: install from upstream git (apt's fzf is too old for `fzf --zsh`).
# Verify the binary is on PATH, not just the directory — a partial / interrupted
# previous run can leave ~/.fzf populated without ~/.local/bin/fzf symlinked.
if ! command -v fzf >/dev/null; then
  if [[ ! -d "$HOME/.fzf" ]]; then
    echo "==> cloning fzf"
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  fi
  if [[ ! -x "$HOME/.fzf/bin/fzf" ]]; then
    echo "==> building fzf binary"
    "$HOME/.fzf/install" --bin
  fi
  echo "==> symlinking fzf onto PATH"
  mkdir -p "$HOME/.local/bin"
  ln -sf "$HOME/.fzf/bin/fzf" "$HOME/.local/bin/fzf"
fi

# zoxide
if ! command -v zoxide >/dev/null; then
  echo "==> installing zoxide"
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi

# lazygit (from upstream release)
if ! command -v lazygit >/dev/null; then
  echo "==> installing lazygit"
  LAZYGIT_VERSION=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep -Po '"tag_name": "v\K[^"]*')
  curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" \
    -o /tmp/lazygit.tar.gz
  tar -xzf /tmp/lazygit.tar.gz -C /tmp lazygit
  sudo install /tmp/lazygit /usr/local/bin/
  rm /tmp/lazygit /tmp/lazygit.tar.gz
fi

# delta (git-delta)
if ! command -v delta >/dev/null; then
  echo "==> installing git-delta"
  DELTA_VERSION=$(curl -fsSL https://api.github.com/repos/dandavison/delta/releases/latest | grep -Po '"tag_name": "\K[^"]*')
  ARCH="$(dpkg --print-architecture)"
  curl -fsSL "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/git-delta_${DELTA_VERSION}_${ARCH}.deb" \
    -o /tmp/delta.deb
  sudo dpkg -i /tmp/delta.deb
  rm /tmp/delta.deb
fi

# Typo corrector: thefuck is broken on Python 3.12+ (uses removed `imp`
# module) and unmaintained since 2022. Verify any existing install actually
# works; otherwise skip with a hint to use pay-respects instead.
if command -v thefuck >/dev/null; then
  if ! thefuck --alias >/dev/null 2>&1; then
    echo "warn: thefuck is installed but broken (likely Python 3.12 'imp' issue)."
    echo "      consider: pip uninstall -y thefuck && cargo install pay-respects"
  fi
elif ! command -v pay-respects >/dev/null; then
  echo "==> skipping typo corrector (install manually: cargo install pay-respects)"
fi

# rbenv + ruby-build (Ruby version manager)
if [[ ! -d "$HOME/.rbenv" ]]; then
  echo "==> installing rbenv"
  git clone --depth 1 https://github.com/rbenv/rbenv.git "$HOME/.rbenv"
  git clone --depth 1 https://github.com/rbenv/ruby-build.git "$HOME/.rbenv/plugins/ruby-build"
fi

# Catppuccin Mocha theme for bat — referenced by git/.gitconfig's
# delta.syntax-theme. Without this, `git log` prints a "Unknown theme" warning.
if command -v bat >/dev/null || command -v batcat >/dev/null; then
  BAT_BIN="$(command -v bat || command -v batcat)"
  BAT_THEME_DIR="$("$BAT_BIN" --config-dir)/themes"
  if [[ ! -f "$BAT_THEME_DIR/Catppuccin Mocha.tmTheme" ]]; then
    echo "==> installing Catppuccin Mocha bat theme"
    mkdir -p "$BAT_THEME_DIR"
    curl -fsSL "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme" \
      -o "$BAT_THEME_DIR/Catppuccin Mocha.tmTheme"
    "$BAT_BIN" cache --build >/dev/null
  fi
fi

# Zap (zsh plugin manager)
if [[ ! -f "$HOME/.local/share/zap/zap.zsh" ]]; then
  echo "==> installing Zap"
  zsh <(curl -fsSL https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1 --keep
  # --keep prevents Zap from overwriting an existing ~/.zshrc.
fi

# Switch default shell to zsh.
if [[ "$SHELL" != "$(command -v zsh)" ]]; then
  echo "==> switching default shell to zsh (you'll be prompted for your password)"
  chsh -s "$(command -v zsh)" || echo "warn: chsh failed; do it manually: chsh -s \$(which zsh)"
fi

cat <<'EOF'

✔ bootstrap complete

next:
  cd ~/dotfiles && ./install.sh
  log out and back in (so the default shell change takes effect)
  in zsh:  p10k configure   to pick a prompt style
  put your name/email in ~/.gitconfig.local

reminders:
  - The MesloLGS NF font needs to be installed in your local terminal (kitty),
    not on the dev box — the rendering happens client-side.
  - On the dev box, MELSO won't help SSH unless your terminal is forwarding it
    via `kitten ssh`, which you've already configured.
EOF
