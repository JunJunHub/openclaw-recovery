#!/bin/bash
# 阶段 11: 编程工具安装

log_info "=== 阶段 11: 编程工具安装 ==="

# 配置
CC_SWITCH_VERSION="3.12.3"
CC_SWITCH_DOWNLOAD_URL="https://github.com/farion1231/cc-switch/releases/download/v${CC_SWITCH_VERSION}"

# 加载 NVM
load_nvm() {
  if [ -s "$HOME/.nvm/nvm.sh" ]; then
    source "$HOME/.nvm/nvm.sh"
  else
    log_error "NVM 未安装，请先执行 --stage node"
    return 1
  fi
}

# 安装 Claude Code CLI
install_claude_code() {
  log_step "安装 Claude Code CLI..."

  # 确保使用淘宝镜像
  npm config set registry https://registry.npmmirror.com

  # 检查是否已安装
  if command_exists claude; then
    local current_version=$(claude --version 2>/dev/null || echo "unknown")
    log_info "Claude Code 已安装: $current_version"

    read -p "是否重新安装？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      return 0
    fi

    npm uninstall -g @anthropic-ai/claude-code
  fi

  # 安装 Claude Code CLI
  log_info "安装 @anthropic-ai/claude-code..."
  npm install -g @anthropic-ai/claude-code

  # 验证
  if command_exists claude; then
    log_info "Claude Code 安装成功: $(claude --version 2>/dev/null || echo 'installed')"
  else
    log_warn "Claude Code 安装可能失败，请手动检查"
  fi
}

# 安装 Codex CLI
install_codex_cli() {
  log_step "安装 Codex CLI (OpenAI)..."

  # 检查是否已安装
  if command_exists codex; then
    local current_version=$(codex --version 2>/dev/null || echo "unknown")
    log_info "Codex CLI 已安装: $current_version"

    read -p "是否重新安装？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      return 0
    fi

    npm uninstall -g @openai/codex
  fi

  # 使用国内镜像安装
  log_info "安装 @openai/codex (使用 npmmirror 镜像)..."
  npm install -g @openai/codex --registry=https://registry.npmmirror.com

  # 验证
  if command_exists codex; then
    log_info "Codex CLI 安装成功: $(codex --version 2>/dev/null || echo 'installed')"
    log_info "  启动命令: codex"
    log_info "  认证方式: ChatGPT 账号登录 或 API Key"
    log_info "  配置文件: ~/.codex/config.toml"
  else
    log_warn "Codex CLI 安装可能失败，请手动检查"
  fi
}

# 安装其他编程工具
install_dev_tools() {
  log_step "安装其他编程工具..."

  # GitHub CLI
  if ! command_exists gh; then
    log_info "安装 GitHub CLI..."
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt-get update -qq
    sudo apt-get install -y gh
  else
    log_info "GitHub CLI 已安装: $(gh --version | head -1)"
  fi
}

# 安装 CC Switch
install_cc_switch() {
  log_step "安装 CC Switch..."

  # CC Switch - 跨平台 AI 编程工具管理器
  # 支持: Claude Code, Codex, OpenCode, OpenClaw, Gemini CLI

  # 检查是否已安装（通过 dpkg）
  if dpkg -l cc-switch 2>/dev/null | grep -q "^ii"; then
    local installed_version=$(dpkg -l cc-switch 2>/dev/null | awk '/^ii/{print $3}')
    log_info "CC Switch 已安装: $installed_version"
    log_info "卸载命令: sudo apt remove cc-switch"
    return 0
  fi

  log_info "CC Switch: 跨平台 AI 编程工具管理器"
  log_info "支持: Claude Code, Codex, OpenCode, OpenClaw, Gemini CLI"

  # 下载 deb 包
  local deb_file="CC-Switch-v${CC_SWITCH_VERSION}-Linux-amd64.deb"
  local deb_path="/tmp/$deb_file"
  local download_url="${CC_SWITCH_DOWNLOAD_URL}/${deb_file}"

  log_info "下载 CC Switch v${CC_SWITCH_VERSION}..."

  if wget -q --show-progress -O "$deb_path" "$download_url"; then
    log_info "安装 CC Switch..."
    sudo apt install -y "$deb_path"

    # 清理下载文件
    rm -f "$deb_path"

    # 验证安装
    if dpkg -l cc-switch 2>/dev/null | grep -q "^ii"; then
      log_info "CC Switch 安装成功"
      log_info "  启动命令: cc-switch"
      log_info "  桌面快捷方式: 应用菜单 → CC Switch"
      log_info "  应用内自动更新: 支持"
      log_info "  卸载命令: sudo apt remove cc-switch"
    else
      log_warn "CC Switch 安装可能失败，请手动检查"
    fi
  else
    log_error "CC Switch 下载失败"
    log_info "手动下载: https://github.com/farion1231/cc-switch/releases"
    return 1
  fi
}

# 主流程
main() {
  load_nvm
  install_claude_code
  install_codex_cli
  install_dev_tools
  install_cc_switch

  log_info "编程工具安装完成"
}

main
