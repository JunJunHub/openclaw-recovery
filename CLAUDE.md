# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

OpenClaw Recovery is a one-click recovery tool for quickly deploying OpenClaw and related development environments in new Ubuntu VMs. It installs system dependencies, Node.js, Chrome, OpenClaw CLI, Python tools, Go environment, and various desktop applications.

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
```

## Architecture

The installer follows a modular stage-based architecture:

```
scripts/
├── install.sh          # Main entry point, argument parsing, stage orchestration
├── lib/
│   └── common.sh       # Shared functions (logging, checks, secret injection)
└── stages/
    ├── 01-system.sh    # System deps, SSH, Chinese input
    ├── 02-node.sh      # NVM + Node.js v24
    ├── 03-chrome.sh    # Google Chrome
    ├── 04-openclaw.sh  # OpenClaw CLI
    ├── 05-config.sh    # Config file restoration (high risk)
    ├── 06-workspaces.sh
    ├── 07-verify.sh
    ├── 08-dev-tools.sh # Claude Code, GitHub CLI
    ├── 09-file-sharing.sh  # Samba (high risk)
    ├── 10-obsidian.sh
    ├── 11-python.sh    # pip, uv, dev tools
    └── 12-golang.sh    # gvm, Go SDK
```

Each stage script is sourced by `install.sh` and uses functions from `common.sh`.

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

## Important Functions (common.sh)

- `log_info/warn/error/step()` - Colored logging
- `check_environment()` - Comprehensive system state check
- `inject_secrets()` - Template variable replacement
- `show_config_diff()` - Preview config changes before overwrite
- `confirm_overwrite()` - User confirmation for risky operations

## Risk Levels

| Stage | Risk | Reason |
|-------|------|--------|
| `config` | High | Overwrites `~/.openclaw/openclaw.json` |
| `file-sharing` | High | Modifies `/etc/samba/smb.conf` |

Both create backups before modifying.

## Testing

This tool is designed for **new VM environments only**. Using `--check` first is recommended to inspect current environment state without making changes.
