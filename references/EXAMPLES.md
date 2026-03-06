# one-mail 使用示例

## 场景 1: 每天早上检查所有邮箱的未读邮件

```bash
# 添加到 crontab
0 8 * * * bash ~/clawd/skills/one-mail/fetch.sh --unread | jq -r '.[] | "[\(.account)] \(.from): \(.subject)"' | head -10
```

输出示例：
```
[gmail] boss@company.com: Weekly Report Due
[outlook] client@example.com: Project Update
[163] friend@163.com: 周末聚会
```

## 场景 2: 搜索所有账户中的重要邮件

```bash
# 搜索包含 "urgent" 或 "important" 的邮件
bash ~/clawd/skills/one-mail/fetch.sh --query "urgent OR important" | \
  jq -r '.[] | "\(.date | split("T")[0]) [\(.account)] \(.from): \(.subject)"'
```

## 场景 3: 自动回复特定邮件

```bash
# 回复最新的包含 "meeting" 的邮件
latest_meeting=$(bash ~/clawd/skills/one-mail/fetch.sh --query "meeting" --limit 1 | jq -r '.[0]')

if [ "$latest_meeting" != "null" ]; then
    from=$(echo "$latest_meeting" | jq -r '.from')
    subject=$(echo "$latest_meeting" | jq -r '.subject')
    
    bash ~/clawd/skills/one-mail/send.sh \
        --to "$from" \
        --subject "Re: $subject" \
        --body "Thanks for your email. I'll review the meeting details and get back to you soon."
fi
```

## 场景 4: 发送带附件的报告

```bash
# 生成报告
echo "Weekly Report" > /tmp/report.txt
echo "- Task 1: Completed" >> /tmp/report.txt
echo "- Task 2: In Progress" >> /tmp/report.txt

# 发送报告
bash ~/clawd/skills/one-mail/send.sh \
    --account gmail \
    --to "boss@company.com" \
    --subject "Weekly Report - $(date +%Y-%m-%d)" \
    --body "Please find attached this week's report." \
    --attach "/tmp/report.txt"
```

## 场景 5: 跨账户邮件统计

```bash
# 统计每个账户的未读邮件数
bash ~/clawd/skills/one-mail/fetch.sh --unread | \
  jq -r 'group_by(.account) | .[] | "\(.[0].account): \(length) unread"'
```

输出示例：
```
gmail: 15 unread
outlook: 3 unread
163: 7 unread
```

## 场景 6: 邮件备份

```bash
# 备份最近 100 封邮件到 JSON 文件
bash ~/clawd/skills/one-mail/fetch.sh --limit 100 > ~/backups/emails-$(date +%Y%m%d).json

# 压缩备份
gzip ~/backups/emails-$(date +%Y%m%d).json
```

## 场景 7: 智能邮件分类

```bash
# 按发件人域名分类
bash ~/clawd/skills/one-mail/fetch.sh --limit 50 | \
  jq -r '.[] | .from' | \
  sed 's/.*@//' | \
  sort | uniq -c | sort -rn | head -10
```

输出示例：
```
  15 company.com
   8 gmail.com
   5 163.com
   3 outlook.com
```

## 场景 8: 邮件提醒脚本

```bash
#!/bin/bash
# email-reminder.sh

# 检查是否有紧急邮件
urgent_count=$(bash ~/clawd/skills/one-mail/fetch.sh --query "urgent" --unread | jq 'length')

if [ "$urgent_count" -gt 0 ]; then
    # 发送通知（macOS）
    osascript -e "display notification \"You have $urgent_count urgent emails\" with title \"Email Alert\""
    
    # 或者发送到飞书
    # message send --channel feishu --target "your_user_id" --message "⚠️ 你有 $urgent_count 封紧急邮件"
fi
```

## 场景 9: 邮件转发

```bash
# 将 Gmail 中的特定邮件转发到 Outlook
bash ~/clawd/skills/one-mail/fetch.sh --account gmail --query "project X" --limit 1 | \
  jq -r '.[0] | "\(.subject)\n\n\(.snippet)"' | \
  bash ~/clawd/skills/one-mail/send.sh \
    --account outlook \
    --to "team@company.com" \
    --subject "FWD: Project X Update" \
    --body "$(cat -)"
```

## 场景 10: 邮件摘要报告

```bash
#!/bin/bash
# email-summary.sh

# 生成今天的邮件摘要
today=$(date +%Y-%m-%d)

summary=$(bash ~/clawd/skills/one-mail/fetch.sh --limit 50 | \
  jq -r --arg today "$today" '
    [.[] | select(.date | startswith($today))] |
    "📧 今日邮件摘要 (\(length) 封)\n\n" +
    (group_by(.account) | .[] | 
      "[\(.[0].account)] \(length) 封:\n" +
      ([.[] | "  • \(.from): \(.subject)"] | join("\n"))
    ) | join("\n\n")
  ')

echo "$summary"

# 发送摘要到飞书
# message send --channel feishu --target "your_user_id" --message "$summary"
```

## 场景 11: 自动归档旧邮件

```bash
# 获取 30 天前的邮件并标记为已读（Gmail）
cutoff_date=$(date -v-30d +%Y-%m-%d)

bash ~/clawd/skills/one-mail/fetch.sh --account gmail --limit 100 | \
  jq -r --arg cutoff "$cutoff_date" '.[] | select(.date < $cutoff) | .id' | \
  while read -r email_id; do
    # 使用 gog 标记为已读
    gog gmail modify "$email_id" --remove-label UNREAD
  done
```

## 场景 12: 邮件关键词监控

```bash
#!/bin/bash
# email-monitor.sh

keywords=("invoice" "payment" "urgent" "deadline")

for keyword in "${keywords[@]}"; do
    count=$(bash ~/clawd/skills/one-mail/fetch.sh --query "$keyword" --unread | jq 'length')
    
    if [ "$count" -gt 0 ]; then
        echo "⚠️ 发现 $count 封包含 '$keyword' 的未读邮件"
        
        # 显示详情
        bash ~/clawd/skills/one-mail/fetch.sh --query "$keyword" --unread | \
          jq -r '.[] | "  • [\(.account)] \(.from): \(.subject)"'
    fi
done
```

## 集成到 OpenClaw

在 `HEARTBEAT.md` 中添加：

```markdown
# 每 2 小时检查一次邮件
if [ $(($(date +%H) % 2)) -eq 0 ]; then
    urgent=$(bash ~/clawd/skills/one-mail/fetch.sh --query "urgent" --unread | jq 'length')
    
    if [ "$urgent" -gt 0 ]; then
        echo "⚠️ 你有 $urgent 封紧急邮件需要处理"
    fi
fi
```

## 提示

1. **性能优化**：使用 `--limit` 参数限制返回数量
2. **错误处理**：检查命令返回值和 JSON 输出
3. **安全性**：不要在脚本中硬编码密码
4. **日志记录**：重定向错误输出到日志文件
5. **定时任务**：使用 cron 或 OpenClaw 的定时功能

## 更多示例

查看 `SKILL.md` 了解完整的 API 文档和参数说明。
