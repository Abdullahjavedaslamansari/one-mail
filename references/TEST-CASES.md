# one-mail Skill 测试用例文档

## 测试环境
- 系统：macOS / Linux
- Shell：bash / zsh
- 依赖：curl, jq, python3, openssl

## 测试分类

### 1. 配置和账户管理测试

#### 1.1 列出所有账户
```bash
bash ~/clawd/skills/one-mail/accounts.sh list
```
**预期结果**：显示所有已配置的邮箱账户

#### 1.2 添加新账户
```bash
bash ~/clawd/skills/one-mail/accounts.sh add
```
**预期结果**：交互式添加账户流程

#### 1.3 删除账户
```bash
bash ~/clawd/skills/one-mail/accounts.sh remove <account_name>
```
**预期结果**：成功删除指定账户

#### 1.4 检查配置文件
```bash
ls -la ~/.onemail/
cat ~/.onemail/config.json | jq '.'
```
**预期结果**：
- config.json 存在且格式正确
- credentials.json 权限为 600

---

### 2. 邮件收取测试

#### 2.1 收取所有账户邮件
```bash
bash ~/clawd/skills/one-mail/fetch.sh --limit 10
```
**预期结果**：返回 JSON 格式的邮件列表

#### 2.2 收取单个账户邮件
```bash
bash ~/clawd/skills/one-mail/fetch.sh --account 163 --limit 5
bash ~/clawd/skills/one-mail/fetch.sh --account outlook --limit 5
bash ~/clawd/skills/one-mail/fetch.sh --account gmail --limit 5
```
**预期结果**：只返回指定账户的邮件

#### 2.3 收取未读邮件
```bash
bash ~/clawd/skills/one-mail/fetch.sh --unread --limit 10
```
**预期结果**：只返回未读邮件（unread: true）

#### 2.4 搜索邮件
```bash
bash ~/clawd/skills/one-mail/fetch.sh --query "测试" --limit 10
```
**预期结果**：返回主题包含"测试"的邮件

#### 2.5 验证 JSON 格式
```bash
bash ~/clawd/skills/one-mail/fetch.sh --limit 1 | grep -v '^\[' | jq '.'
```
**预期结果**：JSON 格式正确，包含必需字段：
- id
- account
- from
- to
- subject
- date
- unread
- has_attachments
- snippet

---

### 3. 邮件发送测试

#### 3.1 发送纯文本邮件
```bash
bash ~/clawd/skills/one-mail/send.sh \
  --to "recipient@example.com" \
  --subject "测试邮件" \
  --body "这是一封测试邮件"
```
**预期结果**：显示"✅ 邮件已发送"

#### 3.2 发送邮件到自己
```bash
FIRST_EMAIL=$(jq -r '.accounts[0].email' ~/.onemail/config.json)
bash ~/clawd/skills/one-mail/send.sh \
  --to "$FIRST_EMAIL" \
  --subject "自测邮件 $(date '+%Y%m%d%H%M%S')" \
  --body "测试邮件发送功能"
```
**预期结果**：
1. 发送成功
2. 等待 5 秒后收取邮件能找到这封邮件

#### 3.3 发送带抄送的邮件
```bash
bash ~/clawd/skills/one-mail/send.sh \
  --to "recipient@example.com" \
  --cc "cc@example.com" \
  --subject "测试抄送" \
  --body "测试 CC 功能"
```
**预期结果**：发送成功

#### 3.4 发送带密送的邮件
```bash
bash ~/clawd/skills/one-mail/send.sh \
  --to "recipient@example.com" \
  --bcc "bcc@example.com" \
  --subject "测试密送" \
  --body "测试 BCC 功能"
```
**预期结果**：发送成功

#### 3.5 指定账户发送
```bash
bash ~/clawd/skills/one-mail/send.sh \
  --account "your@outlook.com" \
  --to "recipient@example.com" \
  --subject "从 Outlook 发送" \
  --body "测试指定账户发送"
```
**预期结果**：从指定账户发送成功

---

### 4. 附件测试

