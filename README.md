# dotfiles

Personal config shared between laptop, PC, and the dev box. Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Layout

| Package | Stows to | What's in it |
|---|---|---|
| `kitty/` | `~/.config/kitty/` | modular kitty config (theme, fonts, ui, keys, ssh) |
| `zsh/` | `~/`, `~/.config/zsh/` | `.zshrc`, `.p10k.zsh`, modular config snippets |
| `git/` | `~/` | `.gitconfig` with delta + sane defaults |

Per-machine override files (gitignored, loaded last):
- `~/.config/kitty/kitty-custom.conf`
- `~/.zshrc.local`
- `~/.gitconfig.local` (your name/email go here)

## Install

### Fresh laptop / PC

```sh
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
./bootstrap-remote.sh   # installs all binaries (zsh, fzf, eza, lazygit, rbenv, ...)
./install.sh            # stows configs + creates the .local stub files
```

Then log out / back in (so zsh becomes the default shell) and:

```sh
p10k configure          # pick a prompt style — writes through symlink into the repo
$EDITOR ~/.gitconfig.local   # set your name + email
```

### Dev box

Same flow:

```sh
ssh dev@development-mahmoudabuqteish        # uses kitten ssh; terminfo travels
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
./bootstrap-remote.sh
./install.sh
exit                # log out
ssh dev@...         # re-enter — now p10k is your prompt on the remote
```

`./install.sh` is idempotent. Re-run anytime after pulling new commits.

## What you get

### kitty

- Catppuccin Mocha theme, opaque background, block cursor.
- Splits + stack layouts (`ctrl+shift+\` and `ctrl+shift+'` to split, `ctrl+shift+space` to zoom).
- `ctrl+shift+d` opens a new tab into your dev SSH.
- `ssh` aliased to `kitten ssh` so terminfo + zsh dotfiles travel automatically.
- Keybindings cheat sheet at `kitty/.config/kitty/keys.conf`.

### zsh

- **Powerlevel10k** prompt — run `p10k configure` after install.
- **Zap** plugin manager (kept from your existing setup).
- **Plugins**: fzf-tab, autosuggestions, fast-syntax-highlighting, completions, autopair, history-substring-search, you-should-use, fzf-git.
- **fzf** integration: `ctrl+t` files, `ctrl+r` history, `ctrl+g, b/h/f/t/s/r` for git stuff, fzf-tab replaces the tab-complete menu with fuzzy + previews.
- **Tools**: zoxide (smart cd → use `z`), thefuck (correct typos with `fuck`), direnv, tldr, rbenv.
- **Aliases**: `cat`→`bat`, `ls/ll/la/lt`→`eza` w/ icons, `lg`→`lazygit`. (No git/ruby/rails aliases by request.)
- All tool inits + aliases are guarded — missing binaries are silent no-ops.

### git

- Pull rebases, push auto-sets-upstream, default branch `main`.
- `delta` as the diff/log pager (side-by-side, navigate, syntax-highlighted).
- Identity in `~/.gitconfig.local` (gitignored).

## Per-machine overrides

| File | Purpose |
|---|---|
| `~/.config/kitty/kitty-custom.conf` | font size, opacity, anything kitty.conf can set |
| `~/.zshrc.local` | machine-specific env vars, work-vs-personal aliases |
| `~/.gitconfig.local` | name, email, signing key |

Loaded last; overrides win.

## Fonts

Install **MesloLGS NF** (the Powerlevel10k-recommended Meslo fork) on each machine that runs the *terminal* (kitty). Not needed on the dev box — rendering is client-side.

Download the four ttf files:

- https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
- https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
- https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
- https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf

```sh
mkdir -p ~/.local/share/fonts
# move the four .ttf files there, then:
fc-cache -f
```

## Auto-reload kitty.conf on save

Kitty doesn't watch the config by default. Patch its desktop entry once:

```sh
mkdir -p ~/.local/share/applications
cp /usr/share/applications/kitty.desktop ~/.local/share/applications/
sed -i 's|^Exec=kitty|Exec=kitty --watch-config|' ~/.local/share/applications/kitty.desktop
```

Edits to any included config now reload live. Manual reload remains `ctrl+shift+f5`.

## Drop-down terminal (Guake / iTerm-style)

Kitty ships `kitty +kitten quick_access_terminal`. Bind a system shortcut in GNOME (Settings → Keyboard → Custom Shortcuts) with:

- Command: `kitty +kitten quick_access_terminal`
- Shortcut: `F12` (or whatever)

## Custom keybindings cheat sheet (kitty)

| Bind | Action |
|---|---|
| `ctrl+shift+t` | New tab in current cwd |
| `ctrl+shift+enter` | New window in current cwd |
| `ctrl+shift+y` | Plain new tab |
| `ctrl+shift+\` | Vertical split (right) |
| `ctrl+shift+'` | Horizontal split (down) |
| `ctrl+shift+d` | New tab → SSH dev box |

Inherited kitty defaults (hints, layout cycling, scrollback navigation) are documented in `kitty/.config/kitty/keys.conf` as comments.

## fzf cheat sheet (zsh)

| Bind | Action |
|---|---|
| `ctrl+t` | Fuzzy file picker (inserts at cursor) |
| `ctrl+r` | Fuzzy history search |
| `<Tab>` | fzf-tab takes over with previews (eza tree for dirs, bat for files, git log for branches) |
| `ctrl+g` then `b` | Git branches |
| `ctrl+g` then `h` | Git commit hashes |
| `ctrl+g` then `f` | Modified/untracked files |
| `ctrl+g` then `t` | Git tags |
| `ctrl+g` then `s` | Git stashes |
| `ctrl+g` then `r` | Git remotes |
