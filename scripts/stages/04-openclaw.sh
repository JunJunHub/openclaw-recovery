#!/bin/bash
# 阶段 4: OpenClaw 安装

log_info "=== 阶段 4: OpenClaw 安装 ==="

OPENCLAW_DIR="$HOME/.openclaw"

# 加载 NVM
load_nvm() {
  if [ -s "$HOME/.nvm/nvm.sh" ]; then
    source "$HOME/.nvm/nvm.sh"
  else
    log_error "NVM 未安装，请先执行 --stage node"
    return 1
  fi
}

# 安装 OpenClaw
install_openclaw() {
  log_step "安装 OpenClaw: $OPENCLAW_PACKAGE"

  # 确保使用淘宝镜像
  npm config set registry https://registry.npmmirror.com

  # 检查是否已安装
  if command_exists openclaw; then
    local current_version=$(openclaw --version 2>/dev/null || echo "unknown")
    log_info "OpenClaw 已安装: $current_version"

    read -p "是否重新安装？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      return 0
    fi

    # 卸载旧版本（尝试两个包名）
    npm uninstall -g openclaw-cn 2>/dev/null || true
    npm uninstall -g openclaw 2>/dev/null || true
  fi

  # 安装
  log_info "安装 $OPENCLAW_PACKAGE..."
  npm install -g "$OPENCLAW_PACKAGE"

  # 验证
  if command_exists openclaw; then
    log_info "OpenClaw 安装成功: $(openclaw --version)"
  else
    log_error "OpenClaw 安装失败"
    return 1
  fi
}

# 初始化 OpenClaw
init_openclaw() {
  log_step "初始化 OpenClaw..."

  # 创建目录结构
  mkdir -p "$OPENCLAW_DIR"

  # 运行 doctor（会创建默认配置）
  openclaw doctor || true

  log_info "OpenClaw 初始化完成"
}

# 主流程
main() {
  load_nvm
  install_openclaw
  init_openclaw

  log_info "OpenClaw 安装完成"
}

main
