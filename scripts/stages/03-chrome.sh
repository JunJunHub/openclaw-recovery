#!/bin/bash
# 阶段 3: Chrome 浏览器安装 (.deb 版本)

log_step "安装 Google Chrome..."

# 检查是否已安装
if command -v google-chrome &> /dev/null; then
  log_info "Chrome 已安装: $(google-chrome --version)"
  return 0  # 使用 return 而不是 exit，因为是 source 加载
fi

log_info "下载 Google Chrome .deb 包..."

# 下载 Chrome .deb
CHROME_DEB="/tmp/google-chrome-stable_current_amd64.deb"
wget -q --show-progress -O "$CHROME_DEB" \
  "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"

# 安装依赖
log_info "安装依赖..."
sudo apt-get install -y libxss1 libappindicator1 libindicator7

# 安装 Chrome
log_info "安装 Chrome..."
sudo dpkg -i "$CHROME_DEB" || sudo apt-get install -y -f

# 清理
rm -f "$CHROME_DEB"

# 验证
if command -v google-chrome &> /dev/null; then
  log_info "Chrome 安装完成: $(google-chrome --version)"
else
  log_error "Chrome 安装失败"
  exit 1
fi
