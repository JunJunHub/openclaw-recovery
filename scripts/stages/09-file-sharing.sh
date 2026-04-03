#!/bin/bash
# 阶段 9: 文件共享配置

log_info "=== 阶段 9: 文件共享配置 ==="

# 挂载点配置
WIN_MOUNT_POINT="/home/$USER/mnt/win"
# 共享目录放在 /home 下，避免家目录权限限制
SHARE_DIR="/home/Share"

# 创建挂载目录
setup_mount_points() {
  log_step "创建挂载目录..."

  # 挂载 Windows 共享文件夹的目录
  sudo mkdir -p "$WIN_MOUNT_POINT"
  sudo chown "$USER:$USER" "$WIN_MOUNT_POINT"
  log_info "创建 Windows 挂载点: $WIN_MOUNT_POINT"

  # 共享给 Windows 的目录（/home 权限 755，Windows 可访问）
  sudo mkdir -p "$SHARE_DIR"
  sudo chown "$USER:$USER" "$SHARE_DIR"
  chmod 777 "$SHARE_DIR"
  log_info "创建共享目录: $SHARE_DIR"
}

# 配置 Samba
setup_samba() {
  log_step "配置 Samba..."

  local smb_conf="/etc/samba/smb.conf"

  # 检查是否已配置
  if grep -q "\[Share\]" "$smb_conf" 2>/dev/null; then
    log_info "Samba 共享已配置，跳过"
    return 0
  fi

  # 创建预览配置
  local temp_conf=$(mktemp)
  cp "$smb_conf" "$temp_conf"
  cat >> "$temp_conf" << EOF

# ===== OpenClaw Recovery 自动配置 =====
[Share]
   path = $SHARE_DIR
   browseable = yes
   read only = no
   create mask = 0777
   directory mask = 0777
   public = yes
   writable = yes
   guest ok = yes
EOF

  # 显示差异
  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "                    📝 Samba 配置变更预览"
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
  echo "将添加以下配置到 /etc/samba/smb.conf:"
  echo ""
  echo "───────────────────────────────────────"
  cat << EOF
[Share]
   path = $SHARE_DIR
   browseable = yes
   read only = no
   create mask = 0777
   directory mask = 0777
   public = yes
   writable = yes
   guest ok = yes
EOF
  echo "───────────────────────────────────────"
  echo ""

  # 确认
  confirm_overwrite "/etc/samba/smb.conf" || {
    rm -f "$temp_conf"
    log_warn "跳过 Samba 配置"
    return 0
  }

  rm -f "$temp_conf"

  # 备份原配置
  sudo cp "$smb_conf" "${smb_conf}.bak"
  log_info "已备份原配置: ${smb_conf}.bak"

  # 添加共享配置
  sudo tee -a "$smb_conf" > /dev/null << EOF

# ===== OpenClaw Recovery 自动配置 =====
[Share]
   path = $SHARE_DIR
   browseable = yes
   read only = no
   create mask = 0777
   directory mask = 0777
   public = yes
   writable = yes
   guest ok = yes
EOF

  log_info "Samba 配置已添加 (路径: $SHARE_DIR)"

  # 重启 Samba 服务
  sudo systemctl restart smbd
  sudo systemctl enable smbd

  log_info "Samba 服务已启动"
}

# 创建 Windows 挂载脚本
create_mount_script() {
  log_step "创建 Windows 挂载脚本..."

  local script_path="$HOME/mount-win.sh"

  cat > "$script_path" << 'EOF'
#!/bin/bash
# 挂载 Windows 共享文件夹
# 用法: ./mount-win.sh <Windows IP> <共享名> [用户名] [密码]
#
# 示例:
#   ./mount-win.sh 192.168.1.100 shared
#   ./mount-win.sh 192.168.1.100 shared myuser mypass

WIN_IP="${1:-192.168.1.100}"
SHARE_NAME="${2:-shared}"
WIN_USER="${3:-guest}"
WIN_PASS="${4:-}"

MOUNT_POINT="/home/$USER/mnt/win"

echo "挂载 Windows 共享: //$WIN_IP/$SHARE_NAME"
echo "挂载点: $MOUNT_POINT"

if [ -z "$WIN_PASS" ]; then
  # guest 模式
  sudo mount -t cifs "//$WIN_IP/$SHARE_NAME" "$MOUNT_POINT" \
    -o guest,uid=1000,gid=1000,iocharset=utf8
else
  # 用户认证模式
  sudo mount -t cifs "//$WIN_IP/$SHARE_NAME" "$MOUNT_POINT" \
    -o username="$WIN_USER",password="$WIN_PASS",uid=1000,gid=1000,iocharset=utf8
fi

if [ $? -eq 0 ]; then
  echo "✅ 挂载成功"
  ls "$MOUNT_POINT"
else
  echo "❌ 挂载失败，请检查:"
  echo "  1. Windows IP 地址是否正确"
  echo "  2. 共享名是否正确"
  echo "  3. Windows 防火墙是否允许"
fi
EOF

  chmod +x "$script_path"
  log_info "挂载脚本已创建: $script_path"
}

# 创建卸载脚本
create_unmount_script() {
  log_step "创建卸载脚本..."

  local script_path="$HOME/unmount-win.sh"

  cat > "$script_path" << 'EOF'
#!/bin/bash
# 卸载 Windows 共享文件夹

MOUNT_POINT="/home/$USER/mnt/win"

echo "卸载: $MOUNT_POINT"
sudo umount "$MOUNT_POINT" 2>/dev/null || sudo umount -l "$MOUNT_POINT"

if [ $? -eq 0 ]; then
  echo "✅ 卸载成功"
else
  echo "⚠️ 可能未挂载或卸载失败"
fi
EOF

  chmod +x "$script_path"
  log_info "卸载脚本已创建: $script_path"
}

# 显示使用说明
show_usage() {
  echo ""
  echo "========================================"
  echo "📁 文件共享配置完成"
  echo "========================================"
  echo ""
  echo "【共享给 Windows】"
  echo "  路径: $SHARE_DIR"
  echo "  访问: \\\\<虚拟机IP>\\Share"
  echo "  示例: \\\\192.168.xxx.xxx\\Share"
  echo ""
  echo "【挂载 Windows 共享】"
  echo "  挂载点: $WIN_MOUNT_POINT"
  echo "  脚本: ~/mount-win.sh"
  echo "  用法: ./mount-win.sh <Windows IP> <共享名> [用户名] [密码]"
  echo ""
  echo "【卸载 Windows 共享】"
  echo "  脚本: ~/unmount-win.sh"
  echo ""
}

# 主流程
main() {
  setup_mount_points
  setup_samba
  create_mount_script
  create_unmount_script
  show_usage

  log_info "文件共享配置完成"
}

main
