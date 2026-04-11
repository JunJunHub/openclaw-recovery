#!/bin/bash
# 阶段 16: 验证测试

log_info "=== 阶段 16: 验证测试 ==="

OPENCLAW_DIR="$HOME/.openclaw"
CONFIG_FILE="$OPENCLAW_DIR/openclaw.json"

# ============================================
# Layer 1: Base Environment
# ============================================

# 验证系统工具
verify_system() {
  log_step "验证系统工具..."

  local tools=("curl" "wget" "git" "vim" "jq" "htop" "tmux" "tree" "sqlite3")
  local missing=0

  for tool in "${tools[@]}"; do
    if command -v "$tool" &> /dev/null; then
      log_info "✓ $tool 已安装"
    else
      log_error "✗ $tool 未安装"
      missing=$((missing + 1))
    fi
  done

  # 检查 SSH
  if systemctl is-active --quiet ssh; then
    log_info "✓ SSH 服务运行中"
  else
    log_warn "⚠ SSH 服务未运行"
  fi

  # 检查中文输入法
  if command -v ibus-daemon &> /dev/null; then
    log_info "✓ ibus 输入法框架已安装"
    if dpkg -l | grep -q ibus-pinyin; then
      log_info "✓ ibus-pinyin 拼音输入法已安装"
    fi
  fi

  if [ $missing -gt 0 ]; then
    return 1
  fi
}

# 验证 Docker
verify_docker() {
  log_step "验证 Docker..."

  if command -v docker &> /dev/null; then
    log_info "✓ Docker: $(docker --version | awk '{print $3}' | tr -d ',')"

    if systemctl is-active --quiet docker; then
      log_info "✓ Docker 服务运行中"
    else
      log_warn "⚠ Docker 服务未运行"
    fi

    if docker compose version &>/dev/null; then
      log_info "✓ Docker Compose: $(docker compose version --short)"
    fi

    if groups | grep -q docker; then
      log_info "✓ 用户在 docker 组中"
    else
      log_warn "⚠ 用户不在 docker 组，请执行 newgrp docker 或重新登录"
    fi
  else
    log_error "✗ Docker 未安装"
    return 1
  fi
}

# 验证 Node.js
verify_nodejs() {
  log_step "验证 Node.js..."

  local node_version=$(node --version 2>/dev/null)
  if [ -n "$node_version" ]; then
    log_info "✓ Node.js: $node_version"
    log_info "✓ npm: $(npm --version)"
  else
    log_error "✗ Node.js 未安装"
    return 1
  fi
}

# 验证 Python
verify_python() {
  log_step "验证 Python..."

  if command -v python3 &> /dev/null; then
    log_info "✓ Python3: $(python3 --version | awk '{print $2}')"
  else
    log_error "✗ Python3 未安装"
    return 1
  fi

  if command -v pip3 &> /dev/null; then
    log_info "✓ pip3: $(pip3 --version | awk '{print $2}')"
  fi

  if command -v uv &> /dev/null; then
    log_info "✓ uv: $(uv --version | awk '{print $2}')"
  else
    log_warn "⚠ uv 未安装"
  fi
}

# 验证 Go
verify_golang() {
  log_step "验证 Go..."

  if command -v go &> /dev/null; then
    log_info "✓ Go SDK: $(go version | awk '{print $3}')"
  else
    log_warn "⚠ Go 未安装"
  fi

  if command -v gvm &> /dev/null; then
    log_info "✓ gvm 已安装"
  else
    log_warn "⚠ gvm 未安装"
  fi
}

# ============================================
# Layer 2: OpenClaw Core
# ============================================

# 验证 Chrome
verify_chrome() {
  log_step "验证 Chrome..."

  if command -v google-chrome &> /dev/null; then
    log_info "✓ Chrome: $(google-chrome --version)"

    # 检查是否为 Snap 版本
    if snap list google-chrome &>/dev/null; then
      log_warn "⚠ Chrome 是 Snap 版本，建议使用 .deb 版本"
    fi
  else
    log_error "✗ Chrome 未安装"
    return 1
  fi
}

# 验证 OpenClaw
verify_openclaw() {
  log_step "验证 OpenClaw..."

  if command -v openclaw &> /dev/null; then
    log_info "✓ OpenClaw: $(openclaw --version)"
  else
    log_error "✗ OpenClaw 未安装"
    return 1
  fi

  # 检查目录
  if [ -d "$OPENCLAW_DIR" ]; then
    log_info "✓ .openclaw 目录存在"
  else
    log_error "✗ .openclaw 目录不存在"
    return 1
  fi
}

# 验证配置文件
verify_config() {
  log_step "验证配置文件..."

  if [ ! -f "$CONFIG_FILE" ]; then
    log_error "✗ 配置文件不存在"
    return 1
  fi

  # JSON 格式验证
  if jq empty "$CONFIG_FILE" 2>/dev/null; then
    log_info "✓ 配置文件格式正确"
  else
    log_error "✗ 配置文件 JSON 格式错误"
    return 1
  fi

  # 检查敏感信息是否已替换
  if grep -q "{{.*}}" "$CONFIG_FILE"; then
    log_warn "⚠ 配置文件包含未替换的占位符"
  else
    log_info "✓ 敏感信息已注入"
  fi
}

# 验证 Workspace
verify_workspaces() {
  log_step "验证 Workspace..."

  local workspaces=("workspace" "workspace-thinker" "workspace-media" "workspace-monitor" "workspace-coder")
  local missing=0

  for ws in "${workspaces[@]}"; do
    if [ -d "$OPENCLAW_DIR/$ws" ]; then
      log_info "✓ $ws"
    else
      log_error "✗ $ws 不存在"
      missing=$((missing + 1))
    fi
  done

  if [ $missing -gt 0 ]; then
    return 1
  fi
}

