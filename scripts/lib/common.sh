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
OPENCLAW_CN_VERSION="openclaw-cn@latest"
OPENCLAW_ORIGINAL_VERSION="openclaw@latest"

# 当前选择的版本（默认原版）
OPENCLAW_PACKAGE="$OPENCLAW_ORIGINAL_VERSION"

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
      log_warn "未知版本 '$version'，使用默认原版"
      OPENCLAW_PACKAGE="$OPENCLAW_ORIGINAL_VERSION"
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

# 检查服务是否运行
service_running() {
  systemctl is-active --quiet "$1" 2>/dev/null
}

# 环境检测
check_environment() {
  log_step "环境检测..."

  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "                    📊 当前环境状态"
  echo "═══════════════════════════════════════════════════════════════"
  echo ""

  # 系统工具
  echo "【系统工具】"
  local tools=("curl" "wget" "git" "vim" "jq" "htop" "tmux" "tree" "sqlite3" "node" "npm")
  for tool in "${tools[@]}"; do
    if command_exists "$tool"; then
      local version=""
      case "$tool" in
        node) version=" ($(node --version 2>/dev/null))" ;;
        npm) version=" ($(npm --version 2>/dev/null))" ;;
        *) version="" ;;
      esac
      echo "  ✅ $tool 已安装$version"
    else
      echo "  ❌ $tool 未安装"
    fi
  done
  echo ""

  # 中文输入法
  echo "【中文输入法】"
  if command_exists "ibus"; then
    echo "  ✅ ibus 输入法框架已安装"
  else
    echo "  ❌ ibus 输入法框架未安装"
  fi
  
  if dpkg -l | grep -q "ibus-pinyin" 2>/dev/null; then
    echo "  ✅ ibus-pinyin 拼音输入法已安装"
  else
    echo "  ❌ ibus-pinyin 拼音输入法未安装"
  fi
  
  # 检查环境变量
  if [ -n "$GTK_IM_MODULE" ] && [ "$GTK_IM_MODULE" = "ibus" ]; then
    echo "  ✅ GTK_IM_MODULE=ibus (已配置)"
  else
    echo "  ⚠️  GTK_IM_MODULE 未配置为 ibus"
  fi
  
  if [ -n "$QT_IM_MODULE" ] && [ "$QT_IM_MODULE" = "ibus" ]; then
    echo "  ✅ QT_IM_MODULE=ibus (已配置)"
  else
    echo "  ⚠️  QT_IM_MODULE 未配置为 ibus"
  fi
  echo ""

  # SSH 服务
  echo "【网络服务】"
  if service_running "ssh"; then
    echo "  ✅ SSH 服务运行中"
  elif command_exists "sshd"; then
    echo "  ⚠️  SSH 已安装但未运行"
  else
    echo "  ❌ SSH 未安装"
  fi
  echo ""

  # 浏览器
  echo "【浏览器】"
  if command_exists "google-chrome"; then
    echo "  ✅ Chrome 已安装 ($(google-chrome --version 2>/dev/null | awk '{print $3}'))"
  else
    echo "  ❌ Chrome 未安装"
  fi
  echo ""

  # OpenClaw
  echo "【OpenClaw】"
  if command_exists "openclaw" || command_exists "openclaw-cn"; then
    local oc_version=""
    if command_exists "openclaw"; then
      oc_version="$(openclaw --version 2>/dev/null || echo "unknown")"
      echo "  ✅ OpenClaw (原版): $oc_version"
    fi
    if command_exists "openclaw-cn"; then
      oc_version="$(openclaw-cn --version 2>/dev/null || echo "unknown")"
      echo "  ✅ OpenClaw-CN (社区版): $oc_version"
    fi
  else
    echo "  ❌ OpenClaw 未安装"
  fi

  # 配置文件
  if [ -f "$HOME/.openclaw/openclaw.json" ]; then
    echo "  ✅ 配置文件已存在"
  else
    echo "  ❌ 配置文件不存在"
  fi
  echo ""

  # 工作空间
  echo "【工作空间】"
  local workspaces=("workspace" "workspace-thinker" "workspace-media" "workspace-monitor" "workspace-coder")
  for ws in "${workspaces[@]}"; do
    if dir_exists "$HOME/.openclaw/$ws"; then
      echo "  ✅ $ws"
    else
      echo "  ❌ $ws 不存在"
    fi
  done
  echo ""

  # 开发工具
  echo "【开发工具】"
  if command_exists "claude"; then
    echo "  ✅ Claude Code CLI 已安装"
  else
    echo "  ❌ Claude Code CLI 未安装"
  fi
  if command_exists "gh"; then
    echo "  ✅ GitHub CLI 已安装 ($(gh --version 2>/dev/null | head -1 | awk '{print $3}'))"
  else
    echo "  ❌ GitHub CLI 未安装"
  fi
  if dpkg -l cc-switch 2>/dev/null | grep -q "^ii"; then
    echo "  ✅ CC Switch 已安装"
  else
    echo "  ❌ CC Switch 未安装"
  fi
  echo ""

  # Python 环境
  echo "【Python 环境】"
  if command_exists "python3"; then
    python_version=$(python3 --version 2>/dev/null | awk '{print $2}')
    echo "  ✅ Python3: $python_version"
  else
    echo "  ❌ Python3 未安装"
  fi
  
  if command_exists "pip3"; then
    pip_version=$(pip3 --version 2>/dev/null | awk '{print $2}')
    echo "  ✅ pip3: $pip_version"
  else
    echo "  ❌ pip3 未安装"
  fi
  
  if command_exists "uv"; then
    uv_version=$(uv --version 2>/dev/null | awk '{print $2}')
    echo "  ✅ uv: $uv_version"
  else
    echo "  ❌ uv 未安装"
  fi
  
  # 检查虚拟环境
  if [ -d "$HOME/.venv_example" ]; then
    echo "  ✅ 示例虚拟环境: ~/.venv_example"
  else
    echo "  ❌ 示例虚拟环境未创建"
  fi
  echo ""

  # Go 环境
  echo "【Go 环境】"
  if command_exists "go"; then
    go_version=$(go version 2>/dev/null | awk '{print $3}')
    echo "  ✅ Go SDK: $go_version"
  else
    echo "  ❌ Go SDK 未安装"
  fi
  
  if [ -d "$HOME/.gvm" ]; then
    echo "  ✅ gvm: 已安装"
  else
    echo "  ❌ gvm 未安装"
  fi
  
  if command_exists "gvm"; then
    echo "  ✅ gvm 命令行可用"
  else
    echo "  ❌ gvm 命令行不可用"
  fi
  
  # 检查示例项目
  if [ -d "$HOME/go/src/example.com/hello" ]; then
    echo "  ✅ 示例项目: ~/go/src/example.com/hello"
  else
    echo "  ❌ 示例项目未创建"
  fi
  echo ""

  # Qt 环境
  echo "【Qt 环境】"
  if [ -d "$HOME/Qt" ]; then
    echo "  ✅ Qt 安装目录: ~/Qt"
    # 检查已安装版本
    if ls "$HOME/Qt"/6.*/gcc_64/bin/qmake 2>/dev/null; then
      local qt_version=$(ls "$HOME/Qt" | grep "^6\." | head -1)
      echo "  ✅ Qt 版本: $qt_version"
    fi
  else
    echo "  ❌ Qt 未安装"
  fi
  
  if command_exists "qmake"; then
    echo "  ✅ qmake 命令可用"
  else
    echo "  ❌ qmake 命令不可用"
  fi
  
  if [ -f "$HOME/Qt/Tools/QtCreator/bin/qtcreator" ]; then
    echo "  ✅ Qt Creator 已安装"
  else
    echo "  ❌ Qt Creator 未安装"
  fi
  echo ""

  # Docker 环境
  echo "【Docker 环境】"
  if command_exists "docker"; then
    local docker_version=$(docker --version 2>/dev/null | awk '{print $3}' | tr -d ',')
    echo "  ✅ Docker: $docker_version"
    
    if service_running "docker"; then
      echo "  ✅ Docker 服务运行中"
    else
      echo "  ⚠️  Docker 服务未运行"
    fi
    
    if docker compose version &>/dev/null; then
      local compose_version=$(docker compose version 2>/dev/null | awk '{print $4}' | tr -d ',')
      echo "  ✅ Docker Compose: $compose_version"
    fi
    
    if groups | grep -q docker; then
      echo "  ✅ 用户在 docker 组中"
    else
      echo "  ⚠️  用户不在 docker 组，需要运行: sudo usermod -aG docker \$USER"
    fi
  else
    echo "  ❌ Docker 未安装"
  fi
  echo ""

  # N8N 环境
  echo "【N8N 工作流平台】"
  if command_exists "docker" && docker ps &>/dev/null; then
    if docker ps --format '{{.Names}}' | grep -q "^n8n$"; then
      local n8n_port=$(docker port n8n 5678 2>/dev/null | cut -d: -f1)
      echo "  ✅ N8N 容器运行中"
      echo "  ✅ 访问地址: http://localhost:${n8n_port:-5678}"
    elif docker ps -a --format '{{.Names}}' | grep -q "^n8n$"; then
      echo "  ⚠️  N8N 容器已停止"
    else
      echo "  ❌ N8N 容器未创建"
    fi
    
    if [ -d "$HOME/.n8n" ]; then
      echo "  ✅ 数据目录: ~/.n8n"
    fi
  else
    echo "  ❌ Docker 未安装或无权限"
  fi
  echo ""

  # 文件共享
  echo "【文件共享】"
  if service_running "smbd"; then
    echo "  ✅ Samba 服务运行中"
  else
    echo "  ❌ Samba 未运行"
  fi
  if [ -d "/home/Share" ]; then
    echo "  ✅ 共享目录存在: /home/Share"
  else
    echo "  ❌ 共享目录不存在"
  fi
  echo ""

  # Obsidian
  echo "【桌面应用】"
  if [ -f "$HOME/Applications/Obsidian.AppImage" ]; then
    echo "  ✅ Obsidian 已安装"
  else
    echo "  ❌ Obsidian 未安装"
  fi
  echo ""

  echo "═══════════════════════════════════════════════════════════════"
  echo ""
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

  read -p "Tavily API Key (搜索，推荐): " TAVILY_API_KEY
  export TAVILY_API_KEY

  read -p "Exa API Key (搜索，可选): " EXA_API_KEY
  export EXA_API_KEY

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
  sed -i "s|{{TAVILY_API_KEY}}|${TAVILY_API_KEY}|g" "$output"
  sed -i "s|{{EXA_API_KEY}}|${EXA_API_KEY}|g" "$output"
  sed -i "s|{{FEISHU_APP_ID}}|${FEISHU_APP_ID}|g" "$output"
  sed -i "s|{{FEISHU_APP_SECRET}}|${FEISHU_APP_SECRET}|g" "$output"
  sed -i "s|{{GATEWAY_TOKEN}}|${GATEWAY_TOKEN}|g" "$output"
  sed -i "s|{{HOME}}|${HOME}|g" "$output"

  # 设置权限
  chmod 600 "$output"

  log_info "配置文件已生成: $output"
}

# 显示配置差异
show_config_diff() {
  local old_file="$1"
  local new_file="$2"
  local file_name="$3"

  if [ ! -f "$old_file" ]; then
    log_info "无现有配置文件，将创建新文件"
    return 0
  fi

  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "                    📝 配置变更预览: $file_name"
  echo "═══════════════════════════════════════════════════════════════"
  echo ""

  # 显示差异
  if diff -u "$old_file" "$new_file" 2>/dev/null; then
    log_info "配置文件无变化"
  else
    echo ""
    echo "--- 现有配置"
    echo "+++ 新配置"
    diff -u "$old_file" "$new_file" 2>/dev/null || true
  fi

  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
}

# 确认配置覆盖
confirm_overwrite() {
  local file_name="$1"

  echo "⚠️  即将覆盖: $file_name"
  echo "   原文件将备份为: ${file_name}.bak.<时间戳>"
  echo ""

  read -p "是否继续？(y/N): " -n 1 -r
  echo

  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_warn "用户取消操作"
    return 1
  fi

  return 0
}
