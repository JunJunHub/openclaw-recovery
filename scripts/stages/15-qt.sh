#!/bin/bash
# 阶段 15: Qt 开发环境安装

log_info "=== 阶段 15: Qt 开发环境安装 ==="

# 配置
QT_VERSION="${QT_VERSION:-6.8}"  # 默认安装 Qt 6.8 LTS
QT_INSTALL_DIR="${QT_INSTALL_DIR:-$HOME/Qt}"
QT_MIRROR="https://mirrors.ustc.edu.cn/qtproject"
QT_INSTALLER_NAME="qt-online-installer-linux-x64-online.run"
QT_INSTALLER_URL="$QT_MIRROR/official_releases/online_installers/$QT_INSTALLER_NAME"
MIN_DISK_SPACE_GB=15  # Qt 安装至少需要 15GB

# 检查磁盘空间
check_disk_space() {
  log_step "检查磁盘空间..."

  local available_gb=$(df -BG "$HOME" | awk 'NR==2 {gsub(/G/,"",$4); print $4}')

  if [ "$available_gb" -lt "$MIN_DISK_SPACE_GB" ]; then
    log_error "磁盘空间不足！当前可用: ${available_gb}GB，建议至少 ${MIN_DISK_SPACE_GB}GB"
    log_warn "Qt 完整安装约需 10-15GB 空间"
    return 1
  fi

  log_info "磁盘空间充足: ${available_gb}GB 可用"
  return 0
}

# 检查是否已安装
check_existing_qt() {
  log_step "检查现有 Qt 安装..."

  if [ -d "$QT_INSTALL_DIR" ]; then
    log_info "检测到现有 Qt 安装: $QT_INSTALL_DIR"

    # 列出已安装版本
    if [ -d "$QT_INSTALL_DIR/6."* ]; then
      log_info "已安装的 Qt 6 版本:"
      ls -d "$QT_INSTALL_DIR"/6.*/ 2>/dev/null | while read dir; do
        local version=$(basename "$dir")
        echo "  - Qt $version"
      done
    fi

    echo ""
    read -p "是否重新安装/添加组件？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      log_info "跳过 Qt 安装"
      return 1
    fi
  fi

  return 0
}

# 安装 Qt 依赖
install_qt_deps() {
  log_step "安装 Qt 编译依赖..."

  local deps=(
    "build-essential"
    "libgl1-mesa-dev"
    "libxcb-xinerama0-dev"
    "libxkbcommon-x11-dev"
    "libx11-xcb-dev"
    "libglu1-mesa-dev"
    "libfontconfig1"
    "libdbus-1-3"
    "libnss3"
    "libnspr4"
    "libxcomposite1"
    "libxdamage1"
    "libxrandr2"
    "libxcursor1"
    "libxi6"
    "libasound2t64"
  )

  log_info "安装依赖包..."
  sudo apt-get update -qq
  sudo apt-get install -y "${deps[@]}" 2>/dev/null || {
    # Ubuntu 24.04+ 使用 t64 包名，回退兼容
    log_warn "部分包安装失败，尝试兼容模式..."
    sudo apt-get install -y "${deps[@]//libasound2t64/libasound2}" 2>/dev/null || true
  }

  log_info "Qt 依赖安装完成"
}

# 下载 Qt 安装器
download_qt_installer() {
  log_step "下载 Qt 在线安装器..."

  QT_INSTALLER_PATH="/tmp/qt-installer/$QT_INSTALLER_NAME"
  local download_dir="/tmp/qt-installer"

  # 清理旧文件
  rm -rf "$download_dir"
  mkdir -p "$download_dir"

  # 尝试多个下载源
  local mirrors=(
    "$QT_MIRROR/official_releases/online_installers/$QT_INSTALLER_NAME"
    "https://download.qt.io/official_releases/online_installers/$QT_INSTALLER_NAME"
  )

  for url in "${mirrors[@]}"; do
    log_info "尝试下载: $url"
    if wget -q --show-progress --timeout=30 -O "$QT_INSTALLER_PATH" "$url"; then
      chmod +x "$QT_INSTALLER_PATH"
      log_info "安装器下载完成: $QT_INSTALLER_PATH"
      return 0
    fi
    log_warn "下载失败: $url"
  done

  log_error "所有下载源均失败"
  return 1
}

