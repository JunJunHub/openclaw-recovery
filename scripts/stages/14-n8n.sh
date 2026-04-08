#!/bin/bash
# 阶段 14: N8N 工作流自动化平台

log_info "=== 阶段 14: N8N 安装 ==="

# 配置
N8N_IMAGE="n8nio/n8n:latest"
N8N_PORT=5678
N8N_DATA_DIR="$HOME/.n8n"
N8N_CONTAINER_NAME="n8n"

# 检查 Docker 是否可用
check_docker() {
  if ! command_exists docker; then
    log_error "Docker 未安装，请先运行: ./scripts/install.sh --stage docker"
    return 1
  fi

  if ! docker info &>/dev/null; then
    log_error "Docker 服务未运行或当前用户无权限"
    log_info "请执行: newgrp docker 或重新登录"
    return 1
  fi

  return 0
}

# 检查 N8N 容器是否已存在
check_n8n_container() {
  if docker ps -a --format '{{.Names}}' | grep -q "^${N8N_CONTAINER_NAME}$"; then
    log_info "N8N 容器已存在"

    # 检查是否运行中
    if docker ps --format '{{.Names}}' | grep -q "^${N8N_CONTAINER_NAME}$"; then
      log_info "N8N 容器运行中，端口: $(docker port $N8N_CONTAINER_NAME 5678 | cut -d: -f1)"
      return 0
    else
      log_warn "N8N 容器已停止"
      return 1
    fi
  fi
  return 1
}

# 拉取 N8N 镜像
pull_n8n_image() {
  log_step "拉取 N8N 镜像..."

  # 检查镜像是否已存在
  if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^${N8N_IMAGE}$"; then
    log_info "N8N 镜像已存在: $N8N_IMAGE"
    return 0
  fi

  log_info "正在拉取 $N8N_IMAGE（约 2GB，请耐心等待）..."

  if docker pull "$N8N_IMAGE"; then
    log_info "N8N 镜像拉取成功"
  else
    log_error "N8N 镜像拉取失败"
    log_info "请检查网络连接或配置 Docker 镜像加速"
    return 1
  fi
}

# 创建数据目录
create_data_dir() {
  log_step "创建 N8N 数据目录..."

  mkdir -p "$N8N_DATA_DIR"
  log_info "数据目录: $N8N_DATA_DIR"
}

# 启动 N8N 容器
start_n8n_container() {
  log_step "启动 N8N 容器..."

  # 检查是否已有容器
  if docker ps -a --format '{{.Names}}' | grep -q "^${N8N_CONTAINER_NAME}$"; then
    log_info "启动现有容器..."
    docker start "$N8N_CONTAINER_NAME"
    return $?
  fi

  # 创建新容器
  docker run -d \
    --name "$N8N_CONTAINER_NAME" \
    --restart unless-stopped \
    -p ${N8N_PORT}:${N8N_PORT} \
    -e TZ=Asia/Shanghai \
    -e N8N_HOST=0.0.0.0 \
    -e N8N_PORT=${N8N_PORT} \
    -e N8N_PROTOCOL=http \
    -e GENERIC_TIMEZONE=Asia/Shanghai \
    -v "${N8N_DATA_DIR}:/home/node/.n8n" \
    "$N8N_IMAGE"

  if [ $? -eq 0 ]; then
    log_info "N8N 容器启动成功"
  else
    log_error "N8N 容器启动失败"
    return 1
  fi
}

# 等待 N8N 启动
wait_for_n8n() {
  log_step "等待 N8N 启动..."

  local max_wait=60
  local waited=0

  while [ $waited -lt $max_wait ]; do
    if curl -s -o /dev/null -w "%{http_code}" "http://localhost:${N8N_PORT}" | grep -q "200"; then
      log_info "N8N 启动成功"
      return 0
    fi

    sleep 2
    waited=$((waited + 2))
    echo -n "."
  done

  echo ""
  log_warn "N8N 启动超时，请手动检查: docker logs n8n"
  return 1
}

# 创建工作流目录
create_workflow_dir() {
  log_step "创建工作流目录..."

  local workflow_dir="$HOME/.openclaw/workspace/n8n-workflows"
  mkdir -p "$workflow_dir"

  # 创建示例工作流
  local example_workflow="$workflow_dir/example-workflow.json"
  if [ ! -f "$example_workflow" ]; then
    cat > "$example_workflow" << 'EOF'
{
  "name": "示例工作流 - HTTP 请求",
  "nodes": [
    {
      "parameters": {},
      "name": "手动触发",
      "type": "n8n-nodes-base.manualTrigger",
      "position": [0, 0]
    },
    {
      "parameters": {
        "url": "https://api.github.com/zen",
        "options": {}
      },
      "name": "HTTP 请求",
      "type": "n8n-nodes-base.httpRequest",
      "position": [200, 0]
    }
  ],
  "connections": {
    "手动触发": {
      "main": [[{"node": "HTTP 请求", "type": "main", "index": 0}]]
    }
  }
}
EOF
    log_info "已创建示例工作流: $example_workflow"
  fi
}

# 显示使用提示
show_usage_tips() {
  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "                    🔄 N8N 使用提示"
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
  echo "【访问地址】"
  echo "  http://localhost:${N8N_PORT}"
  echo ""
  echo "【常用命令】"
  echo "  docker logs n8n              # 查看日志"
  echo "  docker stop n8n              # 停止容器"
  echo "  docker start n8n             # 启动容器"
  echo "  docker restart n8n           # 重启容器"
  echo "  docker rm n8n                # 删除容器"
  echo ""
  echo "【数据目录】"
  echo "  $N8N_DATA_DIR"
  echo "  ├── config                   # 配置文件"
  echo "  ├── database.sqlite          # 数据库"
  echo "  └── .ssh/                    # SSH 密钥"
  echo ""
  echo "【工作流目录】"
  echo "  $HOME/.openclaw/workspace/n8n-workflows"
  echo ""
  echo "【与 OpenClaw 集成】"
  echo "  - 通过 HTTP API 调用 OpenClaw"
  echo "  - 通过共享文件系统交换数据"
  echo "  - 通过飞书/Telegram 消息触发"
  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
}

# 主流程
main() {
  # 检查 Docker
  if ! check_docker; then
    log_error "请先安装并启动 Docker"
    exit 1
  fi

  # 检查现有容器
  if check_n8n_container; then
    show_usage_tips
    exit 0
  fi

  # 执行安装步骤
  pull_n8n_image || exit 1
  create_data_dir
  start_n8n_container || exit 1
  wait_for_n8n
  create_workflow_dir

  show_usage_tips

  log_info "N8N 安装完成"
}

main
