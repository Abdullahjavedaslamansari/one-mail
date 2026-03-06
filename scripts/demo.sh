#!/bin/bash
# one-mail 功能演示脚本

echo "🎬 one-mail 功能演示"
echo "=================="
echo ""

# 检查是否已配置
if [ ! -f "$HOME/.onemail/config.json" ]; then
    echo "⚠️  未检测到配置文件"
    echo ""
    echo "请先运行初始化脚本："
    echo "  bash ~/clawd/skills/one-mail/setup.sh"
    echo ""
    exit 1
fi

# 显示配置的账户
echo "📧 已配置的账户："
echo "----------------"
bash ~/clawd/skills/one-mail/accounts.sh list
echo ""

# 演示 1: 收取邮件
echo "📥 演示 1: 收取最新 5 封邮件"
echo "----------------------------"
echo "命令: bash ~/clawd/skills/one-mail/fetch.sh --limit 5"
echo ""
bash ~/clawd/skills/one-mail/fetch.sh --limit 5 | jq -r '.[] | "[\(.account)] \(.from): \(.subject)"'
echo ""

# 演示 2: 收取未读邮件
echo "📬 演示 2: 收取未读邮件"
echo "----------------------"
echo "命令: bash ~/clawd/skills/one-mail/fetch.sh --unread --limit 5"
echo ""
unread_count=$(bash ~/clawd/skills/one-mail/fetch.sh --unread --limit 5 | jq 'length')
echo "未读邮件数: $unread_count"
echo ""

# 演示 3: 搜索邮件
echo "🔍 演示 3: 搜索包含 'meeting' 的邮件"
echo "------------------------------------"
echo "命令: bash ~/clawd/skills/one-mail/fetch.sh --query 'meeting' --limit 3"
echo ""
bash ~/clawd/skills/one-mail/fetch.sh --query "meeting" --limit 3 | jq -r '.[] | "[\(.account)] \(.date | split("T")[0]) - \(.subject)"'
echo ""

# 演示 4: 邮件统计
echo "📊 演示 4: 邮件统计"
echo "------------------"
echo "命令: bash ~/clawd/skills/one-mail/fetch.sh --limit 50 | jq 'group_by(.account)'"
echo ""
bash ~/clawd/skills/one-mail/fetch.sh --limit 50 | jq -r 'group_by(.account) | .[] | "[\(.[0].account)] \(length) 封邮件"'
echo ""

# 演示 5: 发送邮件（仅显示命令）
echo "📤 演示 5: 发送邮件"
echo "------------------"
echo "命令示例:"
echo "  bash ~/clawd/skills/one-mail/send.sh \\"
echo "    --to 'recipient@example.com' \\"
echo "    --subject 'Hello from one-mail' \\"
echo "    --body 'This is a test email'"
echo ""
echo "（演示模式，不实际发送）"
echo ""

# 演示 6: JSON 处理
echo "🔧 演示 6: 使用 jq 处理邮件数据"
echo "------------------------------"
echo "命令: bash ~/clawd/skills/one-mail/fetch.sh --limit 10 | jq '[.[] | {from, subject}]'"
echo ""
bash ~/clawd/skills/one-mail/fetch.sh --limit 10 | jq '[.[] | {from, subject}] | .[:3]'
echo ""

# 总结
echo "✅ 演示完成！"
echo ""
echo "更多功能："
echo "  • 查看完整文档: cat ~/clawd/skills/one-mail/README.md"
echo "  • 查看使用示例: cat ~/clawd/skills/one-mail/EXAMPLES.md"
echo "  • 快速入门: cat ~/clawd/skills/one-mail/QUICKSTART.md"
echo "  • 账户管理: bash ~/clawd/skills/one-mail/accounts.sh help"
echo ""
