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
| FEISHU_APP_ID | 飞书开放平台 | 可选 |
| FEISHU_APP_SECRET | 飞书开放平台 | 可选 |
| GATEWAY_TOKEN | 自定义生成 | 是 |
