# 验证测试规格

## 📋 目标

验证 OpenClaw 安装和配置是否正确。

## 🔧 验证脚本

```bash
#!/bin/bash

verify_all() {
    echo "=== OpenClaw 安装验证 ==="
    node --version  # v24.14.0
    google-chrome --version
    openclaw --version  # 0.1.8-fix.3
    jq empty ~/.openclaw/openclaw.json
    ls ~/.openclaw/workspace*
}
```

## 📊 验证清单

| 检查项 | 期望结果 |
|--------|----------|
| Node.js | v24.14.0 |
| Chrome | 已安装 |
| OpenClaw | 0.1.8-fix.3 |
| 配置文件 | 格式正确 |
| Workspace | 5 个目录 |
