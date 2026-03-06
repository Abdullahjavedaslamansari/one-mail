# one-mail 快速入门

## 5 分钟上手

### 第 1 步：初始化配置

```bash
bash ~/clawd/skills/one-mail/setup.sh
```

按照提示选择邮箱类型并输入信息。

### 第 2 步：验证配置

```bash
# 查看已配置的账户
bash ~/clawd/skills/one-mail/accounts.sh list
```

### 第 3 步：收取邮件

```bash
# 收取所有账户的邮件
bash ~/clawd/skills/one-mail/fetch.sh

# 只看未读邮件
bash ~/clawd/skills/one-mail/fetch.sh --unread

# 搜索邮件
bash ~/clawd/skills/one-mail/fetch.sh --query "AI"
```

### 第 4 步：发送邮件

```bash
bash ~/clawd/skills/one-mail/send.sh \
  --to "recipient@example.com" \
  --subject "Hello from one-mail" \
  --body "This is a test email"
```

## 常见问题

### Q: 如何配置 Gmail？

A: Gmail 使用 `gog` CLI，需要先配置 OAuth 认证：

```bash
# 如果还没有配置 gog
gog auth login
```

### Q: 如何获取 Outlook Client ID？

A: 需要在 Azure AD 注册应用：

1. 访问 https://portal.azure.com
2. 进入 "Azure Active Directory" > "App registrations"
3. 点击 "New registration"
4. 设置重定向 URI 为 `http://localhost`
5. 添加 API 权限：`Mail.ReadWrite`, `Mail.Send`
6. 创建 Client Secret

### Q: 网易邮箱的应用专用密码在哪里？

A: 登录网易邮箱网页版：

1. 设置 > POP3/SMTP/IMAP
2. 开启 IMAP/SMTP 服务
3. 生成授权码（应用专用密码）

### Q: 如何设置默认账户？

```bash
bash ~/clawd/skills/one-mail/accounts.sh set-default --name gmail
```

### Q: 如何删除账户？

```bash
bash ~/clawd/skills/one-mail/accounts.sh remove --name outlook
```

### Q: 如何测试账户连接？

```bash
bash ~/clawd/skills/one-mail/accounts.sh test --name gmail
```

## 高级技巧

### 1. 使用 jq 过滤邮件

```bash
# 只显示发件人和主题
bash ~/clawd/skills/one-mail/fetch.sh | jq -r '.[] | "\(.from): \(.subject)"'

# 按账户分组
bash ~/clawd/skills/one-mail/fetch.sh | jq 'group_by(.account)'

# 统计未读邮件数
bash ~/clawd/skills/one-mail/fetch.sh --unread | jq 'length'
```

### 2. 定时检查邮件

添加到 crontab：

```bash
# 每小时检查一次
0 * * * * bash ~/clawd/skills/one-mail/fetch.sh --unread | jq -r '.[] | "\(.from): \(.subject)"' | head -5
```

### 3. 集成到 OpenClaw

在 `HEARTBEAT.md` 中添加：

```markdown
# 检查紧急邮件
urgent=$(bash ~/clawd/skills/one-mail/fetch.sh --query "urgent" --unread | jq 'length')
if [ "$urgent" -gt 0 ]; then
    echo "⚠️ 你有 $urgent 封紧急邮件"
fi
```

## 下一步

- 查看 `EXAMPLES.md` 了解更多使用场景
- 查看 `SKILL.md` 了解完整 API 文档
- 查看 `README.md` 了解详细功能说明

## 获取帮助

```bash
# 账户管理帮助
bash ~/clawd/skills/one-mail/accounts.sh help

# 运行测试
bash ~/clawd/skills/one-mail/test.sh
```

## 故障排除

如果遇到问题：

1. 检查依赖：`bash ~/clawd/skills/one-mail/test.sh`
2. 查看配置：`cat ~/.onemail/config.json`
3. 测试连接：`bash ~/clawd/skills/one-mail/accounts.sh test --name <account>`
4. 查看日志：脚本会输出详细的错误信息到 stderr

## 安全提示

- 配置文件权限已设置为 600（仅所有者可读写）
- 不要将 `~/.onemail/credentials.json` 提交到 Git
- 使用应用专用密码，不要使用主密码
- 定期更新 OAuth token

---

🎉 现在你已经掌握了 one-mail 的基本用法！
