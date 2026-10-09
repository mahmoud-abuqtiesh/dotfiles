# Dotfiles

Personal machine configuration, stowed into `$HOME`.
Covers shell, terminal, git, and agent (Claude Code) setup.

## Language

**Global config**:
Agent configuration that loads in every session regardless of working directory; lives in this repo or in user-scope state.
_Avoid_: user settings, default config

**Project-local config**:
Agent configuration that loads only inside one project's directory and is never tracked in that project's git.
Maqsam work config is project-local.
_Avoid_: project settings, repo config

**Checker context**:
The description of trusted repos, domains, secrets, and sensitive targets that the auto-mode safety checker reads before approving actions.
It can only be global config.
_Avoid_: trusted repo, environment
