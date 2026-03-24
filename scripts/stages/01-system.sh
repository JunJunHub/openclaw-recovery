#!/bin/bash
# 阶段 1: 系统依赖安装

log_step "安装系统依赖..."

# 更新软件源
log_info "更新软件源..."
sudo apt-get update -qq

# 安装基础工具
log_info "安装基础工具..."
install_apt_packages \
  curl \
  wget \
  git \
  vim \
  build-essential \
  jq \
  apt-transport-https \
  ca-certificates \
  gnupg \
  lsb-release

# 安装系统工具
log_info "安装系统工具..."
install_apt_packages \
  net-tools \
  htop \
  tmux

# 安装虚拟机工具（VMware）
log_info "安装 VMware 增强工具..."
install_apt_packages \
  open-vm-tools \
  open-vm-tools-desktop || log_warn "VMware 工具安装失败（可能不是 VMware 环境）"

log_info "系统依赖安装完成"
