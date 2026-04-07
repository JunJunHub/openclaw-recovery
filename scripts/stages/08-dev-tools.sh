#!/bin/bash
# 阶段 8: 编程工具安装

log_info "=== 阶段 8: 编程工具安装 ==="

# 配置
CC_SWITCH_VERSION="3.12.3"
CC_SWITCH_DOWNLOAD_URL="https://github.com/farion1231/cc-switch/releases/download/v${CC_SWITCH_VERSION}"
CC_SWITCH_INSTALL_DIR="$HOME/Applications"

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

# 安装 CC Switch
install_cc_switch() {
  log_step "安装 CC Switch..."

  # CC Switch - 跨平台 AI 编程工具管理器
  # 支持: Claude Code, Codex, OpenCode, OpenClaw, Gemini CLI

  local cc_switch_bin="/usr/bin/cc-switch"
  local appimage_file="CC-Switch-v${CC_SWITCH_VERSION}-Linux.AppImage"
  local appimage_path="$CC_SWITCH_INSTALL_DIR/$appimage_file"

  # 检查是否已安装
  if [ -f "$cc_switch_bin" ] || [ -f "$appimage_path" ]; then
    log_info "CC Switch 已安装"
    if [ -f "$cc_switch_bin" ]; then
      cc-switch --version 2>/dev/null || log_info "版本: $CC_SWITCH_VERSION"
    fi
    return 0
  fi

  log_info "CC Switch: 跨平台 AI 编程工具管理器"
  log_info "支持: Claude Code, Codex, OpenCode, OpenClaw, Gemini CLI"

  # 创建安装目录
  mkdir -p "$CC_SWITCH_INSTALL_DIR"

  # 下载 AppImage（通用格式）
  log_info "下载 CC Switch v${CC_SWITCH_VERSION}..."
  local download_url="${CC_SWITCH_DOWNLOAD_URL}/${appimage_file}"

  if wget -q --show-progress -O "$appimage_path" "$download_url"; then
    chmod +x "$appimage_path"
    log_info "CC Switch 下载完成: $appimage_path"

    # 创建符号链接
    sudo ln -sf "$appimage_path" "$cc_switch_bin"

    # 创建桌面快捷方式
    local desktop_file="$HOME/.local/share/applications/cc-switch.desktop"
    mkdir -p "$(dirname "$desktop_file")"

    cat > "$desktop_file" << EOF
[Desktop Entry]
Type=Application
Name=CC Switch
Comment=AI Coding Assistant Manager
Exec=$appimage_path
Icon=cc-switch
Terminal=false
Categories=Development;IDE;
EOF

    log_info "CC Switch 安装成功"
    log_info "  启动命令: cc-switch"
    log_info "  桌面快捷方式: 应用菜单 → CC Switch"
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
  install_dev_tools
  install_cc_switch

  log_info "编程工具安装完成"
}

main
