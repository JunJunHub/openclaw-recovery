# 系统依赖规格

## 概述

安装 Ubuntu 系统所需的基础依赖包，包括开发工具、系统工具和中文输入法支持。

## 依赖列表

### 基础工具

| 包名 | 用途 |
|------|------|
| curl | HTTP 客户端 |
| wget | 文件下载 |
| git | 版本控制 |
| vim | 文本编辑器 |
| build-essential | 编译工具链 |
| jq | JSON 处理 |
| apt-transport-https | HTTPS 软件源支持 |
| ca-certificates | CA 证书 |
| gnupg | GPG 密钥管理 |
| lsb-release | 系统信息 |

### 系统工具

| 包名 | 用途 |
|------|------|
| net-tools | 网络工具 (ifconfig) |
| htop | 进程监控 |
| tmux | 终端复用 |
| tree | 目录树显示 |
| sqlite3 | SQLite 数据库 |
| sqlite3-doc | SQLite 文档 |

### 网络服务

| 包名 | 用途 |
|------|------|
| openssh-server | SSH 远程登录服务 |

### 虚拟机工具

| 包名 | 用途 |
|------|------|
| open-vm-tools | VMware 增强工具 |
| open-vm-tools-desktop | VMware 桌面增强 |

### 文件共享工具

| 包名 | 用途 |
|------|------|
| cifs-utils | 挂载 Windows 共享 |
| samba | 共享文件夹给 Windows |
| samba-common-bin | Samba 管理工具 |

### 中文输入法

| 包名 | 用途 |
|------|------|
| ibus | 输入法框架核心 |
| ibus-clutter | Clutter 工具包支持 |
| ibus-gtk | GTK2 应用支持 |
| ibus-gtk3 | GTK3 应用支持 |
| im-config | 输入法配置工具 |
| ibus-pinyin | 拼音输入法引擎 |
| ibus-table | 表格输入法引擎 |

> ⚠️ **注意**: `ibus-qt4` 已过时，在 Ubuntu 22.04 中不再提供。现代 Qt5/Qt6 应用使用 `ibus` 核心包的内置支持。

## 安装命令

```bash
sudo apt-get update

# 基础工具
sudo apt-get install -y curl wget git vim build-essential jq \
  apt-transport-https ca-certificates gnupg lsb-release

# 系统工具
sudo apt-get install -y net-tools htop tmux tree sqlite3 sqlite3-doc

# SSH 服务
sudo apt-get install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh

# 虚拟机工具
sudo apt-get install -y open-vm-tools open-vm-tools-desktop

# 文件共享
sudo apt-get install -y cifs-utils samba samba-common-bin

# 中文输入法
sudo apt-get install -y ibus ibus-clutter ibus-gtk ibus-gtk3 \
  im-config ibus-pinyin ibus-table
```

## 中文输入法配置

安装后需要配置环境变量（已自动添加到 `~/.profile`）：

```bash
# 中文输入法配置
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus
```

### 配置步骤

1. 重启系统或重新登录
2. 运行 `ibus-setup` 配置输入法
3. 在系统设置中添加中文输入源

### 切换快捷键

- 切换输入法：`Super + Space` (Windows 键 + 空格)
- 中英切换：`Shift`

## 系统要求

- Ubuntu 22.04 / 24.04
- 至少 2GB 可用磁盘空间
- sudo 权限
