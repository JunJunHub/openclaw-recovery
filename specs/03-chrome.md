# Chrome 浏览器规格

## 概述

安装 Google Chrome 浏览器（.deb 版本），用于浏览器自动化和日常使用。

## 安装方式

- **包类型**: .deb (Debian Package)
- **架构**: amd64 (x86_64)
- **来源**: Google 官方下载服务器

## 安装内容

| 组件 | 说明 |
|------|------|
| google-chrome-stable | Chrome 稳定版主程序 |
| 依赖库 | libxss1, libappindicator1, libindicator7 |

## 下载地址

```
https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
```

## 安装命令

```bash
# 下载 .deb 包
wget -O /tmp/google-chrome-stable_current_amd64.deb \
  "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"

# 安装依赖
sudo apt-get install -y libxss1 libappindicator1 libindicator7

# 安装 Chrome
sudo dpkg -i /tmp/google-chrome-stable_current_amd64.deb || \
  sudo apt-get install -y -f

# 清理
rm -f /tmp/google-chrome-stable_current_amd64.deb
```

## 验证方法

```bash
# 检查安装
google-chrome --version

# 启动 Chrome
google-chrome &

# 无头模式测试
google-chrome --headless --dump-dom https://example.com
```

## Chrome 自动化用途

OpenClaw 使用 Chrome 进行浏览器自动化：

1. **网页内容抓取**: 获取动态渲染的页面
2. **自动化测试**: 网页交互测试
3. **截图生成**: 网页截图功能
4. **表单填写**: 自动化表单提交

## 注意事项

### ⚠️ 避免 Snap 版本

不使用 Snap 版 Chromium 的原因：
- AppArmor 安全限制
- 文件系统访问受限
- 与 OpenClaw 浏览器自动化不兼容

### 推荐配置

```bash
# 禁用自动更新（可选）
sudo apt-mark hold google-chrome-stable

# 查看安装状态
dpkg -l | grep google-chrome
```

## 常见问题

### 依赖问题
```bash
# 修复依赖
sudo apt-get install -f
```

### 启动问题
```bash
# 以无沙箱模式启动（仅用于调试）
google-chrome --no-sandbox
```

## 系统要求

- Ubuntu 22.04 / 24.04
- amd64 (x86_64) 架构
- 至少 4GB 内存（推荐）
- 图形界面环境
