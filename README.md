# OpenClaw 一键恢复脚本

> ⚠️ **重要提醒**: 此脚本仅供**新虚拟机环境**使用，禁止在当前生产环境测试！

在全新的 Ubuntu 虚拟机环境中，基于国内网络条件，一键恢复 OpenClaw 的完整配置环境。

## 快速开始

```bash
# 1. 克隆项目
git clone <repo-url> openclaw-recovery
cd openclaw-recovery

# 2. 配置敏感信息
cp config/secrets.env.example config/secrets.env
nano config/secrets.env  # 填入真实值

# 3. 执行一键安装（默认社区版）
chmod +x scripts/install.sh
./scripts/install.sh --all

# 或安装原版 OpenClaw
./scripts/install.sh --all --version original
```

## 版本选择

支持两种 OpenClaw 版本：

| 参数 | 包名 | 说明 |
|------|------|------|
| `--version cn` | openclaw-cn | 社区版（默认），飞书/钉钉/企微开箱即用 |
| `--version original` | openclaw | 原版，功能最新，需手动配置渠道 |

**社区版 vs 原版差异**：

| 功能 | 社区版 | 原版 |
|------|--------|------|
| 飞书/钉钉/企微/QQ | ✅ 内置 | ❌ 需手动配置 |
| 最新功能 | 稍有延迟 | ✅ 首发 |
| Chrome MCP | ❌ | ✅ |
| 国内网络适配 | ✅ | 需配置代理 |

## 系统要求

- **操作系统**: Ubuntu 22.04/24.04 LTS
- **权限**: 需要 sudo 权限安装系统依赖
- **网络**: 国内网络环境

## 安装内容

### 系统工具

| 工具 | 用途 |
|------|------|
| curl / wget | 网络下载 |
| git / vim | 版本控制 + 编辑器 |
| net-tools | ifconfig 网络配置 |
| htop | 进程监控 |
| tmux | 终端复用 |
| jq | JSON 处理 |

### 虚拟机工具

| 工具 | 用途 |
|------|------|
| open-vm-tools | VMware 增强工具 |
| open-vm-tools-desktop | VMware 桌面增强（剪贴板、共享文件夹等）|

### 编程工具

| 工具 | 用途 |
|------|------|
| Claude Code CLI | AI 编程助手 |
| GitHub CLI | GitHub 命令行工具 |

### 文件共享工具

| 工具 | 用途 |
|------|------|
| cifs-utils | 挂载 Windows 共享文件夹 |
| Samba | 共享文件夹给 Windows |

### 核心组件

| 组件 | 版本 | 说明 |
|------|------|------|
| NVM | 0.40.1 | Node 版本管理器 |
| Node.js | v24.14.0 | 运行环境 |
| Google Chrome | 最新稳定版 | 浏览器自动化 |
| OpenClaw | 可选 | `--version cn` 或 `--version original` |
| Agent Workspaces | 5 个 | 工作空间 |

## 使用方式

### 一键安装
```bash
# 社区版（默认）
./scripts/install.sh --all

# 原版
./scripts/install.sh --all --version original
```

### 分阶段安装
```bash
# 安装系统依赖
./scripts/install.sh --stage system

# 安装 NVM 和 Node.js
./scripts/install.sh --stage node

# 安装 Chrome
./scripts/install.sh --stage chrome

# 安装 OpenClaw
./scripts/install.sh --stage openclaw

# 恢复配置
./scripts/install.sh --stage config

# 验证安装
./scripts/install.sh --stage verify

# 安装编程工具
./scripts/install.sh --stage dev-tools

# 配置文件共享
./scripts/install.sh --stage file-sharing
```

## 文件共享配置

### 共享虚拟机文件夹给 Windows

安装完成后，虚拟机的 `/home/Share` 目录会自动共享给 Windows。

**Windows 访问方式**：
```
\\<虚拟机IP>\Share
```

例如：`\\192.168.1.100\Share`

### 挂载 Windows 共享文件夹

1. **Windows 端设置共享**
   - 右键文件夹 → 属性 → 共享 → 共享此文件夹
   - 记下共享名（如 `shared`）

2. **虚拟机端挂载**
   ```bash
   # 使用生成的脚本
   ~/mount-win.sh <Windows IP> <共享名> [用户名] [密码]

   # 示例 (guest 模式)
   ~/mount-win.sh 192.168.1.100 shared

   # 示例 (用户认证)
   ~/mount-win.sh 192.168.1.100 shared myuser mypassword
   ```

3. **卸载**
   ```bash
   ~/unmount-win.sh
   ```

### 目录说明

| 路径 | 用途 |
|------|------|
| `/home/mnt/win` | Windows 共享文件夹挂载点 |
| `/home/Share` | 共享给 Windows 的文件夹 |

## 配置说明

### 敏感信息配置

创建 `config/secrets.env` 文件：

```bash
# API Keys
SILICONFLOW_API_KEY=sk-xxx
BAIDU_QIANFAN_API_KEY=bce-v3/xxx

# 飞书配置
FEISHU_APP_ID=cli_xxx
FEISHU_APP_SECRET=xxx

# Gateway 配置
GATEWAY_TOKEN=xxx
```

### 配置获取地址

| 配置项 | 获取地址 |
|--------|----------|
| SiliconFlow API Key | https://cloud.siliconflow.cn/account/ak |
| 百度千帆 API Key | https://console.bce.baidu.com/qianfan/ais/console/applicationConsole/application/v2 |
| 飞书应用 | https://open.feishu.cn/app |

## 国内网络适配

脚本自动配置以下镜像源：

- **npm**: https://registry.npmmirror.com
- **NVM**: https://npmmirror.com/mirrors/node
- **Chrome**: 官方 .deb 包直连下载

## 项目结构

```
openclaw-recovery/
├── specs/                    # 规格文档
│   ├── 00-overview.md        # 总体规格
│   ├── 01-system-deps.md     # 系统依赖
│   ├── 02-openclaw-install.md
│   ├── 03-config-restore.md
│   ├── 04-workspaces.md
│   └── 05-verification.md
├── scripts/
│   └── install.sh            # 主安装脚本
├── config/
│   ├── openclaw.json.template
│   └── secrets.env.example
└── README.md
```

## 常见问题

### Q: NVM 安装失败
```bash
# 尝试使用国内镜像
curl -o- https://gitee.com/mirrors/nvm/raw/master/install.sh | bash
```

### Q: Chrome 下载超时
```bash
# 手动下载后安装
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y ./google-chrome-stable_current_amd64.deb
```

### Q: Node.js 下载慢
```bash
# 确认 NVM 镜像配置
export NVM_NODEJS_ORG_MIRROR=https://npmmirror.com/mirrors/node
nvm install 24.14.0
```

## 开发说明

本项目基于 **SpecKit** 规格驱动开发：

1. 先编写 `specs/` 目录下的规格文档
2. 根据规格文档实现 `scripts/` 目录下的脚本
3. 规格文档与实现保持同步

## License

MIT
