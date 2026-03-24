#!/bin/bash
# OpenClaw 一键恢复脚本
# 用法: ./install.sh [--all | --stage <stage>] [--version <cn|original>] [--interactive]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# 默认配置
INTERACTIVE=false
STAGE=""
VERSION="cn"

# 解析参数
while [[ $# -gt 0 ]]; do
  case $1 in
    --all)
      STAGE="all"
      shift
      ;;
    --stage)
      STAGE="$2"
      shift 2
      ;;
    --version)
      VERSION="$2"
      shift 2
      ;;
    --interactive)
      INTERACTIVE=true
      shift
      ;;
    -h|--help)
      echo "用法: $0 [--all | --stage <stage>] [--version <cn|original>] [--interactive]"
      echo ""
      echo "选项:"
      echo "  --all              执行所有阶段"
      echo "  --stage <name>     执行指定阶段"
      echo "  --version <type>   选择 OpenClaw 版本:"
      echo "                       cn       - 社区版 (openclaw-cn, 默认)"
      echo "                       original - 原版 (openclaw)"
      echo "  --interactive      交互式输入敏感信息"
      echo ""
      echo "可用阶段:"
      echo "  system    - 系统依赖安装"
      echo "  node      - Node.js 安装"
      echo "  chrome    - Chrome 浏览器安装"
      echo "  openclaw  - OpenClaw 安装"
      echo "  config    - 配置恢复"
      echo "  workspaces- Workspace 恢复"
      echo "  verify    - 验证测试"
      echo "  dev-tools - 编程工具 (Claude Code, GitHub CLI)"
      echo "  file-sharing - 文件共享配置 (Samba, CIFS)"
      exit 0
      ;;
    *)
      log_error "未知参数: $1"
      exit 1
      ;;
  esac
done

# 加载公共函数
source "$SCRIPT_DIR/lib/common.sh"

# 设置 OpenClaw 版本
set_openclaw_version "$VERSION"

# 阶段执行函数
run_stage() {
  local stage_name="$1"
  local stage_script="$SCRIPT_DIR/stages/${stage_name}.sh"

  if [ ! -f "$stage_script" ]; then
    log_error "阶段脚本不存在: $stage_script"
    return 1
  fi

  log_info "执行阶段: $stage_name"
  source "$stage_script"
}

# 主流程
main() {
  echo "========================================"
  echo "  OpenClaw 一键恢复脚本"
  echo "  版本: 0.2.0"
  echo "========================================"
  echo ""
  echo "⚠️  警告：此脚本仅供新虚拟机环境使用！"
  echo ""
  echo "在已配置好的环境中运行可能："
  echo "  - 覆盖现有配置"
  echo "  - 破坏系统环境"
  echo ""
  read -p "确认这是新虚拟机环境？(yes/no): " confirm
  if [[ "$confirm" != "yes" ]]; then
    echo "已取消安装"
    exit 1
  fi
  echo ""

  # 检查系统
  check_system

  # 显示选择的版本
  log_info "OpenClaw 版本: $OPENCLAW_PACKAGE"

  if [ "$STAGE" = "all" ]; then
    # 执行所有阶段
    run_stage "01-system" || exit 1
    run_stage "02-node" || exit 1
    run_stage "03-chrome" || exit 1
    run_stage "04-openclaw" || exit 1
    run_stage "05-config" || exit 1
    run_stage "06-workspaces" || exit 1
    run_stage "07-verify" || exit 1
    run_stage "08-dev-tools" || exit 1
    run_stage "09-file-sharing" || exit 1
  elif [ -n "$STAGE" ]; then
    # 执行指定阶段
    case "$STAGE" in
      system) run_stage "01-system" || exit 1 ;;
      node) run_stage "02-node" || exit 1 ;;
      chrome) run_stage "03-chrome" || exit 1 ;;
      openclaw) run_stage "04-openclaw" || exit 1 ;;
      config) run_stage "05-config" || exit 1 ;;
      workspaces) run_stage "06-workspaces" || exit 1 ;;
      verify) run_stage "07-verify" || exit 1 ;;
      dev-tools) run_stage "08-dev-tools" || exit 1 ;;
      file-sharing) run_stage "09-file-sharing" || exit 1 ;;
      *)
        log_error "未知阶段: $STAGE"
        exit 1
        ;;
    esac
  else
    log_error "请指定 --all 或 --stage <name>"
    exit 1
  fi

  echo ""
  echo "========================================"
  log_info "安装完成！"
  log_info "已安装版本: $OPENCLAW_PACKAGE"
  echo "========================================"
}

main "$@"
