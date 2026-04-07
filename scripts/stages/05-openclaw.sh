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

# 安装 Serper 搜索插件
install_serper_plugin() {
  log_step "安装 Serper 搜索插件..."

  # Serper 插件包名（根据实际情况调整）
  local serper_package="@openclaw/plugin-serper"
  
  # 检查是否已安装
  if npm list -g "$serper_package" 2>/dev/null | grep -q "$serper_package"; then
    log_info "Serper 插件已安装"
    return 0
  fi

  # 尝试安装 serper 插件
  log_info "正在安装 Serper 插件..."
  
  # 方式1: 通过 npm 安装（如果存在独立包）
  if npm install -g "openclaw-plugin-serper" 2>/dev/null; then
    log_info "Serper 插件安装成功"
    return 0
  fi
  
  # 方式2: 如果是内置插件，创建默认配置
  log_info "配置 Serper 插件..."
  
  local config_file="$OPENCLAW_DIR/openclaw.json"
  local temp_config="/tmp/openclaw-serper-config.json"
  
  # 检查配置文件是否存在
  if [ ! -f "$config_file" ]; then
    log_warn "OpenClaw 配置文件不存在，跳过 Serper 配置"
    return 0
  fi
  
  # 添加 Serper 配置（如果配置中没有）
  if ! grep -q "serper" "$config_file" 2>/dev/null; then
    # 创建带有 Serper 配置的片段
    cat > "$temp_config" << 'EOF'
{
  "plugins": {
    "serper": {
      "enabled": true,
      "apiKey": "{{SERPER_API_KEY}}"
    }
  }
}
EOF
    
    log_info "已创建 Serper 插件配置模板"
    log_info "请配置 SERPER_API_KEY 到 config/secrets.env"
    
    rm -f "$temp_config"
  else
    log_info "Serper 插件配置已存在"
  fi
  
  # 显示 Serper 配置说明
  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "                    🔍 Serper 搜索插件配置"
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
  echo "Serper 插件提供 Google 搜索功能，支持："
  echo "  • 网页搜索"
  echo "  • 学术论文搜索"
  echo "  • 新闻搜索"
  echo ""
  echo "获取 API Key："
  echo "  1. 访问 https://serper.dev"
  echo "  2. 注册账号（免费 2500 次/月）"
  echo "  3. 获取 API Key"
  echo ""
  echo "配置方式："
  echo "  方式1: 添加到 config/secrets.env"
  echo "    SERPER_API_KEY=your_api_key_here"
  echo ""
  echo "  方式2: 直接配置到 openclaw.json"
  echo "    {"
  echo '      "plugins": {'
  echo '        "serper": {'
  echo '          "apiKey": "your_api_key_here"'
  echo "        }"
  echo "      }"
  echo "    }"
  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
}

# 主流程
main() {
  load_nvm
  install_openclaw
  init_openclaw
  install_serper_plugin

  log_info "OpenClaw 安装完成"
}

main
