#!/bin/bash
# 阶段 9: 配置恢复

log_info "=== 阶段 9: 配置恢复 ==="

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

# 显示配置差异并确认
show_diff_and_confirm() {
  if [ ! -f "$CONFIG_FILE" ]; then
    log_info "无现有配置文件，将创建新文件"
    return 0
  fi

  # 创建临时文件用于比较
  local temp_file=$(mktemp)
  inject_secrets_silent "$CONFIG_TEMPLATE" "$temp_file"

  # 显示差异
  show_config_diff "$CONFIG_FILE" "$temp_file" "openclaw.json"

  # 确认覆盖
  confirm_overwrite "$CONFIG_FILE"

  local result=$?
  rm -f "$temp_file"

  return $result
}

# 静默注入（不打印日志）
inject_secrets_silent() {
  local template="$1"
  local output="$2"

  if [ ! -f "$template" ]; then
    return 1
  fi

  cp "$template" "$output"

  # 替换占位符
  sed -i "s|{{SILICONFLOW_API_KEY}}|${SILICONFLOW_API_KEY}|g" "$output"
  sed -i "s|{{BAIDU_QIANFAN_API_KEY}}|${BAIDU_QIANFAN_API_KEY}|g" "$output"
  sed -i "s|{{TAVILY_API_KEY}}|${TAVILY_API_KEY}|g" "$output"
  sed -i "s|{{EXA_API_KEY}}|${EXA_API_KEY}|g" "$output"
  sed -i "s|{{FEISHU_APP_ID}}|${FEISHU_APP_ID}|g" "$output"
  sed -i "s|{{FEISHU_APP_SECRET}}|${FEISHU_APP_SECRET}|g" "$output"
  sed -i "s|{{GATEWAY_TOKEN}}|${GATEWAY_TOKEN}|g" "$output"
  sed -i "s|{{HOME}}|${HOME}|g" "$output"

  # 设置权限
  chmod 600 "$output"
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

  # 显示差异并确认
  show_diff_and_confirm || return 1

  backup_config
  restore_config

  log_info "配置恢复完成"
}

main
