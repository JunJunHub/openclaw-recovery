# Node.js 环境规格

## 概述

通过 NVM (Node Version Manager) 安装和管理 Node.js 环境。

## 版本信息

| 组件 | 版本 | 说明 |
|------|------|------|
| NVM | v0.40.1 | Node.js 版本管理器 |
| Node.js | v24.14.0 | LTS 版本 |
| npm | 跟随 Node.js | 包管理器 |

## 安装内容

### NVM 安装
- 从 GitHub 官方仓库下载安装脚本
- 安装到 `~/.nvm` 目录
- 配置 shell 环境变量

### Node.js 安装
- 使用 NVM 安装指定版本
- 设置为默认版本
- 配置 npm 淘宝镜像

## 镜像配置

### Node.js 镜像
```
NVM_NODEJS_ORG_MIRROR=https://npmmirror.com/mirrors/node
```

### npm 镜像
```
registry=https://registry.npmmirror.com
```

## 安装命令

```bash
# 安装 NVM
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# 加载 NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# 安装 Node.js
nvm install v24.14.0
nvm use v24.14.0
nvm alias default v24.14.0

# 配置镜像
npm config set registry https://registry.npmmirror.com
```

## 验证方法

```bash
# 检查版本
node --version   # v24.14.0
npm --version    # 10.x.x
nvm --version    # 0.40.1

# 检查镜像配置
npm config get registry
```

## 环境变量

| 变量 | 值 | 说明 |
|------|------|------|
| NVM_DIR | ~/.nvm | NVM 安装目录 |
| NVM_NODEJS_ORG_MIRROR | npmmirror.com | Node.js 下载镜像 |
| npm_config_registry | npmmirror.com | npm 包镜像 |

## 使用说明

```bash
# 切换 Node.js 版本
nvm use v20

# 安装其他版本
nvm install v22

# 查看已安装版本
nvm list

# 查看远程可用版本
nvm ls-remote
```

## 系统要求

- Ubuntu 22.04 / 24.04
- curl 或 wget
- git
