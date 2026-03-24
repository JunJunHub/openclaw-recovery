# Python 工具规格

## 概述

配置 Python 开发环境，包括 pip、uv 包管理器和常用开发工具。

## 安装内容

### 核心组件

| 组件 | 说明 | 来源 |
|------|------|------|
| Python3 | Python 解释器 | 系统包管理器 |
| pip | Python 包管理器 | 系统包管理器 |
| uv | 快速包管理器 | Astral 官方脚本 |

### 开发工具

| 工具 | 用途 |
|------|------|
| black | 代码格式化 |
| flake8 | 代码检查 |
| pytest | 测试框架 |
| jupyter | Jupyter Notebook |
| ipython | 交互式 Python |
| virtualenv | 虚拟环境管理 |
| wheel | 打包工具 |

## 镜像配置

### pip 镜像源
```
https://pypi.tuna.tsinghua.edu.cn/simple
```

### 配置文件位置
```
~/.pip/pip.conf
```

### 配置内容
```ini
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
trusted-host = pypi.tuna.tsinghua.edu.cn
timeout = 120

[install]
trusted-host = pypi.tuna.tsinghua.edu.cn
```

## 安装命令

### Python3 和 pip
```bash
sudo apt update
sudo apt install -y python3 python3-pip python3-venv
```

### 升级 pip
```bash
python3 -m pip install --upgrade pip
```

### 安装 uv
```bash
# 官方安装脚本
curl -LsSf https://astral.sh/uv/install.sh | sh

# 或通过 pip
python3 -m pip install uv
```

### 安装开发工具
```bash
python3 -m pip install \
  black \
  flake8 \
  pytest \
  jupyter \
  ipython \
  virtualenv \
  wheel
```

## uv 工具

### 简介
uv 是 Astral 开发的快速 Python 包管理器，用 Rust 编写，速度比 pip 快 10-100 倍。

### 特点
- 快速依赖解析
- 虚拟环境管理
- 项目管理
- 兼容 pip 命令

### 常用命令
```bash
# 安装包
uv pip install requests

# 创建虚拟环境
uv venv

# 安装项目依赖
uv pip install -r requirements.txt

# 同步项目
uv sync
```

### 镜像配置
```bash
uv config set registry.index-url "https://pypi.tuna.tsinghua.edu.cn/simple"
```

## 虚拟环境

### 创建虚拟环境
```bash
# 使用 venv
python3 -m venv ~/.venv_example

# 使用 uv
uv venv ~/.venv_example
```

### 激活虚拟环境
```bash
source ~/.venv_example/bin/activate
```

### 退出虚拟环境
```bash
deactivate
```

## 验证方法

```bash
# 检查 Python 版本
python3 --version

# 检查 pip 版本
pip3 --version

# 检查 uv 版本
uv --version

# 测试开发工具
black --version
flake8 --version
pytest --version
```

## 目录结构

```
~/.pip/
└── pip.conf              # pip 配置

~/.local/bin/             # 用户安装的工具
├── black
├── flake8
├── pytest
└── ...

~/.venv_example/          # 示例虚拟环境
├── bin/
│   ├── activate
│   ├── python
│   └── pip
└── lib/

~/activate-venv.sh        # 虚拟环境激活脚本
```

## 系统要求

- Ubuntu 22.04 / 24.04
- Python 3.10+ (系统自带)
- 至少 1GB 磁盘空间

## 注意事项

### pip vs uv
- **pip**: 官方标准，稳定可靠
- **uv**: 更快，推荐用于大型项目

### 虚拟环境选择
- **venv**: Python 内置，简单稳定
- **uv venv**: 更快，与 uv 生态集成

### 国内镜像优势
- 下载速度快
- 连接稳定
- 免费使用