#### 4.1 创建测试附件
```bash
echo "测试附件内容" > /tmp/test-attachment.txt
echo '{"test": true}' > /tmp/test.json
```

#### 4.2 发送带文本附件的邮件
```bash
bash ~/clawd/skills/one-mail/send.sh \
  --to "recipient@example.com" \
  --subject "测试附件 - TXT" \
  --body "请查收附件" \
  --attach "/tmp/test-attachment.txt"
```
**预期结果**：
- 发送成功（或提示附件功能未实现）
- 收件人收到邮件时有附件

#### 4.3 发送带 JSON 附件的邮件
```bash
bash ~/clawd/skills/one-mail/send.sh \
  --to "recipient@example.com" \
  --subject "测试附件 - JSON" \
  --body "请查收 JSON 附件" \
  --attach "/tmp/test.json"
```
**预期结果**：发送成功

#### 4.4 发送多个附件
```bash
bash ~/clawd/skills/one-mail/send.sh \
  --to "recipient@example.com" \
  --subject "测试多个附件" \
  --body "请查收多个附件" \
  --attach "/tmp/test-attachment.txt" \
  --attach "/tmp/test.json"
```
**预期结果**：发送成功（如果支持多附件）

---

### 5. 多账户测试

#### 5.1 从不同账户发送邮件
```bash
# 从第一个账户发送
FIRST_EMAIL=$(jq -r '.accounts[0].email' ~/.onemail/config.json)
bash ~/clawd/skills/one-mail/send.sh \
  --account "$FIRST_EMAIL" \
  --to "test@example.com" \
  --subject "从账户1发送" \
  --body "测试"

# 从第二个账户发送
SECOND_EMAIL=$(jq -r '.accounts[1].email' ~/.onemail/config.json)
bash ~/clawd/skills/one-mail/send.sh \
  --account "$SECOND_EMAIL" \
  --to "test@example.com" \
  --subject "从账户2发送" \
  --body "测试"
```
**预期结果**：两个账户都能成功发送

#### 5.2 收取所有账户邮件并分组
```bash
bash ~/clawd/skills/one-mail/fetch.sh --limit 20 | \
  grep -v '^\[' | \
  jq 'group_by(.account) | map({account: .[0].account, count: length})'
```
**预期结果**：显示每个账户的邮件数量

---

### 6. 统计功能测试

#### 6.1 今日邮件统计
```bash
bash ~/clawd/skills/one-mail/stats.sh --days 1
```
**预期结果**：显示今日邮件统计

#### 6.2 本周邮件统计
```bash
bash ~/clawd/skills/one-mail/stats.sh --days 7
```
**预期结果**：显示本周邮件统计

#### 6.3 JSON 格式统计
```bash
bash ~/clawd/skills/one-mail/stats.sh --days 1 --json
```
**预期结果**：返回 JSON 格式的统计数据

---

### 7. 错误处理测试

#### 7.1 缺少必需参数
```bash
# 缺少收件人
bash ~/clawd/skills/one-mail/send.sh --subject "Test" --body "Test"
# 预期：显示错误"缺少收件人"

# 缺少主题
bash ~/clawd/skills/one-mail/send.sh --to "test@example.com" --body "Test"
# 预期：显示错误"缺少主题"

# 缺少正文
bash ~/clawd/skills/one-mail/send.sh --to "test@example.com" --subject "Test"
# 预期：显示错误"缺少正文"
```

#### 7.2 无效的账户
```bash
bash ~/clawd/skills/one-mail/fetch.sh --account "nonexistent"
```
**预期结果**：显示错误"账户不存在"

#### 7.3 无效的附件路径
```bash
bash ~/clawd/skills/one-mail/send.sh \
  --to "test@example.com" \
  --subject "Test" \
  --body "Test" \
  --attach "/nonexistent/file.txt"
```
**预期结果**：显示错误"文件不存在"

---

### 8. 性能测试

#### 8.1 收取大量邮件
```bash
time bash ~/clawd/skills/one-mail/fetch.sh --limit 50
```
**预期结果**：
- 163 邮箱：< 5 秒
- Outlook：< 3 秒
- Gmail：< 10 秒（gog CLI 较慢）

