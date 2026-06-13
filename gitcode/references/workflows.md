# GitCode Workflows

## 1. Issue 生命周期

```
创建 Issue → 分析需求 → 实现代码 → 创建 PR → Review → Merge → Close Issue
```

### 创建 Issue
- `POST /api/v5/repos/{owner}/{repo}/issues`
- 使用 Conventional Commits 风格的标题
- 标签: bug, enhancement, documentation, question

### 关闭 Issue
- 关联 PR 合并后自动关闭
- 手动: `PUT /api/v5/repos/{owner}/{repo}/issues/{number}` with `{"state_event": "close"}`

## 2. PR 生命周期

```
创建分支 → Push → 创建 PR → Review → 修改 → Approve → Merge
```

### 分支命名
- feature: `feat/short-description`
- bugfix: `fix/short-description`
- docs: `docs/short-description`
- release: `release/vX.Y.Z`

### PR 标题（Conventional Commits）
- `feat: add feature X`
- `fix: resolve issue Y`
- `docs: update README`
- `refactor: simplify module Z`
- `release: vX.Y.Z`

### Code Review
1. `GET /repos/{owner}/{repo}/pulls/{number}/files` 查看变更
2. 每个发现分类:
   - **Block**: 必须修改才允许合并
   - **Suggest**: 建议修改，不阻塞
   - **Optional**: 可选优化
3. `POST /repos/{owner}/{repo}/pulls/{number}/reviews` 提交 review

## 3. Release 流程

```
更新版本号 → Build/Test → 创建 Tag → 创建 Release → 推送
```

1. 更新 csproj/nuspec 版本号
2. `dotnet build && dotnet test`
3. `POST /api/v5/repos/{owner}/{repo}/releases`
4. 同时推送到 Gitee/GitHub（由 gitee/github skill 处理）

## 4. 多仓库同步

GitCode 作为国内镜像，与 GitHub/Gitee 保持同步:

```
GitHub (主仓库) → Gitee (镜像) → GitCode (镜像)
```

- 每次 push GitHub 后，gitee skill 同步到 Gitee
- GitCode 仓库可使用 mirror 功能自动同步，或通过 gitcode skill 手动推送

## 5. 日常检查

```
GET /api/v5/user/repos → 仓库列表
GET /repos/{owner}/{repo}/pulls?state=opened → 待处理 PRs
GET /repos/{owner}/{repo}/issues?state=opened → 待处理 Issues
```