# ============================================
# Layer 3: Dev Tools & Applications
# ============================================

# 验证开发工具
verify_dev_tools() {
  log_step "验证开发工具..."

  # Claude Code
  if command -v claude &> /dev/null; then
    log_info "✓ Claude Code CLI 已安装"
  else
    log_warn "⚠ Claude Code CLI 未安装"
  fi

  # Codex CLI
  if command -v codex &> /dev/null; then
    log_info "✓ Codex CLI: $(codex --version 2>/dev/null || echo 'installed')"
  else
    log_warn "⚠ Codex CLI 未安装"
  fi

  # GitHub CLI
  if command -v gh &> /dev/null; then
    log_info "✓ GitHub CLI: $(gh --version | head -1 | awk '{print $3}')"
  else
    log_warn "⚠ GitHub CLI 未安装"
  fi

  # CC Switch
  if command -v cc-switch &> /dev/null; then
    log_info "✓ CC Switch 已安装"
  else
    log_warn "⚠ CC Switch 未安装"
  fi
}

# 验证文件共享
verify_file_sharing() {
  log_step "验证文件共享..."

  if systemctl is-active --quiet smbd; then
    log_info "✓ Samba 服务运行中"
  else
    log_warn "⚠ Samba 服务未运行"
  fi

  if [ -d "/home/Share" ]; then
    log_info "✓ 共享目录存在: /home/Share"
  else
    log_warn "⚠ 共享目录不存在"
  fi
}

# 验证 Obsidian
verify_obsidian() {
  log_step "验证 Obsidian..."

  if [ -f "$HOME/.local/bin/Obsidian.AppImage" ] || [ -f "$HOME/Applications/Obsidian.AppImage" ]; then
    log_info "✓ Obsidian AppImage 已安装"
  else
    log_warn "⚠ Obsidian 未安装"
  fi

  if [ -d "$OPENCLAW_DIR/obsidian" ]; then
    log_info "✓ Obsidian 知识库存在"
    if [ -d "$OPENCLAW_DIR/obsidian/.git" ]; then
      log_info "✓ Git 仓库已初始化"
    fi
  fi
}

# 验证 N8N
verify_n8n() {
  log_step "验证 N8N..."

  if command -v docker &> /dev/null && docker info &>/dev/null; then
    # 检查容器状态
    if docker ps --format '{{.Names}}' | grep -q "^n8n$"; then
      log_info "✓ N8N 容器运行中"
      local n8n_port=$(docker port n8n 5678 2>/dev/null | cut -d: -f2 | head -1)
      log_info "✓ 访问地址: http://localhost:${n8n_port:-5678}"
    elif docker ps -a --format '{{.Names}}' | grep -q "^n8n$"; then
      log_warn "⚠ N8N 容器已停止"
    else
      log_warn "⚠ N8N 容器未创建"
    fi

    # 检查数据目录
    if [ -d "$HOME/.n8n" ]; then
      log_info "✓ N8N 数据目录存在: ~/.n8n"
    fi
  else
    log_warn "⚠ Docker 未安装或无权限，跳过 N8N 验证"
  fi
}

# 验证 Qt
verify_qt() {
  log_step "验证 Qt..."

  if [ -d "$HOME/Qt" ]; then
    log_info "✓ Qt 安装目录: ~/Qt"

    # 查找 qmake
    local qmake_path=$(find "$HOME/Qt" -name "qmake" -path "*/gcc_64/bin/qmake" 2>/dev/null | head -1)
    if [ -n "$qmake_path" ]; then
      log_info "✓ Qt 版本: $($qmake_path --version 2>/dev/null | grep -oP 'Qt version \K[\d.]+')"
    else
      log_warn "⚠ 未找到 qmake"
    fi

    # 检查 Qt Creator
    if [ -f "$HOME/Qt/Tools/QtCreator/bin/qtcreator" ]; then
      log_info "✓ Qt Creator 已安装"
    fi
  else
    log_warn "⚠ Qt 未安装"
  fi
}

# 生成报告
generate_report() {
  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "                    📋 当前环境状态"
  echo "═══════════════════════════════════════════════════════════════"
  echo ""

  local errors=0

  # Layer 1: Base Environment
  echo "【基础环境层】"
  verify_system || errors=$((errors + 1))
  verify_docker || errors=$((errors + 1))
  verify_nodejs || errors=$((errors + 1))
  verify_python || errors=$((errors + 1))
  verify_golang
  echo ""

  # Layer 2: OpenClaw Core
  echo "【OpenClaw 层】"
  verify_chrome || errors=$((errors + 1))
  verify_openclaw || errors=$((errors + 1))
  verify_config || errors=$((errors + 1))
  verify_workspaces || errors=$((errors + 1))
  echo ""

  # Layer 3: Dev Tools & Applications
  echo "【开发工具层】"
  verify_dev_tools
  echo ""

  echo "【应用层】"
  verify_file_sharing
  verify_obsidian
  verify_n8n
  verify_qt
  echo ""

  echo "═══════════════════════════════════════════════════════════════"

  if [ $errors -eq 0 ]; then
    log_info "✓ 验证通过！"
  else
    log_error "✗ 发现 $errors 个错误"
  fi

  echo "═══════════════════════════════════════════════════════════════"
}

# 主流程
main() {
  generate_report
}

main
