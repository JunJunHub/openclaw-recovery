# OpenClaw 安装规格

## 📋 目标

安装 OpenClaw，支持选择社区版或原版，并配置 Serper 搜索插件。

## 🔧 版本选择

| 参数 | 包名 | 说明 |
|------|------|------|
| `original` (默认) | openclaw@latest | 原版，功能最新 |
| `cn` | openclaw-cn@latest | 社区版，内置飞书/钉钉/企微 |

> ⚠️ **注意**: 默认版本已改为原版 `openclaw@latest`，以获取最新功能支持。

## 🔧 安装脚本

```bash
# 版本配置（在 common.sh 中定义）
OPENCLAW_CN_VERSION="openclaw-cn@latest"
OPENCLAW_ORIGINAL_VERSION="openclaw@latest"

# 当前选择的版本（默认原版）
OPENCLAW_PACKAGE="$OPENCLAW_ORIGINAL_VERSION"

install_openclaw() {
    # 使用全局变量 OPENCLAW_PACKAGE（由 --version 参数设置）

    # 检查是否已安装
    if command -v openclaw &> /dev/null; then
        log_info "OpenClaw 已安装，询问是否重新安装"
        # ... 交互式确认
    fi

    # 使用淘宝镜像
    npm config set registry https://registry.npmmirror.com

    # 安装选定的版本
    npm install -g "$OPENCLAW_PACKAGE"

    log_success "OpenClaw 安装完成: $(openclaw --version)"
}

init_openclaw_dirs() {
    mkdir -p ~/.openclaw/{agents,browser,cron,credentials,extensions,identity,logs,media,memory,obsidian}
    log_success "目录结构初始化完成"
}
```

## 🔍 Serper 搜索插件

### 功能说明
Serper 插件提供 Google 搜索功能：
- 网页搜索
- 学术论文搜索
- 新闻搜索
- 地点搜索

### 获取 API Key
1. 访问 https://serper.dev
2. 注册账号（免费 2500 次/月）
3. 获取 API Key

### 配置方式

**方式一：通过 secrets.env 配置**
```bash
# config/secrets.env
SERPER_API_KEY=your_api_key_here
```

**方式二：直接配置到 openclaw.json**
```json
{
  "plugins": {
    "serper": {
      "enabled": true,
      "apiKey": "your_api_key_here"
    }
  }
}
```

### 使用工具
安装后会自动启用以下工具：
- `serper_search` - 网页搜索
- `serper_scholar` - 学术搜索

## ✅ 验证

```bash
verify_openclaw() {
    command -v openclaw &> /dev/null || { log_error "OpenClaw 未安装"; return 1; }
    openclaw --version
    openclaw doctor
}
```

## 📦 目录结构

```
~/.openclaw/
├── agents/           # Agent 配置
├── browser/          # 浏览器数据
├── cron/             # 定时任务
├── credentials/      # 凭证存储
├── extensions/       # 插件目录
├── identity/         # 身份信息
├── logs/             # 日志文件
├── media/            # 媒体文件
├── memory/           # 记忆存储
├── obsidian/         # 知识库
└── openclaw.json     # 配置文件
```

## 🔄 版本切换

```bash
# 安装原版（默认）
./scripts/install.sh --all

# 安装社区版
./scripts/install.sh --all --version cn

# 指定版本
./scripts/install.sh --all --version original
```
