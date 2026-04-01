#!/bin/bash
# 阶段 10: Obsidian 安装

log_info "=== 阶段 10: Obsidian 安装 ==="

OBSIDIAN_DIR="$HOME/Applications"
OBSIDIAN_APPIMAGE="$OBSIDIAN_DIR/Obsidian.AppImage"
# 旧版本回退 URL（当 API 不可用时使用）
OBSIDIAN_URL="https://github.com/obsidianmd/obsidian-releases/releases/download/v1.12.7/Obsidian-1.12.7.AppImage"

# 安装依赖（AppImage 运行需要）
install_dependencies() {
  log_step "安装依赖..."

  # libfuse2 是 AppImage 必需的
  if ! dpkg -l | grep -q libfuse2; then
    log_info "安装 libfuse2..."
    sudo apt update
    sudo apt install -y libfuse2
  else
    log_info "libfuse2 已安装"
  fi
}

# 创建应用目录
setup_directories() {
  mkdir -p "$OBSIDIAN_DIR"
  mkdir -p "$HOME/.local/share/applications"
  mkdir -p "$HOME/.local/share/icons"
  log_info "创建应用目录: $OBSIDIAN_DIR"
}

# 下载 Obsidian AppImage
download_obsidian() {
  log_step "下载 Obsidian AppImage..."

  if [ -f "$OBSIDIAN_APPIMAGE" ]; then
    log_info "Obsidian 已存在: $OBSIDIAN_APPIMAGE"

    read -p "是否重新下载最新版本？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      return 0
    fi

    rm -f "$OBSIDIAN_APPIMAGE"
  fi

  # 检测系统架构
  local system_arch=$(uname -m)
  log_info "系统架构: $system_arch"
  
  # 获取最新版本信息
  log_info "获取 Obsidian 最新版本信息..."
  local release_info=$(curl -sL "https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest")
  local tag_name=$(echo "$release_info" | jq -r '.tag_name')
  log_info "最新版本: $tag_name"
  
  # 获取所有 AppImage 资产
  local asset_list=$(echo "$release_info" | jq -r '.assets[] | select(.name | endswith(".AppImage")) | "\(.name) \(.browser_download_url)"')
  
  if [ -z "$asset_list" ]; then
    log_error "无法获取 Obsidian AppImage 资产列表"
    return 1
  fi
  
  # 选择合适的 AppImage
  local selected_url=""
  
  # 根据架构选择合适的文件
  if [[ "$system_arch" == "x86_64" || "$system_arch" == "amd64" ]]; then
    log_info "选择 x86_64 架构的 Obsidian"
    
    # 首先尝试无架构后缀的标准版本（通常是 x86_64）
    selected_url=$(echo "$asset_list" | awk '/\.AppImage$/ && !/arm64|aarch64/ {print $2}' | head -1)
    
    # 如果没有找到，尝试包含 x86_64 或 amd64 的版本
    if [ -z "$selected_url" ]; then
      selected_url=$(echo "$asset_list" | awk '/x86_64|amd64/ {print $2}' | head -1)
    fi
  elif [[ "$system_arch" == "aarch64" || "$system_arch" == "arm64" ]]; then
    log_info "选择 ARM64 架构的 Obsidian"
    selected_url=$(echo "$asset_list" | awk '/arm64|aarch64/ {print $2}' | head -1)
  else
    log_warn "未知系统架构: $system_arch，尝试选择第一个 AppImage"
    selected_url=$(echo "$asset_list" | awk '{print $2}' | head -1)
  fi
  
  if [ -z "$selected_url" ]; then
    log_error "无法找到适合系统架构 ($system_arch) 的 Obsidian AppImage"
    log_error "可用的 AppImage 文件:"
    echo "$asset_list" | while read line; do
      log_error "  - $line"
    done
    return 1
  fi
  
  # 提取文件名用于显示
  local filename=$(echo "$asset_list" | grep "$(basename "$selected_url")" | awk '{print $1}')
  log_info "选择文件: $filename"
  log_info "下载地址: $selected_url"
  
  # 下载文件
  wget -q --show-progress -O "$OBSIDIAN_APPIMAGE" "$selected_url"

  if [ $? -eq 0 ]; then
    chmod +x "$OBSIDIAN_APPIMAGE"
    
    # 验证文件可执行性和架构
    if [ -x "$OBSIDIAN_APPIMAGE" ]; then
      log_info "文件已设置为可执行"
      
      # 检查文件架构
      local file_info=$(file "$OBSIDIAN_APPIMAGE" 2>/dev/null || echo "")
      log_info "文件信息: $file_info"
      
      # 架构验证
      if [[ "$system_arch" == "x86_64" ]] && [[ "$filename" == *"arm64"* || "$filename" == *"aarch64"* ]]; then
        log_error "错误：系统是 x86_64，但下载的是 ARM64 版本"
        log_error "文件名: $filename"
        log_error "请手动下载 x86_64 版本"
        rm -f "$OBSIDIAN_APPIMAGE"
        return 1
      elif [[ "$system_arch" == "aarch64" || "$system_arch" == "arm64" ]] && [[ ! "$filename" == *"arm64"* && ! "$filename" == *"aarch64"* ]]; then
        log_warn "警告：系统是 ARM64，但下载的是无架构后缀的版本（可能是 x86_64）"
      fi
    else
      log_error "无法设置文件为可执行"
      return 1
    fi
    
    log_info "Obsidian 下载完成"
    return 0
  else
    log_error "Obsidian 下载失败"
    return 1
  fi
}

