# 文件共享配置规格

## 概述

配置虚拟机与 Windows 主机之间的文件共享。

## 安装工具

| 包名 | 用途 |
|------|------|
| cifs-utils | 挂载 Windows 共享文件夹 (SMB/CIFS) |
| samba | 共享虚拟机文件夹给 Windows |
| samba-common-bin | Samba 管理工具 |

## 目录结构

| 路径 | 用途 |
|------|------|
| `/home/mnt/win` | Windows 共享文件夹挂载点 |
| `/home/Share` | 共享给 Windows 的文件夹 |

## Samba 配置

```ini
[Share]
   path = /home/Share
   browseable = yes
   read only = no
   create mask = 0777
   directory mask = 0777
   public = yes
   writable = yes
   guest ok = yes
```

## 使用方式

### 共享给 Windows
```bash
# Windows 访问
\\<虚拟机IP>\Share
```

### 挂载 Windows 共享
```bash
# 创建挂载脚本
~/mount-win.sh <Windows IP> <共享名> [用户名] [密码]

# 示例
~/mount-win.sh 192.168.1.100 shared
~/mount-win.sh 192.168.1.100 shared myuser mypass
```

## 验证

```bash
# 检查 Samba 状态
sudo systemctl status smbd

# 测试挂载
mount | grep cifs
```
