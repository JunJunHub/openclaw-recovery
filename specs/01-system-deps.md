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

## 安装命令

```bash
sudo apt-get update
sudo apt-get install -y curl wget git vim build-essential jq \
  apt-transport-https ca-certificates gnupg lsb-release
sudo apt-get install -y net-tools htop tmux
```

## 系统要求

- Ubuntu 22.04 / 24.04
- 至少 2GB 可用磁盘空间
- sudo 权限
