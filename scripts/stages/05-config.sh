#!/bin/bash
# 阶段 5: 配置恢复

log_info "=== 阶段 5: 配置恢复 ==="

OPENCLAW_DIR="$HOME/.openclaw"
CONFIG_FILE="$OPENCLAW_DIR/openclaw.json"
CONFIG_TEMPLATE="$PROJECT_DIR/config/openclaw.json.template"

# 加载敏感信息
load_secrets_interactive() {
  if [ "$INTERACTIVE" = true ]; then
    prompt_secrets
  else
    load_secrets
  fi
}

# 验证敏感信息
validate_secrets() {
  log_step "验证敏感信息..."

  local missing=()

  [ -z "$SILICONFLOW_API_KEY" ] && missing+=("SILICONFLOW_API_KEY")
  [ -z "$BAIDU_QIANFAN_API_KEY" ] && missing+=("BAIDU_QIANFAN_API_KEY")
  [ -z "$GATEWAY_TOKEN" ] && missing+=("GATEWAY_TOKEN")

  if [ ${#missing[@]} -gt 0 ]; then
    log_error "缺少以下敏感信息:"
    for key in "${missing[@]}"; do
      echo "  - $key"
    done
    echo ""
    echo "请通过以下方式提供:"
    echo "  1. 创建 config/secrets.env 文件"
    echo "  2. 或使用 --interactive 参数交互式输入"
    return 1
  fi

  log_info "敏感信息验证通过"
}

# 备份现有配置
backup_config() {
  if [ -f "$CONFIG_FILE" ]; then
    local backup_file="${CONFIG_FILE}.bak.$(date +%Y%m%d%H%M%S)"
    cp "$CONFIG_FILE" "$backup_file"
    log_info "已备份配置: $backup_file"
  fi
}

# 恢复配置文件
restore_config() {
  log_step "恢复配置文件..."

  if [ ! -f "$CONFIG_TEMPLATE" ]; then
    log_error "配置模板不存在: $CONFIG_TEMPLATE"
    return 1
  fi

  inject_secrets "$CONFIG_TEMPLATE" "$CONFIG_FILE"

  log_info "配置文件已恢复"
}

# 主流程
main() {
  load_secrets_interactive
  validate_secrets || return 1
  backup_config
  restore_config

  log_info "配置恢复完成"
}

main
