---
name: ghproxy
description: >
  Add GitHub acceleration proxy prefix to URLs. Use this skill whenever the user
  mentions that a GitHub link is slow, cannot download from GitHub, needs GitHub
  download acceleration, mentions "ghproxy", "gh-proxy", "github加速", "加速下载",
  or pastes a GitHub URL saying it's not accessible / too slow. Also trigger when
  the user types /ghproxy followed by a URL or pastes any GitHub raw content,
  release, or archive URL that needs a proxy prefix for faster access in
  restricted-network environments.
---

# GitHub 加速链接 (ghproxy)

## 功能

给 GitHub URL（或其他 URL）自动加上 `https://gh-proxy.org/` 加速代理前缀，生成可直接快速下载的加速链接。

## 触发方式

### 1. 斜杠命令 `/ghproxy`

用户输入 `/ghproxy <URL>` 时，直接生成加速链接。

**示例：**
- 输入：`/ghproxy https://github.com/jgm/pandoc/releases/download/3.9.0.2/pandoc-3.9.0.2-windows-x86_64.msi`
- 输出：`https://gh-proxy.org/https://github.com/jgm/pandoc/releases/download/3.9.0.2/pandoc-3.9.0.2-windows-x86_64.msi`

### 2. 自动检测

当用户在对话中提到 GitHub 链接下载慢、打不开、需要加速时，检测对话中的 GitHub URL 并自动生成加速链接。

## 规则

1. 检查 URL 是否已经包含 `gh-proxy.org` 或其他已知代理前缀，避免重复添加
2. 对于多个 URL 的情况，逐个生成加速链接
3. 如果 URL 已包含代理前缀，提示用户该链接已经是加速链接
4. 输出加速链接的同时，可以附带说明：用 `!` 前缀可以运行 `!curl -O <加速链接>` 或 `!wget <加速链接>` 直接下载
