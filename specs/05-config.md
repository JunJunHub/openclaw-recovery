# 配置恢复规格

## 概述

恢复 openclaw.json 配置文件及处理敏感信息注入。

## 敏感信息处理策略

### 占位符格式

配置模板使用双花括号占位符：

```json
{
  "models": {
    "providers": {
      "siliconflow": {
        "apiKey": "{{SILICONFLOW_API_KEY}}"
      }
    }
  },
  "gateway": {
    "auth": {
      "token": "{{GATEWAY_TOKEN}}"
    }
  }
}
```

### 注入方式

#### 方式1: 环境变量

```bash
export SILICONFLOW_API_KEY="sk-xxx"
export GATEWAY_TOKEN="xxx"
./scripts/install.sh --stage config
```

#### 方式2: .env 文件

```bash
source config/secrets.env
./scripts/install.sh --stage config
```

#### 方式3: 交互式输入

```bash
./scripts/install.sh --stage config --interactive
```

## 配置注入脚本

```bash
#!/bin/bash

inject_secrets() {
  local template="$1"
  local output="$2"
  
  cp "$template" "$output"
  
  # 替换占位符
  sed -i "s|{{SILICONFLOW_API_KEY}}|${SILICONFLOW_API_KEY}|g" "$output"
  sed -i "s|{{BAIDU_QIANFAN_API_KEY}}|${BAIDU_QIANFAN_API_KEY}|g" "$output"
  sed -i "s|{{GATEWAY_TOKEN}}|${GATEWAY_TOKEN}|g" "$output"
  sed -i "s|{{HOME}}|$HOME|g" "$output"
  
  chmod 600 "$output"
}
```

## 敏感信息清单

| 变量名 | 来源 | 必需 |
|--------|------|------|
| SILICONFLOW_API_KEY | SiliconFlow 控制台 | 是 |
| BAIDU_QIANFAN_API_KEY | 百度千帆控制台 | 是 |
| TAVILY_API_KEY | Tavily 控制台 | 推荐 |
| EXA_API_KEY | Exa 控制台 | 可选 |
| FEISHU_APP_ID | 飞书开放平台 | 可选 |
| FEISHU_APP_SECRET | 飞书开放平台 | 可选 |
| GATEWAY_TOKEN | 自定义生成 | 是 |

## Memory Search 配置

### 远程嵌入服务（推荐）

使用 SiliconFlow 的嵌入 API，避免本地模型下载和性能问题：

```json
{
  "memorySearch": {
    "enabled": true,
    "provider": "openai",
    "model": "BAAI/bge-m3",
    "remote": {
      "baseUrl": "https://api.siliconflow.cn/v1",
      "apiKey": "{{SILICONFLOW_API_KEY}}"
    },
    "query": {
      "hybrid": {
        "enabled": true,
        "vectorWeight": 0.7,
        "textWeight": 0.3
      }
    },
    "cache": {"enabled": true}
  }
}
```

### 可用嵌入模型

| 模型 | 最大 Token | 说明 |
|------|-----------|------|
| `BAAI/bge-large-zh-v1.5` | 512 | 中文，短文本 |
| `BAAI/bge-m3` | 8192 | 多语言，推荐 |
| `Qwen/Qwen3-Embedding-8B` | 32768 | 长文本 |

### 配置后操作

配置完成后需要重建索引：

```bash
openclaw gateway restart
openclaw memory index --force
```

## Web Search 配置

### 搜索 Provider 对比

| Provider | 免费额度 | 特点 | 推荐场景 |
|----------|---------|------|---------|
| **Tavily** | 1,000次/月 | AI 优化结果，结构化 | 默认推荐 |
| **Exa** | 1,000次/月 | 神经网络搜索，语义理解 | 备用 |
| **DuckDuckGo** | 无限 | 免费，无需 Key | 测试/备用 |

### 配置示例

```json
{
  "tools": {
    "web": {
      "search": {
        "enabled": true,
        "provider": "tavily"
      }
    }
  },
  "plugins": {
    "entries": {
      "tavily": {
        "enabled": true,
        "config": {
          "webSearch": {
            "apiKey": "{{TAVILY_API_KEY}}"
          }
        }
      },
      "exa": {
        "enabled": true,
        "config": {
          "webSearch": {
            "apiKey": "{{EXA_API_KEY}}"
          }
        }
      }
    }
  }
}
```

### 可用工具

| 工具 | 说明 |
|------|------|
| `web_search` | 通用搜索（自动使用配置的 provider） |
| `tavily_search` | Tavily 专用（支持深度/话题过滤） |
| `tavily_extract` | URL 内容提取 |
| `tavily_search` | Exa 专用（语义搜索） |

### 获取 API Key

- **Tavily**: https://tavily.com（支持国内网络）
- **Exa**: https://exa.ai

### 已弃用：Serper

官方 OpenClaw 不支持 Serper 插件，请使用 Tavily 或 Exa 替代。
