# Obsidian 安装规格

## 概述

安装 Obsidian AppImage 客户端。

## 安装方式

- **方式**: AppImage (无需安装，直接运行)
- **来源**: GitHub Releases
- **路径**: `~/Applications/Obsidian.AppImage`

## 自动创建

| 项目 | 路径 |
|------|------|
| AppImage | `~/Applications/Obsidian.AppImage` |
| 桌面快捷方式 | `~/.local/share/applications/obsidian.desktop` |
| 启动脚本 | `~/.local/bin/obsidian` |

## 启动方式

```bash
# 方式 1: 命令行
obsidian

# 方式 2: 直接运行
~/Applications/Obsidian.AppImage

# 方式 3: 应用菜单
# 搜索 "Obsidian"
```

## 验证

```bash
# 检查 AppImage
ls -la ~/Applications/Obsidian.AppImage

# 检查版本
~/Applications/Obsidian.AppImage --version
```

## 知识库集成

默认知识库位置：`~/.openclaw/obsidian/`

可配置 OpenClaw 自动同步到该知识库。
