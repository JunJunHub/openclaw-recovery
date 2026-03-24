# OpenClaw 安装规格

## 📋 目标

安装 OpenClaw，支持选择社区版或原版。

## 🔧 版本选择

| 参数 | 包名 | 说明 |
|------|------|------|
| `cn` (默认) | openclaw-cn@0.1.8-fix.3 | 社区版，国内优化 |
| `original` | openclaw@latest | 原版，功能最新 |

## 🔧 安装脚本

```bash
# 版本配置（在 common.sh 中定义）
OPENCLAW_CN_VERSION="openclaw-cn@0.1.8-fix.3"
OPENCLAW_ORIGINAL_VERSION="openclaw@latest"

install_openclaw() {
    # 使用全局变量 OPENCLAW_PACKAGE（由 --version 参数设置）
    
    # 检查是否已安装
    if command -v openclaw &> /dev/null; then
        log_info "OpenClaw 已安装，询问是否重新安装"
        # ... 交互式确认
    fi
    
    # 使用淘宝镜像
    npm config set registry https://registry.npmmirror.com
    
    # 安装选定的版本
    npm install -g "$OPENCLAW_PACKAGE"
    
    log_success "OpenClaw 安装完成: $(openclaw --version)"
}

init_openclaw_dirs() {
    mkdir -p ~/.openclaw/{agents,browser,cron,credentials,extensions,identity,logs,media,memory,obsidian}
    log_success "目录结构初始化完成"
}
```

## ✅ 验证

```bash
verify_openclaw() {
    command -v openclaw &> /dev/null || { log_error "OpenClaw 未安装"; return 1; }
    openclaw --version
    openclaw doctor
}
```