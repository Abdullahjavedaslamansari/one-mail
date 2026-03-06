# one-mail Skill - 项目总结

## 📦 项目结构

```
~/clawd/skills/one-mail/
├── SKILL.md          # Skill 定义和使用说明
├── README.md         # 详细文档
├── QUICKSTART.md     # 快速入门指南
├── EXAMPLES.md       # 使用示例集合
├── setup.sh          # 初始化配置脚本
├── fetch.sh          # 收取邮件脚本
├── send.sh           # 发送邮件脚本
├── accounts.sh       # 账户管理脚本
├── test.sh           # 功能测试脚本
└── lib/              # 适配器库
    ├── common.sh     # 公共函数
    ├── gmail.sh      # Gmail 适配器
    ├── outlook.sh    # Outlook 适配器
    └── 163.sh        # 网易邮箱适配器
```

## ✨ 核心功能

### 1. 多账户管理
- 支持 Gmail、Outlook、网易邮箱
- 统一配置文件（`~/.onemail/config.json`）
- 安全凭证存储（`~/.onemail/credentials.json`，600 权限）
- 默认账户设置

### 2. 邮件收取
- 跨账户统一收取
- 未读邮件过滤
- 关键词搜索
- 数量限制
- JSON 格式输出

### 3. 邮件发送
- 指定账户发送
- 支持抄送/密送
- 附件支持
- 回复功能

### 4. 账户操作
- 列出所有账户
- 添加/删除账户
- 设置默认账户
- 测试账户连接

## 🔧 技术实现

### Gmail
- **工具**：`gog` CLI
- **认证**：OAuth 2.0（已配置）
- **功能**：完整支持（收发、附件、搜索）

### Outlook
- **工具**：Microsoft Graph API
- **认证**：OAuth 2.0（需要 Azure AD 应用）
- **功能**：收发支持，附件待实现

### 网易邮箱
- **工具**：Python imaplib + smtplib
- **认证**：应用专用密码
- **功能**：完整支持（IMAP/SMTP）

## 📊 输出格式

统一 JSON 格式：

```json
[
  {
    "id": "msg_123",
    "account": "gmail",
    "from": "sender@example.com",
    "to": "you@gmail.com",
    "subject": "Meeting tomorrow",
    "date": "2026-03-07T10:30:00Z",
    "unread": true,
    "has_attachments": false,
    "snippet": "Let's meet at 3pm..."
  }
]
```

## 🎯 使用场景

1. **每日邮件检查**：定时收取所有账户的未读邮件
2. **跨账户搜索**：搜索所有账户中的重要邮件
3. **自动回复**：根据关键词自动回复邮件
4. **邮件统计**：统计各账户的邮件数量
5. **邮件备份**：定期备份邮件到 JSON 文件
6. **邮件转发**：在不同账户间转发邮件
7. **邮件监控**：监控特定关键词的邮件
8. **邮件摘要**：生成每日邮件摘要报告

## 🔐 安全性

- 配置文件权限：600（仅所有者可读写）
- OAuth 2.0 认证（Gmail、Outlook）
- 应用专用密码（网易邮箱）
- 不在日志中显示敏感信息
- 支持 macOS Keychain（可选）

## 📝 依赖

- `bash` 4.0+
- `jq` - JSON 处理
- `curl` - HTTP 请求
- `openssl` - SSL/TLS 连接
- `python3` - IMAP/SMTP 处理（网易邮箱）
- `gog` - Gmail 操作（可选）

## 🚀 快速开始

```bash
# 1. 初始化配置
bash ~/clawd/skills/one-mail/setup.sh

# 2. 收取邮件
bash ~/clawd/skills/one-mail/fetch.sh --unread

# 3. 发送邮件
bash ~/clawd/skills/one-mail/send.sh \
  --to "recipient@example.com" \
  --subject "Hello" \
  --body "Content"
```

## 📚 文档

- **SKILL.md**：Skill 定义和 API 文档
- **README.md**：详细功能说明和配置指南
- **QUICKSTART.md**：5 分钟快速入门
- **EXAMPLES.md**：12 个实用场景示例

## ✅ 测试

```bash
bash ~/clawd/skills/one-mail/test.sh
```

测试内容：
- 依赖检查
- 配置文件验证
- 账户列表功能
- 邮件收取功能
- JSON 格式验证

## 🔄 集成到 OpenClaw

### 在 HEARTBEAT.md 中添加：

```markdown
# 每 2 小时检查一次邮件
if [ $(($(date +%H) % 2)) -eq 0 ]; then
    urgent=$(bash ~/clawd/skills/one-mail/fetch.sh --query "urgent" --unread | jq 'length')
    
    if [ "$urgent" -gt 0 ]; then
        echo "⚠️ 你有 $urgent 封紧急邮件需要处理"
    fi
fi
```

### 在 crontab 中添加：

```bash
# 每天早上 8 点检查邮件
0 8 * * * bash ~/clawd/skills/one-mail/fetch.sh --unread | jq -r '.[] | "[\(.account)] \(.from): \(.subject)"' | head -10
```

## 🎨 特色功能

1. **统一接口**：不同邮箱服务统一 API
2. **JSON 输出**：便于脚本处理和集成
3. **模块化设计**：适配器模式，易于扩展
4. **错误处理**：详细的错误信息和日志
5. **安全存储**：凭证文件权限保护
6. **灵活配置**：支持多账户和默认账户

## 🔮 未来计划

- [ ] 支持更多邮箱服务（QQ 邮箱、Hotmail 等）
- [ ] Outlook 附件功能完善
- [ ] HTML 邮件支持
- [ ] 邮件模板功能
- [ ] 邮件规则和过滤器
- [ ] 邮件标签和分类
- [ ] 邮件搜索优化
- [ ] 性能优化和缓存

## 📊 项目统计

- **脚本文件**：9 个
- **文档文件**：4 个
- **代码行数**：约 1000 行
- **支持邮箱**：3 种
- **使用示例**：12 个

## 🎉 总结

one-mail 是一个功能完整、易于使用的统一邮箱管理工具。通过统一的命令行接口，可以轻松管理多个邮箱账户，实现邮件的收发、搜索、过滤等功能。

特别适合：
- 需要管理多个邮箱账户的用户
- 需要自动化邮件处理的场景
- 需要集成到脚本和工作流的需求
- OpenClaw AI 助手的邮件管理功能

---

**创建时间**：2026-03-07  
**创建者**：Dolores (OpenClaw AI Assistant)  
**版本**：1.0.0
