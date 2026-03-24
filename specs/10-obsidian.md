# Obsidian 安装规格

## 概述

安装 Obsidian AppImage 客户端，支持自动架构检测和正确版本选择。

## 安装方式

- **方式**: AppImage (无需安装，直接运行)
- **来源**: GitHub Releases
- **路径**: `~/Applications/Obsidian.AppImage`

## 架构支持

| 系统架构 | 选择版本 | 文件名格式 |
|---------|---------|-----------|
| x86_64 / amd64 | 标准 x86_64 版本 | `Obsidian-{version}.AppImage` |
| aarch64 / arm64 | ARM64 版本 | `Obsidian-{version}-arm64.AppImage` |

> ⚠️ **重要**: 脚本会自动检测系统架构并选择正确的 AppImage 文件。错误选择架构会导致 "Exec format error"。

## 版本选择逻辑

```bash
# 检测系统架构
system_arch=$(uname -m)

# x86_64 系统：选择无架构后缀的 AppImage
if [[ "$system_arch" == "x86_64" ]]; then
  # 选择不包含 arm64/aarch64 的 AppImage
  selected=$(echo "$asset_list" | awk '/\.AppImage$/ && !/arm64|aarch64/')
fi

# ARM64 系统：选择包含 arm64 的 AppImage
if [[ "$system_arch" == "aarch64" || "$system_arch" == "arm64" ]]; then
  selected=$(echo "$asset_list" | awk '/arm64|aarch64/')
fi
```

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

# 验证架构
file ~/Applications/Obsidian.AppImage
# 应显示: ELF 64-bit LSB executable, x86-64

# 检查版本
~/Applications/Obsidian.AppImage --version
```

## 常见问题

### Exec format error
**原因**: 下载了错误架构的 AppImage（如 ARM64 版本在 x86_64 系统上）

**解决方案**:
```bash
# 删除错误文件
rm -f ~/Applications/Obsidian.AppImage

# 重新运行安装阶段
./scripts/install.sh --stage obsidian

# 或手动下载正确版本
wget -O ~/Applications/Obsidian.AppImage \
  "https://github.com/obsidianmd/obsidian-releases/releases/latest/download/Obsidian-1.12.7.AppImage"
chmod +x ~/Applications/Obsidian.AppImage
```

### 下载失败
**解决方案**: 检查网络连接，或使用代理下载。

## 知识库集成

默认知识库位置：`~/.openclaw/obsidian/`

可配置 OpenClaw 自动同步到该知识库。

## 下载信息

- **API 端点**: `https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest`
- **最新版本**: v1.12.7
- **可用文件**:
  - `Obsidian-1.12.7.AppImage` (x86_64)
  - `Obsidian-1.12.7-arm64.AppImage` (ARM64)
