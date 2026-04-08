#!/bin/bash
# 阶段 10: Workspace 恢复

log_info "=== 阶段 10: Workspace 恢复 ==="

OPENCLAW_DIR="$HOME/.openclaw"
WORKSPACES=("workspace" "workspace-thinker" "workspace-media" "workspace-monitor" "workspace-coder")
OBSIDIAN_DIR="$OPENCLAW_DIR/obsidian"

# 创建 Workspace 目录
create_workspaces() {
  log_step "创建 Workspace 目录..."

  for ws in "${WORKSPACES[@]}"; do
    local ws_path="$OPENCLAW_DIR/$ws"

    if [ -d "$ws_path" ]; then
      log_info "$ws 已存在"
    else
      mkdir -p "$ws_path/memory"
      log_info "创建 $ws"
    fi
  done
}

# 创建默认文件
create_default_files() {
  log_step "创建默认文件..."

  for ws in "${WORKSPACES[@]}"; do
    local ws_path="$OPENCLAW_DIR/$ws"

    # AGENTS.md
    if [ ! -f "$ws_path/AGENTS.md" ]; then
      cat > "$ws_path/AGENTS.md" << 'EOF'
# AGENTS.md - Your Workspace

This folder is home. Treat it that way.
EOF
    fi

    # SOUL.md
    if [ ! -f "$ws_path/SOUL.md" ]; then
      cat > "$ws_path/SOUL.md" << 'EOF'
# SOUL.md - Who You Are

*You're not a chatbot. You're becoming someone.*
EOF
    fi

    # USER.md
    if [ ! -f "$ws_path/USER.md" ]; then
      cat > "$ws_path/USER.md" << 'EOF'
# USER.md - About Your Human

*Learn about the person you're helping.*
EOF
    fi

    # MEMORY.md
    if [ ! -f "$ws_path/MEMORY.md" ]; then
      touch "$ws_path/MEMORY.md"
    fi
  done

  log_info "默认文件创建完成"
}

# 恢复 Obsidian 知识库
restore_obsidian() {
  log_step "恢复 Obsidian 知识库..."

  if [ -d "$OBSIDIAN_DIR" ]; then
    log_info "Obsidian 知识库已存在"
    return 0
  fi

  # 从 GitHub 克隆
  local obsidian_repo="https://github.com/JunJunHub/openclaw-knowledge-base.git"

  read -p "是否从 GitHub 克隆知识库？(y/N): " -n 1 -r
  echo

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    git clone "$obsidian_repo" "$OBSIDIAN_DIR"
    log_info "知识库克隆完成"
  else
    mkdir -p "$OBSIDIAN_DIR"
    log_info "已创建空知识库目录"
  fi
}

# 主流程
main() {
  create_workspaces
  create_default_files
  restore_obsidian

  log_info "Workspace 恢复完成"
}

main
