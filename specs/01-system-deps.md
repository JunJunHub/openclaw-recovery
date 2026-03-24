# 系统依赖规格

## 概述

安装 Ubuntu 系统所需的基础依赖包。

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

## 安装命令

```bash
sudo apt-get update

# 基础工具
sudo apt-get install -y curl wget git vim build-essential jq \
  apt-transport-https ca-certificates gnupg lsb-release

# 系统工具
sudo apt-get install -y net-tools htop tmux

# SSH 服务
sudo apt-get install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh

# 虚拟机工具
sudo apt-get install -y open-vm-tools open-vm-tools-desktop

# 文件共享
sudo apt-get install -y cifs-utils samba samba-common-bin
```

## 系统要求

- Ubuntu 22.04 / 24.04
- 至少 2GB 可用磁盘空间
- sudo 权限
