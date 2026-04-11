#!/bin/bash
# OpenClaw 一键恢复脚本
# 用法: ./install.sh [--all | --stage <stage>] [--version <cn|original>] [--interactive] [--check]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# 脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# 默认配置
INTERACTIVE=false
STAGE=""
VERSION="original"
DRY_RUN=false

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
    --check|--dry-run)
      DRY_RUN=true
      shift
      ;;
    -h|--help)
      echo "用法: $0 [--all | --stage <stage>] [--version <cn|original>] [--interactive] [--check]"
      echo ""
      echo "选项:"
      echo "  --all              执行所有阶段"
      echo "  --stage <name>     执行指定阶段"
      echo "  --version <type>   选择 OpenClaw 版本:"
      echo "                       cn       - 社区版 (openclaw-cn)"
      echo "                       original - 原版 (openclaw, 默认)"
      echo "  --interactive      交互式输入敏感信息"
      echo "  --check            仅检测环境，不执行安装"
      echo ""
      echo "可用阶段:"
      echo "  【基础环境】"
      echo "  system       - 系统依赖安装"
      echo "  github-hosts - GitHub hosts 配置"
      echo "  docker       - Docker 容器环境"
      echo "  node         - Node.js 安装"
      echo "  python       - Python 工具"
      echo "  golang       - Go 环境"
      echo ""
      echo "  【OpenClaw】"
      echo "  chrome       - Chrome 浏览器"
      echo "  openclaw     - OpenClaw 安装"
      echo "  config       - 配置恢复"
      echo "  workspaces   - Workspace 恢复"
      echo ""
      echo "  【开发工具】"
      echo "  dev-tools    - Claude Code CLI, Codex CLI, GitHub CLI, CC Switch"
      echo ""
      echo "  【应用】"
      echo "  file-sharing - 文件共享 (Samba)"
      echo "  obsidian     - Obsidian AppImage"
      echo "  n8n          - N8N 工作流平台"
      echo "  qt           - Qt 开发环境 (耗时较长)"
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

# 显示将要执行的操作
show_execution_plan() {
  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "                    📋 执行计划"
  echo "═══════════════════════════════════════════════════════════════"
  echo ""

  if [ "$STAGE" = "all" ]; then
    echo "【将执行的阶段】"
    echo "  【基础环境层】"
    echo "  1. system       - 安装系统依赖 (curl, wget, git, vim, htop, tmux, SSH)"
    echo "  2. github-hosts - 配置 GitHub hosts (解决访问不稳定)"
    echo "  3. docker       - 安装 Docker 容器环境"
    echo "  4. node         - 安装 NVM + Node.js v24"
    echo "  5. python       - 安装 Python 工具 (pip, uv)"
    echo "  6. golang       - 安装 Go 环境 (gvm, Go SDK)"
    echo ""
    echo "  【OpenClaw 层】"
    echo "  7. chrome       - 安装 Google Chrome (MCP 依赖)"
    echo "  8. openclaw     - 安装 OpenClaw ($OPENCLAW_PACKAGE)"
    echo "  9. config       - 恢复配置文件 (⚠️ 可能覆盖现有配置)"
    echo "  10. workspaces  - 创建工作空间目录"
    echo ""
    echo "  【开发工具层】"
    echo "  11. dev-tools   - 安装 Claude Code CLI + Codex CLI + GitHub CLI + CC Switch"
    echo ""
    echo "  【应用层】"
    echo "  12. file-sharing - 配置 Samba 文件共享 (⚠️ 修改 smb.conf)"
    echo "  13. obsidian    - 安装 Obsidian AppImage"
    echo "  14. n8n         - 安装 N8N 工作流自动化平台"
    echo ""
    echo "  【耗时任务】"
    echo "  15. qt          - 安装 Qt 6.8 LTS 开发环境 (10-30 分钟)"
    echo ""
    echo "  【验证层】"
    echo "  16. verify      - 全量验证安装结果"
  else
    echo "【将执行的阶段】"
    echo "  $STAGE"
  fi

  echo ""
  echo "【潜在风险】"
  echo "  ⚠️  阶段 config (9): 会覆盖 ~/.openclaw/openclaw.json (有备份)"
  echo "  ⚠️  阶段 file-sharing (12): 会修改 /etc/samba/smb.conf (有备份)"
  echo "  ⚠️  阶段 qt (15): 安装耗时 10-30 分钟"
  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
}

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
  echo "  版本: 0.3.0"
  echo "========================================"
  echo ""

  # 检测模式
  if [ "$DRY_RUN" = true ]; then
    check_environment
    log_info "检测模式完成，未执行任何安装"
    exit 0
  fi

  # 显示执行计划
  show_execution_plan

  # 强化警告
  echo "⚠️  警告：此脚本会修改系统配置！"
  echo ""
  echo "在已配置好的环境中运行可能："
  echo "  • 覆盖 OpenClaw 配置文件 (有备份)"
  echo "  • 修改 Samba 配置 (有备份)"
  echo "  • 安装/更新系统软件包"
  echo ""
  echo "推荐使用场景："
  echo "  ✅ 新虚拟机环境"
  echo "  ✅ 系统重装后的恢复"
  echo ""
  echo "不推荐场景："
  echo "  ❌ 已配置好的生产环境"
  echo "  ❌ 不确定当前环境状态"
  echo ""
  read -p "确认继续执行？请输入 'yes' 继续: " confirm
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
    run_stage "02-github-hosts" || exit 1
    run_stage "03-docker" || exit 1
    run_stage "04-node" || exit 1
    run_stage "05-python" || exit 1
    run_stage "06-golang" || exit 1
    run_stage "07-chrome" || exit 1
    run_stage "08-openclaw" || exit 1
    run_stage "09-config" || exit 1
    run_stage "10-workspaces" || exit 1
    run_stage "11-dev-tools" || exit 1
    run_stage "12-file-sharing" || exit 1
    run_stage "13-obsidian" || exit 1
    run_stage "14-n8n" || exit 1
    run_stage "15-qt" || exit 1
    run_stage "16-verify" || exit 1
  elif [ -n "$STAGE" ]; then
    # 执行指定阶段
    case "$STAGE" in
      system) run_stage "01-system" || exit 1 ;;
      github-hosts) run_stage "02-github-hosts" || exit 1 ;;
      docker) run_stage "03-docker" || exit 1 ;;
      node) run_stage "04-node" || exit 1 ;;
      python) run_stage "05-python" || exit 1 ;;
      golang) run_stage "06-golang" || exit 1 ;;
      chrome) run_stage "07-chrome" || exit 1 ;;
      openclaw) run_stage "08-openclaw" || exit 1 ;;
      config) run_stage "09-config" || exit 1 ;;
      workspaces) run_stage "10-workspaces" || exit 1 ;;
      dev-tools) run_stage "11-dev-tools" || exit 1 ;;
      file-sharing) run_stage "12-file-sharing" || exit 1 ;;
      obsidian) run_stage "13-obsidian" || exit 1 ;;
      n8n) run_stage "14-n8n" || exit 1 ;;
      qt) run_stage "15-qt" || exit 1 ;;
      verify) run_stage "16-verify" || exit 1 ;;
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
