# OpenClaw Recovery 规格总览

## 项目概述

OpenClaw Recovery 是一个一键恢复工具，用于在新虚拟机环境中快速部署 OpenClaw 及相关开发环境。

## 安装阶段清单

### 基础环境层

| 阶段 | 名称 | 说明 |
|------|------|------|
| 01 | 系统依赖 | 基础工具、SSH、中文输入法 |
| 02 | GitHub Hosts | GitHub 访问优化 |
| 03 | Docker | Docker CE + Compose |
| 04 | Node.js | NVM + Node.js v24 |
| 05 | Python | pip, uv + 开发工具 |
| 06 | Golang | gvm + Go SDK |

### OpenClaw 层

| 阶段 | 名称 | 说明 |
|------|------|------|
| 07 | Chrome | Google Chrome (MCP 依赖) |
| 08 | OpenClaw | OpenClaw CLI + Serper 插件 |
| 09 | 配置恢复 | OpenClaw 配置文件恢复 |
| 10 | 工作空间 | Agent 工作空间初始化 |

### 开发工具层

| 阶段 | 名称 | 说明 |
|------|------|------|
| 11 | 开发工具 | Claude Code + GitHub CLI + CC Switch |

### 应用层

| 阶段 | 名称 | 说明 |
|------|------|------|
| 12 | 文件共享 | Samba 文件共享配置 |
| 13 | Obsidian | Obsidian AppImage |
| 14 | N8N | 工作流自动化平台 |
| 15 | Qt | Qt 6.8 LTS 开发环境 |

### 验证层

| 阶段 | 名称 | 说明 |
|------|------|------|
| 16 | 安装验证 | 安装验证测试 |

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

#### 阶段 03: Docker
- Docker CE 容器引擎
- Docker Compose 编排工具
- 用户权限自动配置

#### 阶段 05: Python 工具
- pip 包管理器（清华镜像）
- uv 快速包管理器
- 常用开发工具：black, flake8, pytest, jupyter, ipython
- 示例虚拟环境：`~/.venv_example`

#### 阶段 06: Go 环境
- gvm 版本管理器
- Go 1.21+ SDK
- 开发工具：goimports, gopls, dlv, golangci-lint, air
- 示例项目：`~/go/src/example.com/hello`

#### 阶段 14: N8N 工作流平台
- N8N 容器化部署
- 数据持久化配置
- 端口：5678

#### 阶段 15: Qt 开发环境
- Qt 6.8 LTS 长期支持版
- Qt Creator IDE
- CMake、Ninja 构建工具
- 中科大镜像加速下载

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
│       ├── 02-github-hosts.sh # GitHub hosts
│       ├── 03-docker.sh       # Docker
│       ├── 04-node.sh         # Node.js
│       ├── 05-python.sh       # Python
│       ├── 06-golang.sh       # Golang
│       ├── 07-chrome.sh       # Chrome
│       ├── 08-openclaw.sh     # OpenClaw
│       ├── 09-config.sh       # 配置恢复
│       ├── 10-workspaces.sh   # 工作空间
│       ├── 11-dev-tools.sh    # 开发工具
│       ├── 12-file-sharing.sh # 文件共享
│       ├── 13-obsidian.sh     # Obsidian
│       ├── 14-n8n.sh          # N8N
│       ├── 15-qt.sh           # Qt
│       └── 16-verify.sh       # 验证
└── specs/
    └── *.md                   # 规格文档
```

## 相关链接

- **OpenClaw 官方文档**: https://docs.openclaw.ai
- **OpenClaw 中文社区**: https://clawd.org.cn
- **GitHub 仓库**: https://github.com/JunJunHub/openclaw-recovery
