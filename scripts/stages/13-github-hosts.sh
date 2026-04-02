#!/bin/bash
# 阶段 13: GitHub Hosts 配置
# 解决国内访问 GitHub 不稳定问题

set -e

log_step "配置 GitHub Hosts..."

# 创建脚本目录
mkdir -p "$HOME/scripts"
mkdir -p "$HOME/logs"
mkdir -p "$HOME/.openclaw/notifications"

# 创建更新脚本
cat > "$HOME/scripts/update-github-hosts.sh" << 'SCRIPT_EOF'
#!/bin/bash
# GitHub Hosts 自动更新脚本
# 通过 DNS 查询获取最新 IP，更新 /etc/hosts

set -e

HOSTS_FILE="/etc/hosts"
LOG_FILE="$HOME/logs/github-hosts.log"
DATE=$(date +%Y-%m-%d)

# 创建日志目录
mkdir -p "$(dirname "$LOG_FILE")"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 获取域名 IP（使用多个 DNS 服务器尝试）
get_ip() {
  local domain=$1
  local ip=""
  
  # 尝试多个 DNS 服务器
  for dns in "8.8.8.8" "1.1.1.1" "114.114.114.114"; do
    ip=$(nslookup "$domain" "$dns" 2>/dev/null | grep -A1 "Name:" | grep "Address" | tail -1 | awk '{print $2}' | head -1)
    if [[ -n "$ip" && "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      echo "$ip"
      return 0
    fi
  done
  
  # 如果所有 DNS 都失败，尝试 dig
  ip=$(dig +short "$domain" A 2>/dev/null | head -1)
  if [[ -n "$ip" && "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "$ip"
    return 0
  fi
  
  return 1
}

log "开始更新 GitHub hosts..."

# 备份原文件
sudo cp "$HOSTS_FILE" "${HOSTS_FILE}.backup.${DATE}" 2>/dev/null || true

# 删除旧的 GitHub 条目（如果存在）
if grep -q "# GitHub Hosts" "$HOSTS_FILE"; then
  sudo sed -i '/# GitHub Hosts/,/# GitHub Hosts End/d' "$HOSTS_FILE"
  log "已删除旧的 GitHub hosts 条目"
fi

# 获取最新 IP
DOMAINS=(
  "github.com"
  "github.global.ssl.fastly.net"
  "codeload.github.com"
  "api.github.com"
  "gist.github.com"
)

NEW_ENTRIES=""
FAILED_DOMAINS=""

for domain in "${DOMAINS[@]}"; do
  ip=$(get_ip "$domain")
  if [[ -n "$ip" ]]; then
    NEW_ENTRIES="${NEW_ENTRIES}${ip} ${domain}\n"
    log "✓ $domain -> $ip"
  else
    FAILED_DOMAINS="${FAILED_DOMAINS}${domain}, "
    log "✗ $domain 解析失败"
  fi
done

if [[ -z "$NEW_ENTRIES" ]]; then
  log "错误：所有域名解析失败，取消更新"
  exit 1
fi

# 添加新条目
{
  echo ""
  echo "# GitHub Hosts ($DATE)"
  echo -e "$NEW_ENTRIES"
  echo "# GitHub Hosts End"
} | sudo tee -a "$HOSTS_FILE" > /dev/null

# 刷新 DNS 缓存
if command -v resolvectl &> /dev/null; then
  sudo resolvectl flush-caches 2>/dev/null || true
elif command -v systemd-resolve &> /dev/null; then
  sudo systemd-resolve --flush-caches 2>/dev/null || true
fi

log "DNS 缓存已刷新"

# 验证更新
if grep -q "# GitHub Hosts ($DATE)" "$HOSTS_FILE"; then
  log "✅ GitHub hosts 更新成功"
  
  # 写入通知文件，由 OpenClaw heartbeat 检测并发送通知
  echo "{\"type\":\"github_hosts_updated\",\"date\":\"$DATE\",\"time\":\"$(date -Iseconds)\"}" > "$HOME/.openclaw/notifications/github-hosts.json"
  
  log "通知已触发"
else
  log "❌ GitHub hosts 更新失败"
  exit 1
fi
SCRIPT_EOF

chmod +x "$HOME/scripts/update-github-hosts.sh"
log_info "已创建更新脚本: ~/scripts/update-github-hosts.sh"

# 获取当前 GitHub IP
log_info "获取 GitHub 最新 IP..."

get_ip() {
  local domain=$1
  for dns in "8.8.8.8" "1.1.1.1" "114.114.114.114"; do
    ip=$(nslookup "$domain" "$dns" 2>/dev/null | grep -A1 "Name:" | grep "Address" | tail -1 | awk '{print $2}' | head -1)
    if [[ -n "$ip" && "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      echo "$ip"
      return 0
    fi
  done
  dig +short "$domain" A 2>/dev/null | head -1
}

GITHUB_IP=$(get_ip "github.com")
FASTLY_IP=$(get_ip "github.global.ssl.fastly.net")
CODELOAD_IP=$(get_ip "codeload.github.com")
API_IP=$(get_ip "api.github.com")

# 检查是否已有 GitHub hosts 条目
if grep -q "# GitHub Hosts" /etc/hosts; then
  log_warn "已有 GitHub hosts 条目，跳过初始配置"
  log_info "可手动运行更新脚本: ~/scripts/update-github-hosts.sh"
else
  # 添加初始 hosts 条目（需要 sudo）
  log_warn "需要 sudo 权限来修改 /etc/hosts"
  log_info "请在终端执行以下命令添加初始 hosts："
  echo ""
  echo "sudo bash -c 'cat >> /etc/hosts << EOF

# GitHub Hosts ($(date +%Y-%m-%d))
${GITHUB_IP:-20.205.243.166} github.com
${FASTLY_IP:-151.101.1.194} github.global.ssl.fastly.net
${CODELOAD_IP:-20.205.243.165} codeload.github.com
${API_IP:-20.205.243.168} api.github.com
# GitHub Hosts End
EOF'"
  echo ""
  echo "sudo resolvectl flush-caches"
  echo ""
fi

# 配置 crontab 定时任务（每周一早上 6 点更新）
CRON_JOB="0 6 * * 1 $HOME/scripts/update-github-hosts.sh >> $HOME/logs/github-hosts.log 2>&1"

if crontab -l 2>/dev/null | grep -q "update-github-hosts.sh"; then
  log_info "已有定时任务，跳过配置"
else
  log_info "配置定时任务（每周一早上 6 点更新）..."
  (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
  log_info "定时任务已配置"
fi

# 验证 crontab
log_info "当前定时任务："
crontab -l 2>/dev/null | grep -v "^#" | grep -v "^$" || log_warn "无定时任务"

log_info "GitHub Hosts 配置完成"
log_info "手动更新命令: ~/scripts/update-github-hosts.sh"
log_info "日志文件: ~/logs/github-hosts.log"
