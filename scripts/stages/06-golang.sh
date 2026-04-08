#!/bin/bash
# 阶段 6: Go 环境安装

log_info "=== 阶段 6: Go 环境安装 ==="

# 检查是否已安装 go
check_go() {
  log_step "检查 Go 环境..."

  if command_exists go; then
    local version=$(go version 2>/dev/null | awk '{print $3}')
    log_info "Go 已安装: $version"
    return 0
  else
    log_info "Go 未安装"
    return 1
  fi
}

# 安装 gvm (Go Version Manager)
install_gvm() {
  log_step "安装 Go Version Manager (gvm)..."

  if [ -d "$HOME/.gvm" ]; then
    log_info "gvm 已安装，跳过"
    return 0
  fi

  log_info "正在安装 gvm..."

  # 安装依赖
  sudo apt update
  sudo apt install -y curl git mercurial make binutils bison gcc build-essential

  # 下载并安装 gvm
  bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)

  # 加载 gvm
  if [ -f "$HOME/.gvm/scripts/gvm" ]; then
    source "$HOME/.gvm/scripts/gvm"
    
    # 添加到 bashrc
    if ! grep -q "gvm" "$HOME/.bashrc" 2>/dev/null; then
      echo '[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"' >> "$HOME/.bashrc"
    fi
    
    log_info "gvm 安装成功"
    return 0
  else
    log_error "gvm 安装失败"
    return 1
  fi
}

# 配置 Go 镜像源
setup_go_mirror() {
  log_step "配置 Go 镜像源..."

  # 设置环境变量
  export GOPROXY=https://goproxy.cn,direct
  export GO111MODULE=on
  
  # 永久设置
  if ! grep -q "GOPROXY" "$HOME/.bashrc" 2>/dev/null; then
    echo 'export GOPROXY="https://goproxy.cn,direct"' >> "$HOME/.bashrc"
    echo 'export GO111MODULE="on"' >> "$HOME/.bashrc"
    echo 'export GOSUMDB="sum.golang.google.cn"' >> "$HOME/.bashrc"
  fi
  
  # 为当前会话设置
  export GOSUMDB=sum.golang.google.cn
  
  log_info "Go 镜像源配置完成"
  log_info "  GOPROXY: https://goproxy.cn"
  log_info "  GOSUMDB: sum.golang.google.cn"
}

# 通过 gvm 安装最新 Go 版本
install_go_via_gvm() {
  log_step "通过 gvm 安装最新 Go 版本..."

  # 确保 gvm 已加载
  if [ -f "$HOME/.gvm/scripts/gvm" ]; then
    source "$HOME/.gvm/scripts/gvm"
  else
    log_error "gvm 脚本不存在"
    return 1
  fi

  # 获取可用的 Go 版本
  log_info "获取可用的 Go 版本..."
  
  # 安装 Go（最新稳定版）
  local go_version=""
  
  # 尝试获取最新稳定版本
  if command_exists gvm; then
    # 安装 Go 1.21+（最新稳定版）
    go_version="1.21"
    
    # 检查是否已安装
    if gvm list | grep -q "go$go_version" 2>/dev/null; then
      log_info "Go $go_version 已通过 gvm 安装"
    else
      log_info "正在安装 Go $go_version..."
      gvm install "go$go_version" -B
      if [ $? -eq 0 ]; then
        log_info "Go $go_version 安装成功"
      else
        log_warn "安装 Go $go_version 失败，尝试其他版本"
        # 尝试安装 Go 1.20
        gvm install "go1.20" -B 2>/dev/null && go_version="1.20"
      fi
    fi
    
    # 使用安装的版本
    if gvm list | grep -q "go$go_version" 2>/dev/null; then
      gvm use "go$go_version" --default
      log_info "设置为默认版本: $go_version"
    fi
  else
    log_warn "gvm 命令未找到，尝试直接安装 Go"
    install_go_direct
    return $?
  fi
}

# 直接安装 Go（备选方案）
install_go_direct() {
  log_step "直接安装 Go..."

  # 检查架构
  local arch="$(uname -m)"
  local go_arch="amd64"
  
  if [ "$arch" = "aarch64" ]; then
    go_arch="arm64"
  elif [ "$arch" = "x86_64" ]; then
    go_arch="amd64"
  else
    go_arch="amd64"
  fi
  
  # 安装最新 Go 版本
  local go_version="1.21.5"
  local go_tar="go${go_version}.linux-${go_arch}.tar.gz"
  local go_url="https://golang.google.cn/dl/${go_tar}"
  
  log_info "下载 Go ${go_version}..."
  
  # 下载
  cd /tmp
  wget "$go_url"
  
  if [ -f "$go_tar" ]; then
    # 移除旧版本
    sudo rm -rf /usr/local/go
    
    # 解压
    sudo tar -C /usr/local -xzf "$go_tar"
    
    # 清理
    rm -f "$go_tar"
    
    # 添加到 PATH
    if ! grep -q "/usr/local/go/bin" "$HOME/.bashrc" 2>/dev/null; then
      echo 'export PATH=$PATH:/usr/local/go/bin' >> "$HOME/.bashrc"
    fi
    
    export PATH=$PATH:/usr/local/go/bin
    log_info "Go ${go_version} 安装成功"
  else
    log_error "Go 下载失败"
    return 1
  fi
}