#### 8.2 发送邮件性能
```bash
time bash ~/clawd/skills/one-mail/send.sh \
  --to "test@example.com" \
  --subject "Performance Test" \
  --body "Test"
```
**预期结果**：< 3 秒

---

### 9. 数据完整性测试

#### 9.1 邮件 ID 唯一性
```bash
bash ~/clawd/skills/one-mail/fetch.sh --limit 50 | \
  grep -v '^\[' | \
  jq -r '.[].id' | \
  sort | \
  uniq -d
```
**预期结果**：无重复 ID（输出为空）

#### 9.2 日期格式验证
```bash
bash ~/clawd/skills/one-mail/fetch.sh --limit 10 | \
  grep -v '^\[' | \
  jq -r '.[].date'
```
**预期结果**：所有日期格式正确

#### 9.3 邮件地址格式验证
```bash
bash ~/clawd/skills/one-mail/fetch.sh --limit 10 | \
  grep -v '^\[' | \
  jq -r '.[].from'
```
**预期结果**：所有邮件地址格式正确

---

### 10. 集成测试

#### 10.1 完整流程测试
```bash
# 1. 发送邮件
UNIQUE_ID=$(date '+%s')
FIRST_EMAIL=$(jq -r '.accounts[0].email' ~/.onemail/config.json)

bash ~/clawd/skills/one-mail/send.sh \
  --to "$FIRST_EMAIL" \
  --subject "Integration Test $UNIQUE_ID" \
  --body "完整流程测试邮件"

# 2. 等待邮件送达
sleep 5

# 3. 收取邮件
bash ~/clawd/skills/one-mail/fetch.sh --limit 20 | \
  grep -v '^\[' | \
  jq ".[] | select(.subject | contains(\"Integration Test $UNIQUE_ID\"))"

# 4. 验证邮件内容
```
**预期结果**：能找到刚才发送的邮件

---

## 自动化测试脚本

运行完整的自动化测试套件：

```bash
bash ~/clawd/skills/one-mail/test-suite.sh
```

**预期结果**：
- 显示每个测试用例的执行结果
- 最后显示测试报告（通过/失败统计）
- 所有核心功能测试通过

---

## 测试检查清单

### 基础功能
- [ ] 账户管理（添加、列表、删除）
- [ ] 邮件收取（所有账户）
- [ ] 邮件收取（单个账户）
- [ ] 邮件发送（纯文本）
- [ ] 邮件发送（带抄送）
- [ ] 邮件发送（带密送）

### 高级功能
- [ ] 附件发送（文本文件）
- [ ] 附件发送（二进制文件）
- [ ] 未读邮件过滤
- [ ] 邮件搜索
- [ ] 邮件统计

### 多账户
- [ ] 163 邮箱收发
- [ ] Outlook 邮箱收发
- [ ] Gmail 邮箱收发
- [ ] 跨账户发送

### 错误处理
- [ ] 缺少必需参数
- [ ] 无效的账户
- [ ] 无效的附件路径
- [ ] 网络错误处理

### 性能
- [ ] 收取邮件性能
- [ ] 发送邮件性能
- [ ] 大量邮件处理

### 数据完整性
- [ ] 邮件 ID 唯一性
- [ ] 日期格式正确
- [ ] 邮件地址格式正确
- [ ] JSON 格式正确

---

## 已知问题

1. ⚠️ 163 邮箱正文预览为空 - 需要进一步调试
2. ⚠️ 统计趋势图 jq 错误 - 需要修复 jq 语法
3. ⏳ 附件功能未完全实现 - 需要实现上传和下载
4. ⚠️ Gmail 收取速度较慢 - gog CLI 性能问题

---

## 测试报告模板

```
测试日期：YYYY-MM-DD
测试人员：XXX
测试环境：macOS / Linux

测试结果：
- 总计：XX 个测试用例
- 通过：XX 个
- 失败：XX 个
- 跳过：XX 个

失败用例：
1. XXX - 原因：XXX
2. XXX - 原因：XXX

建议：
1. XXX
2. XXX
```
