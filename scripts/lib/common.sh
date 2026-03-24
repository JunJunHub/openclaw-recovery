#!/bin/bash
# 公共函数库

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日志函数
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# OpenClaw 版本配置
OPENCLAW_CN_VERSION="openclaw-cn@0.1.8-fix.3"
OPENCLAW_ORIGINAL_VERSION="openclaw@latest"

# 当前选择的版本（默认社区版）
OPENCLAW_PACKAGE="$OPENCLAW_CN_VERSION"

# 设置 OpenClaw 版本
set_openclaw_version() {
  local version="$1"
  case "$version" in
    cn|community|社区版)
      OPENCLAW_PACKAGE="$OPENCLAW_CN_VERSION"
      log_info "选择社区版: $OPENCLAW_PACKAGE"
      ;;
    original|official|原版)
      OPENCLAW_PACKAGE="$OPENCLAW_ORIGINAL_VERSION"
      log_info "选择原版: $OPENCLAW_PACKAGE"
      ;;
    *)
      log_warn "未知版本 '$version'，使用默认社区版"
      OPENCLAW_PACKAGE="$OPENCLAW_CN_VERSION"
      ;;
  esac
}

# 检查系统
check_system() {
  if [ ! -f /etc/os-release ]; then
    log_error "无法检测系统版本"
    exit 1
  fi

  source /etc/os-release

  if [[ "$ID" != "ubuntu" ]]; then
    log_warn "此脚本主要针对 Ubuntu，当前系统: $ID"
  fi

  log_info "检测到系统: $PRETTY_NAME"
}

# 检查命令是否存在
command_exists() {
  command -v "$1" &> /dev/null
}

# 检查文件是否存在
file_exists() {
  [ -f "$1" ]
}

# 检查目录是否存在
dir_exists() {
  [ -d "$1" ]
}

# 确认操作
confirm() {
  local prompt="$1"
  local default="${2:-n}"

  read -p "$prompt (y/N): " -n 1 -r
  echo

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    return 0
  fi
  return 1
}

# 检查是否为 root 用户
is_root() {
  [ "$EUID" -eq 0 ]
}

# 需要 sudo 时提示
require_sudo() {
  if ! is_root; then
    log_info "需要 sudo 权限执行以下命令"
    sudo -v
  fi
}

# 添加到 PATH
add_to_path() {
  local path_to_add="$1"
  local shell_rc="${HOME}/.bashrc"

  if ! grep -q "$path_to_add" "$shell_rc" 2>/dev/null; then
    echo "export PATH=\"$path_to_add:\$PATH\"" >> "$shell_rc"
    log_info "已添加到 PATH: $path_to_add"
  fi
}

# 下载文件（带重试）
download_file() {
  local url="$1"
  local output="$2"
  local max_retries=3
  local retry=0

  while [ $retry -lt $max_retries ]; do
    if wget -q --show-progress -O "$output" "$url"; then
      return 0
    fi

    retry=$((retry + 1))
    log_warn "下载失败，重试 ($retry/$max_retries)..."
    sleep 2
  done

  log_error "下载失败: $url"
  return 1
}

# 安装 apt 包
install_apt_packages() {
  local packages=("$@")

  log_info "安装包: ${packages[*]}"
  sudo apt-get update -qq
  sudo apt-get install -y "${packages[@]}"
}

# 敏感信息交互式输入
prompt_secrets() {
  log_info "请输入敏感信息（留空跳过）:"

  read -p "SiliconFlow API Key: " SILICONFLOW_API_KEY
  export SILICONFLOW_API_KEY

  read -p "百度千帆 API Key: " BAIDU_QIANFAN_API_KEY
  export BAIDU_QIANFAN_API_KEY

  read -p "飞书 App ID: " FEISHU_APP_ID
  export FEISHU_APP_ID

  read -p "飞书 App Secret: " FEISHU_APP_SECRET
  export FEISHU_APP_SECRET

  read -p "Gateway Token (留空自动生成): " GATEWAY_TOKEN
  if [ -z "$GATEWAY_TOKEN" ]; then
    GATEWAY_TOKEN=$(openssl rand -hex 24)
    log_info "已自动生成 Gateway Token"
  fi
  export GATEWAY_TOKEN
}

# 加载 secrets.env
load_secrets() {
  local secrets_file="$PROJECT_DIR/config/secrets.env"

  if [ -f "$secrets_file" ]; then
    log_info "加载配置: $secrets_file"
    set -a
    source "$secrets_file"
    set +a
  fi
}

# 替换配置文件中的占位符
inject_secrets() {
  local template="$1"
  local output="$2"

  if [ ! -f "$template" ]; then
    log_error "模板文件不存在: $template"
    return 1
  fi

  cp "$template" "$output"

  # 替换占位符
  sed -i "s|{{SILICONFLOW_API_KEY}}|${SILICONFLOW_API_KEY}|g" "$output"
  sed -i "s|{{BAIDU_QIANFAN_API_KEY}}|${BAIDU_QIANFAN_API_KEY}|g" "$output"
  sed -i "s|{{FEISHU_APP_ID}}|${FEISHU_APP_ID}|g" "$output"
  sed -i "s|{{FEISHU_APP_SECRET}}|${FEISHU_APP_SECRET}|g" "$output"
  sed -i "s|{{GATEWAY_TOKEN}}|${GATEWAY_TOKEN}|g" "$output"
  sed -i "s|{{HOME}}|${HOME}|g" "$output"

  # 设置权限
  chmod 600 "$output"

  log_info "配置文件已生成: $output"
}
