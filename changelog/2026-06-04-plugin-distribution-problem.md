# GroundPA Toolkit 插件分发方案评估

Date: 2026-06-04

## 问题背景

GroundPA Toolkit 是纯 .NET 项目（19 个 Claude Code skills），目前通过 Git 仓库分发。普通用户（国内、农学背景）安装时会遇到以下障碍。

## 已验证的安装路径及问题

### 1. GitHub shorthand

```powershell
claude plugin marketplace add angri450/GroundPA-Toolkit
claude plugin install groundpa-toolkit@angri450
```

问题：国内网络连不上 GitHub，且 HTTPS clone 可能触发认证。

### 2. Gitee HTTPS

```powershell
claude plugin marketplace add https://gitee.com/angri450/GroundPA-Toolkit.git
```

问题：Gitee HTTPS clone 在非交互模式下触发用户名/密码认证弹窗，Claude Code 的 clone 过程无法处理交互式认证，直接失败。

### 3. Gitee SSH

SSH URL 形式可以绕过 HTTPS 密码弹窗，但仍然要求用户提前配置 Gitee SSH key。

问题：需要用户提前配置 Gitee SSH key，首次连接还需要写入 known_hosts。对普通用户门槛太高。

### 4. 远程 marketplace.json + npm 源

marketplace 通过 Gitee raw URL 分发（匿名可访问），插件本体通过 npm 安装。

问题：GroundPA Toolkit 是纯 .NET 项目，不应该为 Claude Code 插件分发引入 npm 技术栈。维护 package.json、npm publish 流程与 .NET 工具链不一致，增加维护负担。

### 5. Gitee raw marketplace.json + source: "./"

```powershell
claude plugin marketplace add https://gitee.com/angri450/GroundPA-Toolkit/raw/main/.claude-plugin/marketplace.json
```

问题：Claude Code 的 URL-based marketplace 只下载 marketplace.json 本身，不 clone 仓库。`source: "./"` 指向的相对路径不存在，插件安装时报 path not found。

## 已解决方案：Gitee 一行安装脚本

实现仓库根目录 `install.ps1`：

```powershell
irm https://gitee.com/angri450/GroundPA-Toolkit/raw/main/install.ps1 | iex
```

脚本行为：

```text
1. 从 Gitee archive URL 匿名下载源码 zip，不执行 Git clone。
2. 解压到稳定本地目录 `%LOCALAPPDATA%\GroundPA-Toolkit`。
3. 校验 `.claude-plugin/plugin.json` 和 `.claude-plugin/marketplace.json` 存在。
4. 拒绝覆盖非 GroundPA 目录，避免误删用户文件。
5. 执行 `claude plugin validate <local-dir>`。
6. 移除旧的 `angri450` marketplace 注册。
7. 执行 `claude plugin marketplace add --scope user <local-dir>`。
8. 执行 `claude plugin install --scope user groundpa-toolkit@angri450`。
9. 提示用户重启 Claude Code 或执行 `/reload-plugins`。
```

这个方案保留 `"source": "./"`。区别是 marketplace 已经位于本地完整插件目录中，`./` 可以正确解析，不再依赖 Claude Code clone 远程 Git 仓库。

## 备选方案：本地 zip 安装

用户从 Gitee Release 页面下载 zip，解压到本地，用本地路径添加 marketplace：

```powershell
claude plugin marketplace add <local-groundpa-folder>
claude plugin install groundpa-toolkit@angri450
/reload-plugins
```

优点：不需要 Git 登录、不需要 SSH key、不需要 npm、保留纯 .NET 项目结构。

缺点：用户需要手动下载解压，更新时也要重新下载覆盖。体验不如一行命令。

## 原待解决项

需要实现一键安装脚本，让用户不需要手动下载解压。大致思路：

1. 在仓库根目录提供 `install.ps1`
2. 脚本自动从 Gitee Release 下载最新 zip
3. 解压到固定目录（如 `$env:USERPROFILE\.groundpa-toolkit`）
4. 执行 `claude plugin marketplace remove angri450`（清理旧版）
5. 执行 `claude plugin marketplace add $env:USERPROFILE\.groundpa-toolkit`
6. 执行 `claude plugin install groundpa-toolkit@angri450`
7. 提示用户执行 `/reload-plugins`

用户侧只需一行：

```powershell
irm https://gitee.com/angri450/GroundPA-Toolkit/raw/main/install.ps1 | iex
```

状态：已实现。

## 技术约束

- 纯 .NET 项目，不接受 npm/node 作为分发依赖
- marketplace.json 保持 `"source": "./"`（本地目录/Git-based marketplace 专用）
- 安装入口必须匿名可访问（Gitee raw URL 满足此条件）
- 不支持 OAuth/登录流程，不支持交互式认证
