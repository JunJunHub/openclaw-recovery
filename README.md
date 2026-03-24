# OpenClaw Recovery 一键恢复工具

> ⚠️ **重要提醒**: 此工具专为**新虚拟机环境**设计，在已配置环境中执行可能覆盖现有配置！

---

## 快速开始

```bash
# 1. 克隆项目
git clone https://github.com/JunJunHub/openclaw-recovery.git
cd openclaw-recovery

# 2. 配置敏感信息
cp config/secrets.env.example config/secrets.env
nano config/secrets.env  # 填入真实值

# 3. 环境检测（推荐先执行）
./scripts/install.sh --check

# 4. 一键安装（默认原版）
./scripts/install.sh --all
```

---

## 使用说明

### 命令参数

```bash
./scripts/install.sh [选项]
```

| 参数 | 说明 |
|------|------|
| `--all` | 执行所有安装阶段 |
| `--stage <name>` | 执行指定阶段 |
| `--version <type>` | 选择 OpenClaw 版本 |
| `--check` | 仅检测环境，不执行安装 |
| `--interactive` | 交互式输入敏感信息 |
| `-h, --help` | 显示帮助信息 |

### 版本选择

| 参数 | 包名 | 说明 |
|------|------|------|
| `--version original` | openclaw@latest | 原版（默认），功能最新 |
| `--version cn` | openclaw-cn@latest | 社区版，飞书/钉钉/企微内置 |

**社区版 vs 原版差异**：

| 功能 | 社区版 | 原版 |
|------|--------|------|
| 飞书/钉钉/企微/QQ | ✅ 内置 | ❌ 需手动配置 |
| 最新功能 | 稍有延迟 | ✅ 首发 |
| Chrome MCP | ❌ | ✅ |
| 国内网络适配 | ✅ | 需配置代理 |

### 使用示例

```bash
# 环境检测
./scripts/install.sh --check

# 一键安装（原版，默认）
./scripts/install.sh --all

# 一键安装（社区版）
./scripts/install.sh --all --version cn

# 单独安装某个阶段
./scripts/install.sh --stage node
./scripts/install.sh --stage python
./scripts/install.sh --stage golang

# 交互式输入敏感信息
./scripts/install.sh --all --interactive
```

---

## 安装阶段清单

| 阶段 | 命令 | 安装内容 | 风险等级 |
|------|------|---------|---------|
| 01 | `--stage system` | 系统依赖 + SSH + 中文输入法 | 🟢 低 |
| 02 | `--stage node` | NVM + Node.js v24 | 🟢 低 |
| 03 | `--stage chrome` | Google Chrome | 🟢 低 |
| 04 | `--stage openclaw` | OpenClaw CLI + Serper 插件 | 🟡 中 |
| 05 | `--stage config` | 配置文件恢复 | 🔴 高（覆盖配置）|
| 06 | `--stage workspaces` | 工作空间初始化 | 🟢 低 |
| 07 | `--stage verify` | 安装验证测试 | 🟢 低 |
| 08 | `--stage dev-tools` | Claude Code + GitHub CLI | 🟡 中 |
| 09 | `--stage file-sharing` | Samba 文件共享 | 🔴 高（修改 smb.conf）|
| 10 | `--stage obsidian` | Obsidian AppImage | 🟢 低 |
| 11 | `--stage python` | Python 工具 (pip, uv) | 🟢 低 |
| 12 | `--stage golang` | Go 环境 (gvm, Go SDK) | 🟢 低 |

---

## 支持恢复的配置清单

### 系统工具

| 工具 | 用途 | 阶段 |
|------|------|------|
| curl | HTTP 客户端 | system |
| wget | 文件下载 | system |
| git | 版本控制 | system |
| vim | 文本编辑器 | system |
| jq | JSON 处理 | system |
| build-essential | 编译工具链 | system |
| net-tools | 网络配置 (ifconfig) | system |
| htop | 进程监控 | system |
| tmux | 终端复用 | system |
| tree | 目录树显示 | system |
| sqlite3 | SQLite 数据库 | system |
| openssh-server | SSH 远程登录 | system |
| open-vm-tools | VMware 增强工具 | system |
| cifs-utils | 挂载 Windows 共享 | system |
| samba | 共享文件夹给 Windows | system |
| ibus | 输入法框架 | system |
| ibus-pinyin | 中文拼音输入法 | system |

### 开发环境

| 组件 | 版本 | 阶段 |
|------|------|------|
| NVM | 0.40.1 | node |
| Node.js | v24.14.0 | node |
| npm | 淘宝镜像 | node |
| Google Chrome | 最新稳定版 | chrome |

### OpenClaw 核心

| 组件 | 说明 | 阶段 |
|------|------|------|
| OpenClaw CLI | 主程序（原版/社区版可选）| openclaw |
| Serper 插件 | 搜索插件 | openclaw |
| openclaw.json | 配置文件（从模板恢复）| config |
| 工作空间 | 5 个 Agent 工作空间 | workspaces |

