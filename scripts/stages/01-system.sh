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
  tmux \
  tree \
  sqlite3 \
  sqlite3-doc

# 安装 SSH 服务
log_info "安装 SSH 服务..."
install_apt_packages \
  openssh-server

# 启用并启动 SSH
sudo systemctl enable ssh
sudo systemctl start ssh
log_info "SSH 服务已启用"

# 安装虚拟机工具（VMware）
log_info "安装 VMware 增强工具..."
install_apt_packages \
  open-vm-tools \
  open-vm-tools-desktop || log_warn "VMware 工具安装失败（可能不是 VMware 环境）"

# 安装文件共享工具
log_info "安装文件共享工具..."
install_apt_packages \
  cifs-utils \
  samba \
  samba-common-bin

# 安装中文输入法
log_info "安装中文输入法..."
install_apt_packages \
  ibus \
  ibus-clutter \
  ibus-gtk \
  ibus-gtk3 \
  ibus-qt4 \
  im-config \
  ibus-pinyin \
  ibus-table

log_info "中文输入法安装完成"
log_info "如需配置输入法，请运行: ibus-setup"

# 添加中文输入法环境变量
if ! grep -q "IBUS" "$HOME/.profile" 2>/dev/null; then
  cat >> "$HOME/.profile" << 'EOF'

# 中文输入法配置
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus
EOF
  log_info "已添加中文输入法环境变量到 ~/.profile"
fi

# 显示配置说明
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "                    🀄 中文输入法配置说明"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "已安装以下组件："
echo "  • ibus 输入法框架"
echo "  • ibus-pinyin 拼音输入法"
echo "  • 各种 GUI 工具包支持 (GTK, Qt)"
echo ""
echo "使用步骤："
echo "  1. 重启系统：sudo reboot"
echo "  2. 在桌面环境设置中添加中文输入法"
echo "  3. 或在终端运行：ibus-setup"
echo ""
echo "默认切换快捷键："
echo "  • 切换输入法：Super + Space (Windows 键 + 空格)"
echo "  • 中英切换：Shift"
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo ""

log_info "系统依赖安装完成"
