#!/bin/bash
# 阶段 3: Docker 安装

log_info "=== 阶段 3: Docker 安装 ==="

# 配置
DOCKER_MIRROR="https://mirrors.aliyun.com/docker-ce"

# 检查是否已安装 Docker
check_docker_installed() {
  if command_exists docker && docker --version &>/dev/null; then
    log_info "Docker 已安装: $(docker --version | awk '{print $3}' | tr -d ',')"
    return 0
  fi
  return 1
}

# 安装 Docker 依赖
install_dependencies() {
  log_step "安装 Docker 依赖..."

  sudo apt-get update -qq
  sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
}

# 添加 Docker GPG 密钥和软件源
add_docker_repository() {
  log_step "添加 Docker 软件源..."

  # 创建 keyrings 目录
  sudo install -m 0755 -d /etc/apt/keyrings

  # 添加 GPG 密钥（使用阿里云镜像）
  local gpg_url="${DOCKER_MIRROR}/linux/ubuntu/gpg"
  local gpg_file="/etc/apt/keyrings/docker.gpg"

  if [ ! -f "$gpg_file" ]; then
    log_info "下载 Docker GPG 密钥..."
    if curl -fsSL "$gpg_url" | sudo gpg --dearmor -o "$gpg_file" 2>/dev/null; then
      sudo chmod a+r "$gpg_file"
      log_info "GPG 密钥添加成功"
    else
      log_error "GPG 密钥下载失败"
      return 1
    fi
  else
    log_info "GPG 密钥已存在"
  fi

  # 添加软件源
  local arch=$(dpkg --print-architecture)
  local codename=$(. /etc/os-release && echo "$VERSION_CODENAME")
  local repo_file="/etc/apt/sources.list.d/docker.list"

  echo "deb [arch=$arch signed-by=$gpg_file] ${DOCKER_MIRROR}/linux/ubuntu $codename stable" | sudo tee "$repo_file" > /dev/null

  log_info "Docker 软件源添加成功"
}

# 安装 Docker
install_docker() {
  log_step "安装 Docker..."

  sudo apt-get update -qq

  # 安装 Docker CE 及相关组件
  sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

  # 验证安装
  if command_exists docker; then
    log_info "Docker 安装成功: $(docker --version | awk '{print $3}' | tr -d ',')"
    log_info "Docker Compose: $(docker compose version | awk '{print $4}' | tr -d ',')"
  else
    log_error "Docker 安装失败"
    return 1
  fi
}

# 配置用户权限
configure_user_permissions() {
  log_step "配置用户权限..."

  # 将当前用户加入 docker 组
  if groups | grep -q docker; then
    log_info "用户已在 docker 组中"
  else
    sudo usermod -aG docker "$USER"
    log_info "已将用户 $USER 加入 docker 组"
    log_warn "需要重新登录才能生效"
  fi
}

# 配置 Docker 镜像加速
configure_mirror() {
  log_step "配置 Docker 镜像加速..."

  local daemon_json="/etc/docker/daemon.json"
  local backup_json="/etc/docker/daemon.json.bak.$(date +%Y%m%d%H%M%S)"

  # 国内镜像源（支持 IPv4，避免 IPv6 连接问题）
  local mirrors='{
  "registry-mirrors": [
    "https://hub.rat.dev",
    "https://docker.hlyun.org",
    "https://mirror.ccs.tencentyun.com"
  ]
}'

  # 备份现有配置
  if [ -f "$daemon_json" ]; then
    sudo cp "$daemon_json" "$backup_json"
    log_info "已备份现有配置到: $backup_json"
  fi

  # 写入新配置
  echo "$mirrors" | sudo tee "$daemon_json" > /dev/null
  log_info "已配置 Docker 镜像加速"
  log_info "镜像源: hub.rat.dev, docker.hlyun.org, 腾讯云"

  # 重启 Docker 使配置生效
  if systemctl is-active --quiet docker; then
    log_info "重启 Docker 服务使配置生效..."
    sudo systemctl restart docker
    sleep 2
    log_info "Docker 服务已重启"
  fi
}

# 启动 Docker 服务
start_docker_service() {
  log_step "启动 Docker 服务..."

  # 启用并启动 Docker
  sudo systemctl enable docker
  sudo systemctl start docker

  # 等待服务启动
  sleep 2

  # 检查服务状态
  if systemctl is-active --quiet docker; then
    log_info "Docker 服务已启动"
  else
    log_error "Docker 服务启动失败"
    return 1
  fi
}

# 验证 Docker 安装
verify_docker() {
  log_step "验证 Docker 安装..."

  # 测试 Docker 是否正常工作
  if docker run --rm hello-world &>/dev/null; then
    log_info "Docker 运行正常（hello-world 测试通过）"
  else
    log_warn "Docker 测试失败，可能需要重新登录后重试"
    log_info "手动测试命令: docker run --rm hello-world"
  fi
}

# 显示使用提示
show_usage_tips() {
  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "                    🐳 Docker 使用提示"
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
  echo "【常用命令】"
  echo "  docker ps                    # 查看运行中的容器"
  echo "  docker images                # 查看本地镜像"
  echo "  docker compose up -d         # 启动 compose 服务"
  echo "  docker compose down          # 停止 compose 服务"
  echo "  docker system prune -a       # 清理未使用的资源"
  echo ""
  echo "【N8N 快速启动】"
  echo "  docker run -d --name n8n \\"
  echo "    -p 5678:5678 \\"
  echo "    -v ~/.n8n:/home/node/.n8n \\"
  echo "    n8nio/n8n"
  echo ""
  echo "【权限提示】"
  echo "  ⚠️  如果提示权限不足，请执行: newgrp docker"
  echo "  或重新登录终端"
  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
}

# 主流程
main() {
  # 检查是否已安装
  if check_docker_installed; then
    log_info "Docker 已安装，跳过安装步骤"
    read -p "是否重新安装？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      configure_user_permissions
      show_usage_tips
      return 0
    fi
  fi

  # 执行安装步骤
  install_dependencies
  add_docker_repository
  install_docker
  start_docker_service
  configure_user_permissions
  configure_mirror
  verify_docker

  show_usage_tips

  log_info "Docker 安装完成"
}

main
