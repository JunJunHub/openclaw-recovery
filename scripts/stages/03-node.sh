#!/bin/bash
# 阶段 2: Node.js 安装 (通过 NVM)

NVM_VERSION="v0.40.1"
# OpenClaw 推荐的 Node.js 版本
NODE_VERSION="22"

log_step "安装 Node.js $NODE_VERSION (通过 NVM，OpenClaw 推荐)..."

# 检查是否已安装 NVM
if [ -d "$HOME/.nvm" ]; then
  log_info "NVM 已安装"
else
  log_info "安装 NVM $NVM_VERSION..."

  # 使用 NVM 镜像（国内加速）
  export NVM_NODEJS_ORG_MIRROR="https://npmmirror.com/mirrors/node"

  # 下载并安装 NVM
  wget -qO- "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" | bash

  # 加载 NVM
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

  log_info "NVM 安装完成"
fi

# 加载 NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# 检查 Node.js 版本
CURRENT_NODE=$(node --version 2>/dev/null || echo "none")

# 检查是否已安装 v22.x（OpenClaw 推荐）
if [[ "$CURRENT_NODE" == v22* ]]; then
  log_info "Node.js $CURRENT_NODE 已安装 (OpenClaw 推荐 v22.x)"
else
  log_info "安装 Node.js $NODE_VERSION (OpenClaw 推荐 v22.x)..."

  # 使用国内镜像
  export NVM_NODEJS_ORG_MIRROR="https://npmmirror.com/mirrors/node"

  # 安装 Node.js（OpenClaw 推荐 v22）
  nvm install "$NODE_VERSION"
  nvm use "$NODE_VERSION"
  nvm alias default "$NODE_VERSION"

  log_info "Node.js 安装完成: $(node --version) (OpenClaw 推荐)"
fi

# 配置 npm 淘宝镜像
log_info "配置 npm 淘宝镜像..."
npm config set registry https://registry.npmmirror.com

log_info "Node.js 环境配置完成"