# 生成自动安装脚本
generate_install_script() {
  QT_INSTALL_SCRIPT_PATH="/tmp/qt-installer/auto-install.qs"

  log_step "生成自动安装脚本..."

  cat > "$QT_INSTALL_SCRIPT_PATH" << 'INSTALLSCRIPT'
// Qt 自动安装脚本
// 安装 Qt 6.8 LTS + Qt Creator

function Controller() {
    installer.autoRejectMessageBoxes();
    installer.installationFinished.connect(function() {
        gui.clickButton(buttons.NextButton);
    });
}

Controller.prototype.WelcomePageCallback = function() {
    gui.clickButton(buttons.NextButton, 3000);
}

Controller.prototype.CredentialsPageCallback = function() {
    // 跳过登录（开源版无需登录）
    gui.clickButton(buttons.SkipButton, 1000);
}

Controller.prototype.IntroductionPageCallback = function() {
    gui.clickButton(buttons.NextButton, 1000);
}

Controller.prototype.TargetDirectoryPageCallback = function() {
    // 设置安装目录
    var dir = system.environmentVariable("QT_INSTALL_DIR") || "/home/" + system.environmentVariable("USER") + "/Qt";
    installer.setValue("TargetDir", dir);
    gui.clickButton(buttons.NextButton, 1000);
}

Controller.prototype.ComponentSelectionPageCallback = function() {
    // 选择组件
    var page = gui.pageWidgetByObjectName("ComponentSelectionPage");

    // 获取要安装的 Qt 版本
    var qtVersion = system.environmentVariable("QT_VERSION") || "6.8";

    // 选择 Qt 版本 (Desktop gcc_64)
    var componentId = "qt.qt6." + qtVersion.replace(".", "") + ".gcc_64";
    if (installer.componentByName(componentId)) {
        page.deselectAll();
        page.selectComponent(componentId);
    }

    // Qt Creator 默认已选中
    gui.clickButton(buttons.NextButton, 1000);
}

Controller.prototype.LicenseAgreementPageCallback = function() {
    var page = gui.pageWidgetByObjectName("LicenseAgreementPage");
    page.acceptRadioButton.checked = true;
    gui.clickButton(buttons.NextButton, 1000);
}

Controller.prototype.ReadyForInstallationPageCallback = function() {
    gui.clickButton(buttons.NextButton, 1000);
}

Controller.prototype.PerformInstallationPageCallback = function() {
    // 等待安装完成
}

Controller.prototype.FinishedPageCallback = function() {
    gui.clickButton(buttons.FinishButton, 1000);
}
INSTALLSCRIPT

  log_info "自动安装脚本已生成: $QT_INSTALL_SCRIPT_PATH"
}

# 运行 Qt 安装器
run_qt_installer() {
  local installer_path="$1"
  local script_path="$2"

  log_step "运行 Qt 安装器..."
  log_info "使用镜像源加速: $QT_MIRROR"

  # 导出环境变量
  export QT_INSTALL_DIR
  export QT_VERSION

  # 运行安装器（使用镜像 + 自动安装脚本）
  # 注意: --mirror 参数是关键，确保从国内镜像下载
  "$installer_path" \
    --mirror "$QT_MIRROR" \
    --script "$script_path" \
    --verbose

  return $?
}