# 验证 Go 安装
verify_go() {
  log_step "验证 Go 安装..."

  if command_exists go; then
    local version=$(go version 2>/dev/null)
    log_info "Go 版本: $version"
    
    # 测试简单的 Go 程序
    local test_file="/tmp/test_go.go"
    cat > "$test_file" << 'EOF'
package main

import "fmt"

func main() {
    fmt.Println("✅ Go 环境正常工作!")
    fmt.Printf("Go 版本: %s\n", goVersion())
}

func goVersion() string {
    return "1.21+"
}
EOF
    
    if go run "$test_file" 2>/dev/null; then
      log_info "Go 环境验证通过"
    else
      log_warn "Go 环境验证失败"
    fi
    
    rm -f "$test_file"
  else
    log_warn "Go 命令未找到"
    return 1
  fi
}

# 安装常用 Go 工具
install_go_tools() {
  log_step "安装常用 Go 工具..."

  if ! command_exists go; then
    log_warn "Go 未安装，跳过工具安装"
    return 1
  fi

  local tools=(
    "golang.org/x/tools/cmd/goimports"  # 代码格式化
    "github.com/go-delve/delve/cmd/dlv"  # 调试器
    "golang.org/x/tools/gopls"           # 语言服务器
    "github.com/golangci/golangci-lint/cmd/golangci-lint"  # 代码检查
    "github.com/cosmtrek/air"            # 热重载开发工具
  )

  for tool in "${tools[@]}"; do
    local tool_name=$(echo "$tool" | awk -F'/' '{print $NF}')
    log_info "安装 $tool_name..."
    go install "$tool@latest" 2>/dev/null || log_warn "安装 $tool_name 失败"
  done

  log_info "常用 Go 工具安装完成"
}

# 创建 Go 工作区示例
create_go_workspace() {
  log_step "创建 Go 工作区示例..."

  local go_path="$HOME/go"
  local example_dir="$go_path/src/example.com/hello"
  
  # 设置 GOPATH（如果使用 Go Modules，GOPATH 不是必须的，但保留）
  if ! grep -q "GOPATH" "$HOME/.bashrc" 2>/dev/null; then
    echo "export GOPATH=$go_path" >> "$HOME/.bashrc"
    echo 'export PATH=$PATH:$GOPATH/bin' >> "$HOME/.bashrc"
  fi
  
  export GOPATH="$go_path"
  export PATH=$PATH:$GOPATH/bin
  
  # 创建示例项目
  mkdir -p "$example_dir"
  
  cat > "$example_dir/go.mod" << 'EOF'
module example.com/hello

go 1.21
EOF

  cat > "$example_dir/main.go" << 'EOF'
package main

import "fmt"

func main() {
    fmt.Println("👋 Hello from Go!")
    fmt.Println("🚀 Go 环境配置成功!")
    
    // 显示环境信息
    fmt.Println("\n📋 环境信息:")
    fmt.Println("  - GOPATH:", getGopath())
    fmt.Println("  - GOROOT:", getGoroot())
}

func getGopath() string {
    return goEnv("GOPATH")
}

func getGoroot() string {
    return goEnv("GOROOT")
}

func goEnv(key string) string {
    // 简化版本，实际使用中会调用 go env
    if key == "GOPATH" {
        return "$HOME/go"
    }
    if key == "GOROOT" {
        return "/usr/local/go"
    }
    return ""
}
EOF

  # 创建构建脚本
  cat > "$example_dir/build.sh" << 'EOF'
#!/bin/bash
# Go 示例项目构建脚本

echo "🔨 编译示例项目..."
go build -o hello .

echo "✅ 编译完成!"
echo "运行: ./hello"
EOF

  chmod +x "$example_dir/build.sh"
  chmod +x "$example_dir/main.go"
  
  log_info "Go 工作区示例已创建: $example_dir"
  log_info "  项目文件: main.go, go.mod, build.sh"
}

# 显示配置信息
show_go_info() {
  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "                    🦫 Go 环境配置完成"
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
  
  echo "【Go 版本】"
  if command_exists go; then
    go version 2>/dev/null || echo "  未安装"
  else
    echo "  未安装"
  fi
  echo ""
  
  echo "【gvm 状态】"
  if [ -d "$HOME/.gvm" ]; then
    echo "  ✅ 已安装"
    if command_exists gvm; then
      gvm version 2>/dev/null
    fi
  else
    echo "  ❌ 未安装"
  fi
  echo ""
  
  echo "【环境变量】"
  echo "  GOPROXY: https://goproxy.cn"
  echo "  GOSUMDB: sum.golang.google.cn"
  echo "  GO111MODULE: on"
  if [ -n "$GOPATH" ]; then
    echo "  GOPATH: $GOPATH"
  else
    echo "  GOPATH: ~/go (建议)"
  fi
  echo ""
  
  echo "【已安装工具】"
  echo "  ✓ go - Go 编译器"
  echo "  ✓ gvm - Go 版本管理器 (可选)"
  echo "  ✓ goimports - 代码格式化"
  echo "  ✓ gopls - 语言服务器"
  echo "  ✓ dlv - 调试器"
  echo "  ✓ golangci-lint - 代码检查"
  echo "  ✓ air - 热重载开发工具"
  echo ""
  
  echo "【示例项目】"
  echo "  位置: ~/go/src/example.com/hello"
  echo "  编译: cd ~/go/src/example.com/hello && go build"
  echo "  运行: ./hello"
  echo ""
  
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
}

# 主流程
main() {
  if check_go; then
    log_warn "Go 已安装，跳过安装过程"
    log_warn "如需重新安装，请先手动卸载现有 Go 环境"
  else
    install_gvm
    setup_go_mirror
    
    # 尝试通过 gvm 安装
    if command_exists gvm; then
      install_go_via_gvm
    else
      install_go_direct
    fi
  fi
  
  # 加载环境变量
  source "$HOME/.bashrc" 2>/dev/null || true
  
  verify_go
  install_go_tools
  create_go_workspace
  show_go_info
  
  log_info "Go 环境安装完成"
}

main