### Python 工具

| 工具 | 说明 | 阶段 |
|------|------|------|
| pip | Python 包管理器 | python |
| uv | 快速 Python 包管理器 | python |
| black | 代码格式化 | python |
| flake8 | 代码检查 | python |
| pytest | 测试框架 | python |
| jupyter | Jupyter Notebook | python |
| ipython | 交互式 Python | python |

**Python 镜像配置**：
- pip 镜像：https://pypi.tuna.tsinghua.edu.cn/simple
- uv 镜像：https://pypi.tuna.tsinghua.edu.cn/simple

### Go 环境

| 组件 | 说明 | 阶段 |
|------|------|------|
| gvm | Go 版本管理器 | golang |
| Go SDK | 最新稳定版 (1.21+) | golang |
| goimports | 代码格式化 | golang |
| gopls | 语言服务器 | golang |
| dlv | 调试器 | golang |
| golangci-lint | 代码检查 | golang |
| air | 热重载开发工具 | golang |

**Go 镜像配置**：
- GOPROXY：https://goproxy.cn
- GOSUMDB：sum.golang.google.cn

### 配置文件恢复

| 文件 | 路径 | 说明 |
|------|------|------|
| openclaw.json | ~/.openclaw/openclaw.json | OpenClaw 主配置 |
| secrets.env | config/secrets.env | 敏感信息（需手动配置）|

**配置模板变量**：

| 变量 | 说明 | 来源 |
|------|------|------|
| `{{SILICONFLOW_API_KEY}}` | SiliconFlow API Key | https://cloud.siliconflow.cn |
| `{{BAIDU_QIANFAN_API_KEY}}` | 百度千帆 API Key | https://console.bce.baidu.com/qianfan |
| `{{FEISHU_APP_ID}}` | 飞书应用 ID | https://open.feishu.cn/app |
| `{{FEISHU_APP_SECRET}}` | 飞书应用密钥 | https://open.feishu.cn/app |
| `{{GATEWAY_TOKEN}}` | Gateway 认证令牌 | 自动生成或手动指定 |
| `{{SERPER_API_KEY}}` | Serper 搜索 API Key | https://serper.dev |

### 工作空间

| 工作空间 | 路径 | 用途 |
|---------|------|------|
| main | ~/.openclaw/workspace | 主 Agent |
| thinker | ~/.openclaw/workspace-thinker | 技术调研 |
| media | ~/.openclaw/workspace-media | 内容创作 |
| monitor | ~/.openclaw/workspace-monitor | 监控调度 |
| coder | ~/.openclaw/workspace-coder | 开发实现 |

每个工作空间自动创建：
- `AGENTS.md` - 工作空间说明
- `SOUL.md` - Agent 人格定义
- `USER.md` - 用户信息
- `MEMORY.md` - 长期记忆
- `memory/` - 日志目录

### 开发工具

| 工具 | 说明 | 阶段 |
|------|------|------|
| Claude Code CLI | AI 编程助手 | dev-tools |
| GitHub CLI | Git 命令行工具 | dev-tools |

### 文件共享

| 配置 | 路径/命令 | 说明 |
|------|----------|------|
| 共享目录 | /home/Share | 共享给 Windows |
| 挂载点 | /home/mnt/win | 挂载 Windows 共享 |
| 挂载脚本 | ~/mount-win.sh | 挂载 Windows 共享 |
| 卸载脚本 | ~/unmount-win.sh | 卸载 Windows 共享 |
| Samba 配置 | /etc/samba/smb.conf | 自动添加 [Share] 配置 |

### 桌面应用

| 应用 | 安装位置 | 阶段 |
|------|---------|------|
| Obsidian | ~/Applications/Obsidian.AppImage | obsidian |
| 启动脚本 | ~/.local/bin/obsidian | obsidian |
| 桌面快捷方式 | 应用菜单 → Obsidian | obsidian |

---

## 中文输入法配置

安装完成后，中文输入法已自动安装，但需要手动配置：

### 配置步骤

1. **重启系统**（确保输入法框架生效）
   ```bash
   sudo reboot
   ```

2. **配置输入法**
   - 在桌面环境设置中添加中文输入法
   - 或在终端运行：`ibus-setup`

3. **切换输入法**
   - 默认快捷键：`Super + Space`（Windows 键 + 空格）
   - 中英切换：`Shift`

### 已安装组件

- ibus 输入法框架
- ibus-pinyin 拼音输入法
- GTK/Qt GUI 工具包支持

---

## Serper 搜索插件

OpenClaw 默认安装 Serper 搜索插件，用于网络搜索功能。

### 配置 Serper API Key

1. **获取 API Key**
   - 访问：https://serper.dev
   - 注册账号并获取 API Key

2. **配置到 OpenClaw**
   ```bash
   # 编辑配置文件
   nano ~/.openclaw/openclaw.json
   
   # 在 plugins 配置中添加
   {
     "plugins": {
       "serper": {
         "apiKey": "YOUR_SERPER_API_KEY"
       }
     }
   }
   ```

