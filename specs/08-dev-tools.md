# 开发工具规格

## 概述

安装常用编程开发工具，包括 Claude Code CLI 和 GitHub CLI。

## 安装内容

| 工具 | 说明 | 用途 |
|------|------|------|
| Claude Code | Anthropic 官方 CLI | AI 辅助编程 |
| GitHub CLI | GitHub 命令行工具 | Git 操作、PR 管理 |

## Claude Code CLI

### 安装方式
通过 npm 全局安装。

### 安装命令
```bash
npm install -g @anthropic-ai/claude-code
```

### 使用方式
```bash
# 启动交互式会话
claude

# 指定模型
claude --model claude-3-opus

# 查看版本
claude --version
```

### 配置要求
- 需要配置 `ANTHROPIC_API_KEY` 环境变量
- 或通过 `claude login` 进行认证

## GitHub CLI

### 安装方式
通过 GitHub 官方 APT 仓库安装。

### 安装命令
```bash
# 添加 GitHub CLI 仓库
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
  sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
  https://cli.github.com/packages stable main" | \
  sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# 安装
sudo apt-get update
sudo apt-get install -y gh
```

### 认证方式
```bash
# 浏览器认证
gh auth login

# 查看认证状态
gh auth status

# 查看配置
gh config list
```

### 常用命令
```bash
# 仓库操作
gh repo clone owner/repo
gh repo create
gh repo fork

# PR 操作
gh pr create
gh pr list
gh pr checkout 123

# Issue 操作
gh issue create
gh issue list

# Actions
gh run list
gh run watch
```

## 验证方法

```bash
# 验证 Claude Code
claude --version

# 验证 GitHub CLI
gh --version

# 验证 GitHub 认证
gh auth status
```

## 配置文件

### Claude Code
- 配置目录: `~/.config/claude/`
- 环境变量: `ANTHROPIC_API_KEY`

### GitHub CLI
- 配置目录: `~/.config/gh/`
- 认证文件: `~/.config/gh/hosts.yml`

## 系统要求

- Node.js v18+ (用于 Claude Code)
- curl, git
- Ubuntu 22.04 / 24.04
