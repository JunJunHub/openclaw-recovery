#!/bin/bash
# 阶段 7: 验证测试

log_info "=== 阶段 7: 验证测试 ==="

OPENCLAW_DIR="$HOME/.openclaw"
CONFIG_FILE="$OPENCLAW_DIR/openclaw.json"

# 验证 Node.js
verify_nodejs() {
  log_step "验证 Node.js..."

  local node_version=$(node --version 2>/dev/null)
  if [[ "$node_version" == "v24.14.0" ]]; then
    log_info "✓ Node.js: $node_version"
  else
    log_error "✗ Node.js 版本不正确: $node_version (期望: v24.14.0)"
    return 1
  fi

  log_info "✓ npm: $(npm --version)"
}

# 验证 Chrome
verify_chrome() {
  log_step "验证 Chrome..."

  if command -v google-chrome &> /dev/null; then
    log_info "✓ Chrome: $(google-chrome --version)"

    # 检查是否为 Snap 版本
    if snap list google-chrome &>/dev/null; then
      log_warn "Chrome 是 Snap 版本，建议使用 .deb 版本"
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

# 验证 Obsidian
verify_obsidian() {
  log_step "验证 Obsidian..."

  if [ -d "$OPENCLAW_DIR/obsidian" ]; then
    log_info "✓ Obsidian 知识库存在"

    if [ -d "$OPENCLAW_DIR/obsidian/.git" ]; then
      log_info "✓ Git 仓库已初始化"
    fi
  else
    log_warn "⚠ Obsidian 知识库不存在"
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
      log_info "✓ Docker Compose: $(docker compose version | awk '{print $4}' | tr -d ',')"
    fi

    if groups | grep -q docker; then
      log_info "✓ 用户在 docker 组中"
    else
      log_warn "⚠ 用户不在 docker 组"
    fi
  else
    log_warn "⚠ Docker 未安装"
  fi
}

# 生成报告
generate_report() {
  echo ""
  echo "========================================"
  echo "  OpenClaw 安装验证报告"
  echo "  时间: $(date '+%Y-%m-%d %H:%M:%S')"
  echo "========================================"
  echo ""

  local errors=0

  verify_nodejs || errors=$((errors + 1))
  verify_chrome || errors=$((errors + 1))
  verify_openclaw || errors=$((errors + 1))
  verify_config || errors=$((errors + 1))
  verify_workspaces || errors=$((errors + 1))
  verify_obsidian
  verify_docker

  echo ""
  echo "========================================"

  if [ $errors -eq 0 ]; then
    log_info "✓ 验证通过！"
  else
    log_error "✗ 发现 $errors 个错误"
  fi

  echo "========================================"
}

# 主流程
main() {
  generate_report
}

main