3. **或通过 secrets.env 配置**
   ```bash
   # 添加到 config/secrets.env
   SERPER_API_KEY=your_api_key_here
   ```

---

## 敏感信息配置

### 配置文件模板

```bash
# config/secrets.env

# ============ API Keys ============
# SiliconFlow (DeepSeek/Qwen 等模型)
SILICONFLOW_API_KEY=sk-xxxxxxxxxxxxxxxx

# 百度千帆 (ERNIE 等模型)
BAIDU_QIANFAN_API_KEY=bce-v3/xxxxxxxxxxxxxxxx

# Serper 搜索 API
SERPER_API_KEY=xxxxxxxxxxxxxxxx

# ============ 飞书配置 ============
# 用于飞书消息通道
FEISHU_APP_ID=cli_xxxxxxxxxxxx
FEISHU_APP_SECRET=xxxxxxxxxxxxxxxxxxxx

# ============ Gateway 配置 ============
# 留空则自动生成
GATEWAY_TOKEN=
```

### 配置获取地址

| 配置项 | 获取地址 |
|--------|----------|
| SiliconFlow | https://cloud.siliconflow.cn/account/ak |
| 百度千帆 | https://console.bce.baidu.com/qianfan/ais/console/applicationConsole/application/v2 |
| Serper | https://serper.dev |
| 飞书应用 | https://open.feishu.cn/app → 创建企业自建应用 |

---

## 保护机制

### 1. 环境检测模式
```bash
./scripts/install.sh --check
```
仅检测环境状态，不执行任何安装操作。

### 2. 执行计划预览
运行安装前显示将要执行的所有阶段和潜在风险。

### 3. 配置变更预览
覆盖配置前显示 diff 对比，需要用户确认。

### 4. 自动备份
- `openclaw.json` → `openclaw.json.bak.YYYYMMDDHHMMSS`
- `smb.conf` → `smb.conf.bak`

### 5. 交互式确认
关键操作需要 `y/N` 确认。

---

## 使用场景

### ✅ 推荐场景

- 新安装的 Ubuntu 虚拟机
- 系统重装后快速恢复环境
- 虚拟机快照恢复后重建环境

### ❌ 不推荐场景

- 已配置好的生产环境（可能覆盖配置）
- 不确定当前环境状态（建议先用 --check 检测）

---

## 常见问题

### Q: NVM 安装失败
```bash
# 使用国内镜像
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
export NVM_NODEJS_ORG_MIRROR=https://npmmirror.com/mirrors/node
nvm install 24.14.0
```

### Q: Go 下载慢
```bash
# gvm 已配置代理，如需手动设置
export GOPROXY=https://goproxy.cn,direct
```

### Q: Python 包下载慢
```bash
# pip 已配置清华镜像，如需手动设置
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
```

### Q: 如何恢复备份的配置？
```bash
# 查找备份文件
ls -la ~/.openclaw/openclaw.json.bak.*

# 恢复
cp ~/.openclaw/openclaw.json.bak.20260324120000 ~/.openclaw/openclaw.json
```

### Q: 中文输入法不生效？
1. 确保已重启系统
2. 检查环境变量：
   ```bash
   echo $GTK_IM_MODULE  # 应显示 ibus
   echo $QT_IM_MODULE   # 应显示 ibus
   ```
3. 运行 `ibus-setup` 重新配置

---

## 项目结构

```
openclaw-recovery/
├── README.md                   # 本文档
├── DO_NOT_TEST_HERE.md         # 生产环境警告
├── specs/                      # 规格文档
│   ├── 00-overview.md
│   ├── 01-system-deps.md
│   ├── 02-openclaw-install.md
│   ├── 03-config-restore.md
│   ├── 04-workspaces.md
│   ├── 05-verification.md
│   ├── 06-dev-tools.md
│   └── 07-obsidian.md
├── scripts/
│   ├── install.sh              # 主入口
│   ├── lib/
│   │   └── common.sh           # 公共函数
│   └── stages/
│       ├── 01-system.sh
│       ├── 02-node.sh
│       ├── 03-chrome.sh
│       ├── 04-openclaw.sh
│       ├── 05-config.sh
│       ├── 06-workspaces.sh
│       ├── 07-verify.sh
│       ├── 08-dev-tools.sh
│       ├── 09-file-sharing.sh
│       ├── 10-obsidian.sh
│       ├── 11-python.sh
│       └── 12-golang.sh
└── config/
    ├── openclaw.json.template  # 配置模板
    ├── secrets.env.example     # 敏感信息示例
    └── secrets.env             # 敏感信息（需创建，不提交）
```

---

## 相关资源

- **GitHub**: https://github.com/JunJunHub/openclaw-recovery
- **OpenClaw 官方文档**: https://docs.openclaw.ai
- **OpenClaw 中文社区**: https://clawd.org.cn
- **问题反馈**: https://github.com/JunJunHub/openclaw-recovery/issues

---

## License

MIT
