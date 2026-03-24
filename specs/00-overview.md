# OpenClaw Recovery 规格总览

## 项目概述

OpenClaw Recovery 是一个一键恢复工具，用于在新虚拟机环境中快速部署 OpenClaw 及相关开发环境。

## 安装阶段清单

| 阶段 | 名称 | 说明 | 规格文档 |
|------|------|------|---------|
| 01 | 系统依赖 | 基础工具、SSH、中文输入法 | [01-system-deps.md](01-system-deps.md) |
| 02 | Node.js | NVM + Node.js v24 | [02-node.md](02-node.md) |
| 03 | Chrome | Google Chrome 浏览器 | [03-chrome.md](03-chrome.md) |
| 04 | OpenClaw | OpenClaw CLI + Serper 插件 | [04-openclaw.md](04-openclaw.md) |
| 05 | 配置恢复 | OpenClaw 配置文件恢复 | [05-config.md](05-config.md) |
| 06 | 工作空间 | Agent 工作空间初始化 | [06-workspaces.md](06-workspaces.md) |
| 07 | 安装验证 | 安装验证测试 | [07-verify.md](07-verify.md) |
| 08 | 开发工具 | Claude Code + GitHub CLI | [08-dev-tools.md](08-dev-tools.md) |
| 09 | 文件共享 | Samba 文件共享配置 | [09-file-sharing.md](09-file-sharing.md) |
| 10 | Obsidian | Obsidian AppImage | [10-obsidian.md](10-obsidian.md) |
| 11 | Python | pip, uv + 开发工具 | [11-python.md](11-python.md) |
| 12 | Golang | gvm + Go SDK | [12-golang.md](12-golang.md) |

## 核心功能

### 版本控制
- **OpenClaw 版本**: 支持原版 (`openclaw@latest`) 和社区版 (`openclaw-cn@latest`)
- **Node.js 版本**: v24.14.0 (通过 NVM 管理)
- **Go 版本**: 1.21+ (通过 gvm 管理)

### 国内优化
- **npm 镜像**: npmmirror.com
- **pip 镜像**: pypi.tuna.tsinghua.edu.cn
- **Go 模块代理**: goproxy.cn
- **Node.js 下载镜像**: npmmirror.com/mirrors/node

### 新增功能

#### 阶段 11: Python 工具
- pip 包管理器（清华镜像）
- uv 快速包管理器
- 常用开发工具：black, flake8, pytest, jupyter, ipython
- 示例虚拟环境：`~/.venv_example`

#### 阶段 12: Go 环境
- gvm 版本管理器
- Go 1.21+ SDK
- 开发工具：goimports, gopls, dlv, golangci-lint, air
- 示例项目：`~/go/src/example.com/hello`

## 使用方式

```bash
# 一键安装（所有阶段）
./scripts/install.sh --all

# 安装指定阶段
./scripts/install.sh --stage node
./scripts/install.sh --stage python
./scripts/install.sh --stage golang

# 指定 OpenClaw 版本
./scripts/install.sh --all --version cn       # 社区版
./scripts/install.sh --all --version original # 原版

# 环境检测
./scripts/install.sh --check
```

## 配置文件

| 文件 | 说明 |
|------|------|
| `config/secrets.env` | 敏感信息（API Key 等）|
| `config/openclaw.json.template` | OpenClaw 配置模板 |
| `scripts/lib/common.sh` | 公共函数和配置 |

## 敏感信息配置

在运行前需要配置 `config/secrets.env`：

```bash
# OpenClaw API Keys
SILICONFLOW_API_KEY=your_key
BAIDU_QIANFAN_API_KEY=your_key

# Feishu (可选)
FEISHU_APP_ID=your_id
FEISHU_APP_SECRET=your_secret

# Gateway Token
GATEWAY_TOKEN=your_token

# Serper API Key (搜索插件)
SERPER_API_KEY=your_key
```

## 系统要求

- **操作系统**: Ubuntu 22.04 / 24.04
- **架构**: x86_64 (amd64) 或 aarch64 (arm64)
- **磁盘空间**: 至少 10GB
- **内存**: 至少 4GB (推荐 8GB)
- **权限**: sudo 权限

## 目录结构

```
openclaw-recovery/
├── config/
│   ├── secrets.env.example    # 敏感信息模板
│   └── openclaw.json.template # OpenClaw 配置模板
├── scripts/
│   ├── install.sh             # 主安装脚本
│   ├── lib/
│   │   └── common.sh          # 公共函数
│   └── stages/
│       ├── 01-system.sh       # 系统依赖
│       ├── 02-node.sh         # Node.js
│       ├── 03-chrome.sh       # Chrome
│       ├── 04-openclaw.sh     # OpenClaw
│       ├── 05-config.sh       # 配置恢复
│       ├── 06-workspaces.sh   # 工作空间
│       ├── 07-verify.sh       # 安装验证
│       ├── 08-dev-tools.sh    # 开发工具
│       ├── 09-file-sharing.sh # 文件共享
│       ├── 10-obsidian.sh     # Obsidian
│       ├── 11-python.sh       # Python
│       └── 12-golang.sh       # Golang
└── specs/
    ├── 00-overview.md         # 总览
    ├── 01-system-deps.md      # 系统依赖规格
    ├── 02-node.md             # Node.js 规格
    ├── 03-chrome.md           # Chrome 规格
    ├── 04-openclaw.md         # OpenClaw 规格
    ├── 05-config.md           # 配置恢复规格
    ├── 06-workspaces.md       # 工作空间规格
    ├── 07-verify.md           # 验证规格
    ├── 08-dev-tools.md        # 开发工具规格
    ├── 09-file-sharing.md     # 文件共享规格
    ├── 10-obsidian.md         # Obsidian 规格
    ├── 11-python.md           # Python 规格
    └── 12-golang.md           # Golang 规格
```

## 相关链接

- **OpenClaw 官方文档**: https://docs.openclaw.ai
- **OpenClaw 中文社区**: https://clawd.org.cn
- **GitHub 仓库**: https://github.com/JunJunHub/openclaw-recovery
