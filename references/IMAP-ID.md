# 网易邮箱 IMAP ID 技术说明

## 问题背景

网易邮箱（163.com、126.com、yeah.net 等）要求 IMAP 客户端在连接时发送 ID 命令来标识客户端信息。如果不发送 ID 命令，可能会导致连接失败或功能受限。

## IMAP ID 命令

IMAP ID 是 RFC 2971 定义的扩展命令，用于客户端和服务器交换身份信息。

### 命令格式

```
ID ("key1" "value1" "key2" "value2" ...)
```

### 网易邮箱要求的字段

- `name` - 客户端名称
- `version` - 客户端版本
- `vendor` - 供应商名称
- `support-email` - 支持邮箱（可选）

## one-mail 的实现

### 1. 扩展 IMAP4_SSL 类

```python
class IMAP4_SSL_ID(imaplib.IMAP4_SSL):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # 添加 ID 命令支持
        imaplib.Commands['ID'] = ('AUTH',)
    
    def id_(self, *args):
        """发送 ID 命令"""
        name = 'ID'
        typ, dat = self._simple_command(name, *args)
        return self._untagged_response(typ, dat, name)
```

### 2. 发送 ID 命令

```python
mail = IMAP4_SSL_ID('imap.163.com')

# 发送 ID 命令
mail.id_('("name" "one-mail" "version" "1.0.1" "vendor" "OpenClaw" "support-email" "support@openclaw.ai")')

# 然后登录
mail.login(email, password)
```

### 3. 错误处理

```python
try:
    mail.id_('("name" "one-mail" "version" "1.0.1" "vendor" "OpenClaw")')
except Exception as e:
    # 如果不支持 ID 命令，记录但继续
    print(f"Warning: ID command failed: {e}", file=sys.stderr)
```

## 测试方法

### 使用测试脚本

```bash
python3 ~/clawd/skills/one-mail/test-163-imap.py your@163.com your_app_password
```

### 手动测试

```python
import imaplib

# 扩展类（见上文）
mail = IMAP4_SSL_ID('imap.163.com')

# 发送 ID
typ, dat = mail.id_('("name" "test" "version" "1.0")')
print(f"ID response: {typ} - {dat}")

# 登录
mail.login('your@163.com', 'your_password')
mail.select('INBOX')

# 搜索邮件
typ, data = mail.search(None, 'ALL')
print(f"Found {len(data[0].split())} emails")

mail.close()
mail.logout()
```

## 常见问题

### Q: 为什么需要 ID 命令？

A: 网易邮箱使用 ID 命令来：
- 识别客户端类型
- 统计客户端使用情况
- 提供针对性的服务
- 防止滥用

### Q: 不发送 ID 会怎样？

A: 可能会：
- 连接被拒绝
- 功能受限
- 性能降低
- 被标记为可疑客户端

### Q: ID 信息会被记录吗？

A: 是的，服务器会记录客户端 ID 信息，但这是正常的协议行为。

### Q: 可以伪造 ID 吗？

A: 技术上可以，但不建议：
- 可能违反服务条款
- 可能被检测和封禁
- 影响服务质量

## 其他邮箱服务

### Gmail
- 不强制要求 ID 命令
- 支持但不是必需的

### Outlook
- 使用 Graph API，不涉及 IMAP ID

### QQ 邮箱
- 类似网易邮箱，可能也需要 ID 命令

## 参考资料

- [RFC 2971 - IMAP4 ID extension](https://tools.ietf.org/html/rfc2971)
- [网易邮箱开发者文档](https://help.mail.163.com/)
- [Python imaplib 文档](https://docs.python.org/3/library/imaplib.html)

## 更新日志

- 2026-03-07: 初始版本，添加 IMAP ID 支持

---

**作者**: Dolores (OpenClaw AI Assistant)  
**版本**: 1.0.1
