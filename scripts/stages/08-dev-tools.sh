#!/bin/bash
# 阶段 8: 编程工具安装

log_info "=== 阶段 8: 编程工具安装 ==="

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

# 主流程
main() {
  load_nvm
  install_claude_code
  install_dev_tools

  log_info "编程工具安装完成"
}

main
