# GitCode Workspace Setup

## 1. 获取 Token

1. 登录 https://gitcode.com
2. 进入 Settings → Access Tokens: https://gitcode.com/-/user_settings/personal_access_tokens
3. 创建 token，选择 scopes: `api`, `read_repository`, `write_repository`
4. 复制 token，只显示一次

## 2. 设置环境变量

添加到 `~/.claude/settings.local.json`:

```json
{
  "env": {
    "GITCODE_TOKEN": "your-token-here"
  }
}
```

或系统环境变量:
```powershell
$env:GITCODE_TOKEN = "your-token-here"
```

## 3. Token 安全

- 不要在代码、日志、commit 中硬编码 token
- 不要在 JSON 输出中打印 token 值
- 如果 token 泄露，立即去 GitCode 页面 revoke 并重新生成
- Token 只在 `.claude/settings.local.json` 或系统环境变量中存在

## 4. 验证连接

Claude 会在首次调用时自动验证 token。如果返回 401，检查:
- Token 是否正确复制（没有多余空格）
- Token 是否过期或被 revoke
- Scope 是否包含 `api`
