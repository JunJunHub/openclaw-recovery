# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

OpenClaw Recovery is a one-click recovery tool for quickly deploying OpenClaw and related development environments in new Ubuntu VMs. It installs system dependencies, Node.js, Chrome, OpenClaw CLI, Python tools, Go environment, Qt, Docker, and various desktop applications.

## Key Commands

```bash
# Environment check (safe, no installation)
./scripts/install.sh --check

# Full installation
./scripts/install.sh --all

# Install specific stage
./scripts/install.sh --stage <stage-name>

# OpenClaw version selection
./scripts/install.sh --all --version original  # default
./scripts/install.sh --all --version cn        # community edition

# Interactive secrets input
./scripts/install.sh --all --interactive
```

## Architecture

The installer follows a modular stage-based architecture:

```
scripts/
├── install.sh          # Main entry point, argument parsing, stage orchestration
├── lib/
│   └── common.sh       # Shared functions (logging, checks, secret injection)
└── stages/
    ├── 01-system.sh       # System deps, SSH, Chinese input
    ├── 02-github-hosts.sh # GitHub hosts configuration
    ├── 03-node.sh         # NVM + Node.js v24
    ├── 04-chrome.sh       # Google Chrome
    ├── 05-openclaw.sh     # OpenClaw CLI
    ├── 06-config.sh       # Config file restoration
    ├── 07-workspaces.sh   # Workspace directories
    ├── 08-dev-tools.sh    # Claude Code, GitHub CLI, CC Switch
    ├── 09-file-sharing.sh # Samba file sharing
    ├── 10-obsidian.sh     # Obsidian AppImage
    ├── 11-python.sh       # pip, uv, dev tools
    ├── 12-golang.sh       # gvm, Go SDK
    ├── 13-qt.sh           # Qt 6.8 LTS
    ├── 14-docker.sh       # Docker CE
    └── 15-verify.sh       # Verification tests
```

Each stage script is sourced by `install.sh` and uses functions from `common.sh`.

## Stage Reference

| Stage | Command | Risk | Description |
|-------|---------|------|-------------|
| 01-system | `--stage system` | Low | System deps, SSH, Chinese input |
| 02-github-hosts | `--stage github-hosts` | Low | GitHub hosts for access stability |
| 03-node | `--stage node` | Low | NVM + Node.js v24 |
| 04-chrome | `--stage chrome` | Low | Google Chrome |
| 05-openclaw | `--stage openclaw` | Medium | OpenClaw CLI + Serper plugin |
| 06-config | `--stage config` | High | Overwrites `~/.openclaw/openclaw.json` |
| 07-workspaces | `--stage workspaces` | Low | Creates workspace directories |
| 08-dev-tools | `--stage dev-tools` | Medium | Claude Code, GitHub CLI, CC Switch |
| 09-file-sharing | `--stage file-sharing` | High | Modifies `/etc/samba/smb.conf` |
| 10-obsidian | `--stage obsidian` | Low | Obsidian AppImage |
| 11-python | `--stage python` | Low | pip, uv, pytest, jupyter |
| 12-golang | `--stage golang` | Low | gvm, Go SDK, gopls, dlv |
| 13-qt | `--stage qt` | Low | Qt 6.8 LTS + Qt Creator |
| 14-docker | `--stage docker` | Low | Docker CE + Compose |
| 15-verify | `--stage verify` | Low | Full verification tests |

## Configuration

### Secrets Management

Sensitive data is handled via `config/secrets.env` (gitignored):

```bash
cp config/secrets.env.example config/secrets.env
# Edit with real values
```

Template placeholders in `config/openclaw.json.template`:
- `{{SILICONFLOW_API_KEY}}`
- `{{BAIDU_QIANFAN_API_KEY}}`
- `{{TAVILY_API_KEY}}`
- `{{EXA_API_KEY}}`
- `{{FEISHU_APP_ID}}`, `{{FEISHU_APP_SECRET}}`
- `{{GATEWAY_TOKEN}}`

The `inject_secrets()` function in `common.sh` replaces these at install time.

### OpenClaw Version Types

| Version | Package | Notes |
|---------|---------|-------|
| `original` | `openclaw@latest` | Default, latest features, Chrome MCP |
| `cn` | `openclaw-cn@latest` | Community edition, built-in Feishu/DingTalk |

## Development

### Testing a Single Stage

```bash
# Test a stage in isolation (recommended for development)
./scripts/install.sh --stage node
./scripts/install.sh --stage python
```

### Key Functions (common.sh)

- `log_info/warn/error/step()` - Colored logging
- `check_environment()` - Comprehensive system state check (used by `--check`)
- `inject_secrets()` - Template variable replacement
- `show_config_diff()` + `confirm_overwrite()` - Safe config modification pattern

### Risk Levels

High-risk stages (`config`, `file-sharing`) automatically create backups before modifying files.

## Testing

Designed for **new VM environments only**. Always run `--check` first to inspect environment state without making changes.