# 创建桌面快捷方式
create_desktop_entry() {
  log_step "创建桌面快捷方式..."

  # 下载图标
  local icon_path="$HOME/.local/share/icons/obsidian.png"
  if [ ! -f "$icon_path" ]; then
    wget -q -O "$icon_path" "https://obsidian.md/images/obsidian-logo-gradient.svg" 2>/dev/null || true
  fi

  # 创建 .desktop 文件
  cat > "$HOME/.local/share/applications/obsidian.desktop" << EOF
[Desktop Entry]
Name=Obsidian
Comment=Obsidian Note Taking App
Exec=$OBSIDIAN_APPIMAGE --no-sandbox %U
Icon=$icon_path
Terminal=false
Type=Application
Categories=Office;Utility;
StartupNotify=true
MimeType=x-scheme-handler/obsidian;
EOF

  chmod +x "$HOME/.local/share/applications/obsidian.desktop"

  # 更新桌面数据库
  update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

  log_info "桌面快捷方式已创建"
}

# 创建启动脚本
create_launcher_script() {
  log_step "创建启动脚本..."

  local script_path="$HOME/.local/bin/obsidian"
  mkdir -p "$(dirname "$script_path")"

  cat > "$script_path" << 'EOF'
#!/bin/bash
# Obsidian 启动脚本
# 支持命令行启动和后台运行

OBSIDIAN_APP="$HOME/Applications/Obsidian.AppImage"

if [ ! -f "$OBSIDIAN_APP" ]; then
  echo "错误: Obsidian 未安装"
  echo "请运行: openclaw-recovery --stage obsidian"
  exit 1
fi

# 后台运行（虚拟机环境需要 --no-sandbox）
nohup "$OBSIDIAN_APP" --no-sandbox "$@" > /dev/null 2>&1 &
EOF

  chmod +x "$script_path"
  log_info "启动脚本已创建: $script_path"
}

# 显示使用说明
show_usage() {
  echo ""
  echo "========================================"
  echo "📝 Obsidian 安装完成"
  echo "========================================"
  echo ""
  echo "【安装位置】"
  echo "  AppImage: $OBSIDIAN_APPIMAGE"
  echo ""
  echo "【启动方式】"
  echo "  1. 应用菜单: 搜索 'Obsidian'"
  echo "  2. 命令行: obsidian"
  echo "  3. 直接运行: $OBSIDIAN_APPIMAGE"
  echo ""
  echo "【知识库位置】"
  echo "  默认: ~/.openclaw/obsidian/"
  echo ""
}

# 主流程
main() {
  install_dependencies
  setup_directories
  download_obsidian
  create_desktop_entry
  create_launcher_script
  show_usage

  log_info "Obsidian 安装完成"
}

main