# 手动安装提示
show_manual_install_guide() {
  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "              📋 Qt 手动安装指南"
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
  echo "如果自动安装失败，请手动执行以下步骤："
  echo ""
  echo "1. 下载安装器："
  echo "   wget https://download.qt.io/official_releases/online_installers/qt-online-installer-linux-x64-online.run"
  echo "   chmod +x qt-online-installer-linux-x64-online.run"
  echo ""
  echo "2. 运行安装器（使用镜像加速）："
  echo "   ./qt-online-installer-linux-x64-online.run --mirror $QT_MIRROR"
  echo ""
  echo "3. 在安装界面选择组件："
  echo "   ✓ Qt 6.8.x → Desktop gcc_64"
  echo "   ✓ Qt Creator（默认已选）"
  echo "   ✓ Developer and Designer Tools → CMake、Ninja（如未安装）"
  echo ""
  echo "4. 安装完成后配置环境变量："
  echo "   echo 'export PATH=\"\$HOME/Qt/6.8.x/gcc_64/bin:\$PATH\"' >> ~/.bashrc"
  echo "   source ~/.bashrc"
  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
}

# 配置环境变量
setup_qt_env() {
  log_step "配置 Qt 环境变量..."

  local bashrc="$HOME/.bashrc"

  # 检查是否已配置
  if grep -q "Qt/6\." "$bashrc" 2>/dev/null; then
    log_info "Qt PATH 已配置"
    return 0
  fi

  # 构建所有需要添加的 PATH
  local qt_paths=()

  # Qt SDK bin
  for dir in "$QT_INSTALL_DIR"/6.*/gcc_64/bin; do
    if [ -d "$dir" ]; then
      qt_paths+=("$dir")
      break
    fi
  done

  # Qt Tools (CMake, Ninja 等)
  [ -d "$QT_INSTALL_DIR/Tools/CMake/bin" ] && qt_paths+=("$QT_INSTALL_DIR/Tools/CMake/bin")
  [ -d "$QT_INSTALL_DIR/Tools/Ninja/bin" ] && qt_paths+=("$QT_INSTALL_DIR/Tools/Ninja/bin")

  if [ ${#qt_paths[@]} -eq 0 ]; then
    log_warn "未找到 Qt 安装目录，跳过环境变量配置"
    return 1
  fi

  # 添加到 bashrc
  echo "" >> "$bashrc"
  echo "# Qt 6" >> "$bashrc"

  for path in "${qt_paths[@]}"; do
    echo "export PATH=\"$path:\$PATH\"" >> "$bashrc"
    log_info "添加到 PATH: $path"
  done

  log_info "Qt PATH 已添加到 ~/.bashrc"

  # 添加 Qt Creator 快捷方式
  if [ -f "$QT_INSTALL_DIR/Tools/QtCreator/bin/qtcreator" ]; then
    local qtcreator_path="$QT_INSTALL_DIR/Tools/QtCreator/bin/qtcreator"
    local desktop_file="$HOME/.local/share/applications/qtcreator.desktop"

    mkdir -p "$(dirname "$desktop_file")"

    cat > "$desktop_file" << EOF
[Desktop Entry]
Type=Application
Name=Qt Creator
Comment=Integrated Development Environment for Qt
Exec=$qtcreator_path %F
Icon=$QT_INSTALL_DIR/Tools/QtCreator/share/qtcreator/logo/logo_icon.png
Terminal=false
Categories=Development;IDE;Qt;
MimeType=text/x-c++src;text/x-c++hdr;text/x-csrc;text/x-chdr;
EOF

    log_info "Qt Creator 桌面快捷方式已创建"
  fi

  return 0
}

# 验证安装
verify_qt_install() {
  log_step "验证 Qt 安装..."

  local success=true

  # 检查 qmake
  if [ -f "$QT_INSTALL_DIR"/6.*/gcc_64/bin/qmake ]; then
    local qmake_path=$(ls "$QT_INSTALL_DIR"/6.*/gcc_64/bin/qmake 2>/dev/null | head -1)
    local qt_version=$($qmake_path --version 2>/dev/null | grep -oP "Qt version \K[\d.]+")
    log_info "Qt 已安装: $qt_version"
  else
    log_warn "未找到 qmake"
    success=false
  fi

  # 检查 Qt Creator
  if [ -f "$QT_INSTALL_DIR/Tools/QtCreator/bin/qtcreator" ]; then
    log_info "Qt Creator 已安装"
  else
    log_warn "未找到 Qt Creator"
    success=false
  fi

  if [ "$success" = true ]; then
    return 0
  else
    return 1
  fi
}

# 显示安装信息
show_qt_info() {
  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "                    🎨 Qt 开发环境配置"
  echo "═══════════════════════════════════════════════════════════════"
  echo ""

  echo "【安装信息】"
  echo "  安装目录: $QT_INSTALL_DIR"
  echo "  镜像源: $QT_MIRROR"
  echo ""

  if [ -d "$QT_INSTALL_DIR"/6.*/gcc_64 ]; then
    local qt_version=$(ls "$QT_INSTALL_DIR" | grep "^6\." | head -1)
    echo "【Qt 版本】"
    echo "  Qt $qt_version"
    echo ""
    echo "【编译器】"
    echo "  Desktop gcc_64"
    echo ""
    echo "【环境变量】"
    echo "  Qt SDK: $QT_INSTALL_DIR/$qt_version/gcc_64/bin"
    [ -d "$QT_INSTALL_DIR/Tools/CMake/bin" ] && echo "  CMake: $QT_INSTALL_DIR/Tools/CMake/bin"
    [ -d "$QT_INSTALL_DIR/Tools/Ninja/bin" ] && echo "  Ninja: $QT_INSTALL_DIR/Tools/Ninja/bin"
    echo ""
    echo "【创建项目】"
    echo "  mkdir ~/qt-projects && cd ~/qt-projects"
    echo "  qt-cmake -G Ninja -B build -S ."
    echo "  cmake --build build"
    echo ""
  fi

  echo "【Qt Creator】"
  if [ -f "$QT_INSTALL_DIR/Tools/QtCreator/bin/qtcreator" ]; then
    echo "  启动命令: $QT_INSTALL_DIR/Tools/QtCreator/bin/qtcreator"
    echo "  桌面快捷方式: 应用菜单 → Qt Creator"
  else
    echo "  未安装"
  fi
  echo ""

  echo "【学习资源】"
  echo "  官方文档: https://doc.qt.io/qt-6/"
  echo "  中文教程: https://www.qter.org/"
  echo "  示例代码: $QT_INSTALL_DIR/Examples/"
  echo ""

  echo "═══════════════════════════════════════════════════════════════"
  echo ""
}

# 主流程
main() {
  log_info "开始安装 Qt $QT_VERSION LTS..."

  # 检查磁盘空间
  if ! check_disk_space; then
    log_warn "磁盘空间不足，建议清理后重试"
    echo ""
    read -p "是否继续安装？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      log_info "跳过 Qt 安装"
      return 0
    fi
  fi

  # 检查现有安装
  if ! check_existing_qt; then
    log_info "Qt 阶段完成（跳过安装）"
    return 0
  fi

  # 安装依赖
  install_qt_deps

  # 下载安装器
  if ! download_qt_installer; then
    log_error "安装器下载失败"
    show_manual_install_guide
    return 1
  fi

  # 生成自动安装脚本
  generate_install_script

  # 运行安装器
  log_info "正在安装 Qt，请稍候..."
  log_warn "安装过程可能需要 10-30 分钟，取决于网络速度"

  # 尝试自动安装
  if run_qt_installer "$QT_INSTALLER_PATH" "$QT_INSTALL_SCRIPT_PATH"; then
    log_info "Qt 安装完成"
  else
    log_warn "自动安装失败，请手动安装"
    show_manual_install_guide

    # 清理临时文件
    rm -rf /tmp/qt-installer
    return 1
  fi

  # 配置环境变量
  setup_qt_env

  # 验证安装
  verify_qt_install

  # 显示信息
  show_qt_info

  # 清理临时文件
  rm -rf /tmp/qt-installer

  log_info "Qt 开发环境安装完成"
}

main
