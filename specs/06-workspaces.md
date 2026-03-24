# Workspace 恢复规格

## 概述

恢复 5 个 Agent 工作空间及 Obsidian 知识库。

## Agent Workspace 配置

### 默认 Workspace 结构

每个 workspace 包含：

```
workspace-xxx/
├── AGENTS.md        # Agent 行为规则
├── SOUL.md          # 人格定义
├── USER.md          # 用户信息
├── MEMORY.md        # 长期记忆
├── HEARTBEAT.md     # 心跳任务
└── memory/          # 日志目录
```

### 恢复脚本

```bash
#!/bin/bash

WORKSPACES=("workspace" "workspace-thinker" "workspace-media" "workspace-monitor" "workspace-coder")

restore_workspaces() {
  for ws in "${WORKSPACES[@]}"; do
    local ws_path="$HOME/.openclaw/$ws"
    mkdir -p "$ws_path/memory"
    echo "✓ $ws 已恢复"
  done
}
```

## Obsidian 知识库恢复

### 恢复方式

#### 方式1: Git 克隆

```bash
git clone https://github.com/JunJunHub/openclaw-knowledge-base.git ~/.openclaw/obsidian
```

#### 方式2: 本地备份恢复

```bash
tar -xzf backup/obsidian.tar.gz -C ~/.openclaw/
```

## 验证清单

| 检查项 | 命令 | 期望结果 |
|--------|------|----------|
| Workspace 存在 | `ls ~/.openclaw/workspace*/AGENTS.md` | 5 个文件 |
| Obsidian 存在 | `ls ~/.openclaw/obsidian/` | 目录列表 |
