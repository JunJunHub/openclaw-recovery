#!/bin/bash
# 阶段 5: Python 工具安装

log_info "=== 阶段 5: Python 工具安装 ==="

# 检查 Python3
check_python() {
  log_step "检查 Python 环境..."

  if command_exists python3; then
    local version=$(python3 --version 2>/dev/null | awk '{print $2}')
    log_info "Python3 已安装: $version"
    return 0
  else
    log_warn "Python3 未安装，尝试安装..."
    sudo apt update
    sudo apt install -y python3 python3-pip python3-venv
    log_info "Python3 安装完成"
    return 0
  fi
}

# 配置 pip 镜像源
setup_pip_mirror() {
  log_step "配置 pip 镜像源..."

  local pip_conf_dir="$HOME/.pip"
  local pip_conf="$pip_conf_dir/pip.conf"

  # 创建目录
  mkdir -p "$pip_conf_dir"

  # 检查是否已配置
  if [ -f "$pip_conf" ] && grep -q "https://pypi.tuna.tsinghua.edu.cn/simple" "$pip_conf" 2>/dev/null; then
    log_info "pip 镜像源已配置，跳过"
    return 0
  fi

  # 创建配置
  cat > "$pip_conf" << 'EOF'
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
trusted-host = pypi.tuna.tsinghua.edu.cn
timeout = 120

[install]
trusted-host = pypi.tuna.tsinghua.edu.cn
EOF

  log_info "pip 镜像源已配置: $pip_conf"

  # 全局配置文件（可选）
  local global_conf="/etc/pip.conf"
  if [ ! -f "$global_conf" ]; then
    echo "配置全局 pip 镜像源..."
    sudo tee "$global_conf" > /dev/null << 'EOF'
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
trusted-host = pypi.tuna.tsinghua.edu.cn
timeout = 120
EOF
    log_info "全局 pip 配置已创建"
  fi
}

# 升级 pip
upgrade_pip() {
  log_step "升级 pip..."

  if command_exists pip3; then
    python3 -m pip install --upgrade pip --no-warn-script-location
    log_info "pip 已升级: $(pip3 --version 2>/dev/null | awk '{print $2}')"
  else
    log_warn "未找到 pip3，尝试安装 python3-pip"
    sudo apt install -y python3-pip
    python3 -m pip install --upgrade pip --no-warn-script-location
    log_info "pip 安装并升级完成"
  fi
}

# 安装 uv（快速 Python 包管理器）
install_uv() {
  log_step "安装 uv (快速 Python 包管理器)..."

  if command_exists uv; then
    local version=$(uv --version 2>/dev/null | awk '{print $2}')
    log_info "uv 已安装: $version"
    return 0
  fi

  log_info "正在安装 uv..."
  
  # 使用官方安装脚本
  curl -LsSf https://astral.sh/uv/install.sh | sh
  
  # 等待安装完成，更新 PATH
  if [ -f "$HOME/.cargo/bin/uv" ]; then
    export PATH="$HOME/.cargo/bin:$PATH"
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> "$HOME/.bashrc"
  fi
  
  # 验证安装
  if command_exists uv; then
    local version=$(uv --version 2>/dev/null | awk '{print $2}')
    log_info "uv 安装成功: $version"
    
    # 配置 uv 镜像源
    if command_exists uv; then
      uv config set registry.index-url "https://pypi.tuna.tsinghua.edu.cn/simple"
      log_info "uv 镜像源已配置"
    fi
  else
    log_warn "uv 安装失败，尝试使用 pip 安装"
    python3 -m pip install uv --no-warn-script-location
    log_info "uv 通过 pip 安装完成"
  fi
}

# 安装常用 Python 开发工具
install_dev_tools() {
  log_step "安装常用 Python 开发工具..."

  local tools=(
    "black"          # 代码格式化
    "flake8"         # 代码检查
    "pytest"         # 测试框架
    "jupyter"        # Jupyter Notebook
    "ipython"        # 交互式 Python
    "virtualenv"     # 虚拟环境（Python 3.3+ 自带 venv，但保留）
    "wheel"          # 打包工具
  )

  for tool in "${tools[@]}"; do
    log_info "安装 $tool..."
    python3 -m pip install "$tool" --no-warn-script-location 2>/dev/null || log_warn "安装 $tool 失败"
  done

  log_info "常用 Python 开发工具安装完成"
}

# 创建虚拟环境示例
create_example_venv() {
  log_step "创建虚拟环境示例..."

  local venv_dir="$HOME/.venv_example"
  
  if [ -d "$venv_dir" ]; then
    log_info "示例虚拟环境已存在: $venv_dir"
    return 0
  fi

  python3 -m venv "$venv_dir"
  log_info "示例虚拟环境已创建: $venv_dir"
  
  # 创建激活脚本说明
  cat > "$HOME/activate-venv.sh" << 'EOF'
#!/bin/bash
# 激活虚拟环境脚本
# 用法: source ~/activate-venv.sh

VENV_DIR="$HOME/.venv_example"

if [ -f "$VENV_DIR/bin/activate" ]; then
  source "$VENV_DIR/bin/activate"
  echo "✅ 虚拟环境已激活"
  echo "    Python: $(python --version)"
  echo "    pip: $(pip --version | awk '{print $2}')"
  echo ""
  echo "退出虚拟环境: deactivate"
else
  echo "❌ 虚拟环境不存在: $VENV_DIR"
  echo "重新创建: python3 -m venv \$VENV_DIR"
fi
EOF

  chmod +x "$HOME/activate-venv.sh"
  log_info "激活脚本已创建: ~/activate-venv.sh"
}

# 显示配置信息
show_python_info() {
  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "                    🐍 Python 环境配置完成"
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
  
  echo "【Python 版本】"
  python3 --version 2>/dev/null || echo "  未安装"
  echo ""
  
  echo "【pip 版本】"
  python3 -m pip --version 2>/dev/null || echo "  未安装"
  echo ""
  
  echo "【uv 版本】"
  if command_exists uv; then
    uv --version 2>/dev/null || echo "  未安装"
  else
    echo "  未安装"
  fi
  echo ""
  
  echo "【镜像源配置】"
  echo "  pip: https://pypi.tuna.tsinghua.edu.cn/simple"
  if command_exists uv; then
    echo "  uv: 已配置清华镜像"
  fi
  echo ""
  
  echo "【工具列表】"
  echo "  ✓ pip - Python 包管理器"
  echo "  ✓ uv - 快速 Python 包管理器"
  echo "  ✓ black - 代码格式化"
  echo "  ✓ flake8 - 代码检查"
  echo "  ✓ pytest - 测试框架"
  echo "  ✓ jupyter - Jupyter Notebook"
  echo "  ✓ ipython - 交互式 Python"
  echo ""
  
  echo "【虚拟环境】"
  echo "  示例虚拟环境: ~/.venv_example"
  echo "  激活命令: source ~/activate-venv.sh"
  echo "  退出命令: deactivate"
  echo ""
  
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
}

# 主流程
main() {
  check_python
  setup_pip_mirror
  upgrade_pip
  install_uv
  install_dev_tools
  create_example_venv
  show_python_info
  
  log_info "Python 工具安装完成"
}

main