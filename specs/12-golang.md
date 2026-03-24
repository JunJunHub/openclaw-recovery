# Go 环境规格

## 概述

安装 Go 语言开发环境，包括 gvm 版本管理器和常用开发工具。

## 安装内容

### 核心组件

| 组件 | 版本 | 说明 |
|------|------|------|
| gvm | latest | Go Version Manager |
| Go | 1.21+ | Go 编译器 |

### 开发工具

| 工具 | 用途 |
|------|------|
| goimports | 代码格式化 |
| gopls | 语言服务器 (LSP) |
| dlv (Delve) | 调试器 |
| golangci-lint | 代码检查 |
| air | 热重载开发工具 |

## 镜像配置

### Go 模块代理
```
GOPROXY=https://goproxy.cn,direct
```

### 校验和数据库
```
GOSUMDB=sum.golang.google.cn
```

### 环境变量
```bash
export GOPROXY="https://goproxy.cn,direct"
export GO111MODULE="on"
export GOSUMDB="sum.golang.google.cn"
```

## 安装方式

### 方式一：通过 gvm 安装（推荐）

```bash
# 安装依赖
sudo apt install -y curl git mercurial make binutils bison gcc build-essential

# 安装 gvm
bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)

# 加载 gvm
source ~/.gvm/scripts/gvm

# 安装 Go
gvm install go1.21 -B
gvm use go1.21 --default
```

### 方式二：直接安装

```bash
# 下载 Go
wget https://golang.google.cn/dl/go1.21.5.linux-amd64.tar.gz

# 解压安装
sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz

# 配置 PATH
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
```

## gvm 使用说明

### 版本管理

```bash
# 查看已安装版本
gvm list

# 查看可用版本
gvm listall

# 安装特定版本
gvm install go1.20 -B

# 切换版本
gvm use go1.20

# 设置默认版本
gvm use go1.21 --default

# 卸载版本
gvm uninstall go1.19
```

### 安装选项

| 选项 | 说明 |
|------|------|
| -B | 安装预编译二进制（推荐，快速）|
| -s | 从源码编译 |
| --prefer-binary | 优先使用二进制 |

## 开发工具安装

```bash
# 安装常用工具
go install golang.org/x/tools/cmd/goimports@latest
go install github.com/go-delve/delve/cmd/dlv@latest
go install golang.org/x/tools/gopls@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
go install github.com/cosmtrek/air@latest
```

## 项目结构

### Go Modules 项目

```
my-project/
├── go.mod           # 模块定义
├── go.sum           # 依赖校验
├── main.go          # 入口文件
├── cmd/             # 命令行工具
├── pkg/             # 公共库
├── internal/        # 内部代码
└── api/             # API 定义
```

### 初始化项目

```bash
# 创建项目
mkdir my-project && cd my-project

# 初始化模块
go mod init example.com/my-project

# 创建主文件
cat > main.go << 'EOF'
package main

import "fmt"

func main() {
    fmt.Println("Hello, Go!")
}
EOF

# 运行
go run main.go

# 编译
go build
```

## 示例项目

安装脚本会创建示例项目：

```
~/go/src/example.com/hello/
├── go.mod
├── main.go
└── build.sh
```

## 验证方法

```bash
# 检查 Go 版本
go version

# 检查环境配置
go env

# 测试编译
go run ~/go/src/example.com/hello/main.go

# 检查工具
which goimports gopls dlv
```

## 环境变量

| 变量 | 默认值 | 说明 |
|------|------|------|
| GOROOT | /usr/local/go 或 gvm 管理 | Go 安装目录 |
| GOPATH | ~/go | 工作目录 |
| GOPROXY | goproxy.cn | 模块代理 |
| GO111MODULE | on | 模块模式 |
| GOSUMDB | sum.golang.google.cn | 校验和数据库 |

## 常用命令

```bash
# 初始化模块
go mod init <module-name>

# 下载依赖
go mod download

# 整理依赖
go mod tidy

# 运行
go run main.go

# 编译
go build -o myapp

# 测试
go test ./...

# 格式化
go fmt ./...
goimports -w .

# 代码检查
golangci-lint run

# 热重载开发
air
```

## 系统要求

- Ubuntu 22.04 / 24.04
- 至少 2GB 磁盘空间
- gvm 需要编译工具链（可选）

## 注意事项

### gvm vs 直接安装

| 方式 | 优点 | 缺点 |
|------|------|------|
| gvm | 多版本管理 | 需要额外安装 |
| 直接安装 | 简单快速 | 版本固定 |

### 国内镜像优势
- 下载速度快
- 模块解析稳定
- 免费使用

### 环境变量配置
确保将 gvm 和 Go 相关的环境变量添加到 `~/.bashrc`：
```bash
# gvm
[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"

# Go 环境变量
export GOPROXY="https://goproxy.cn,direct"
export GO111MODULE="on"
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"
```
