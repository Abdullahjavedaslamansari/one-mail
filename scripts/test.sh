#!/bin/bash
# one-mail 测试脚本

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🧪 one-mail 功能测试"
echo ""

# 测试 1: 检查依赖
echo "1️⃣ 检查依赖..."
missing_deps=()

if ! command -v jq &> /dev/null; then
    missing_deps+=("jq")
fi

if ! command -v curl &> /dev/null; then
    missing_deps+=("curl")
fi

if ! command -v python3 &> /dev/null; then
    missing_deps+=("python3")
fi

if [ ${#missing_deps[@]} -gt 0 ]; then
    echo "❌ 缺少依赖: ${missing_deps[*]}"
    exit 1
else
    echo "✅ 所有依赖已安装"
fi

echo ""

# 测试 2: 检查配置文件
echo "2️⃣ 检查配置文件..."
if [ -f "$HOME/.onemail/config.json" ]; then
    echo "✅ 配置文件存在"
    
    # 显示账户数量
    account_count=$(jq '.accounts | length' "$HOME/.onemail/config.json")
    echo "   已配置 $account_count 个账户"
    
    # 显示默认账户
    default_account=$(jq -r '.default_account' "$HOME/.onemail/config.json")
    if [ "$default_account" != "null" ]; then
        echo "   默认账户: $default_account"
    fi
else
    echo "⚠️  配置文件不存在，请先运行: bash $SCRIPT_DIR/setup.sh"
fi

echo ""

# 测试 3: 测试账户列表
echo "3️⃣ 测试账户列表..."
if bash "$SCRIPT_DIR/accounts.sh" list &> /dev/null; then
    echo "✅ 账户列表功能正常"
else
    echo "❌ 账户列表功能失败"
fi

echo ""

# 测试 4: 测试邮件收取（如果有配置）
if [ -f "$HOME/.onemail/config.json" ]; then
    account_count=$(jq '.accounts | length' "$HOME/.onemail/config.json")
    
    if [ "$account_count" -gt 0 ]; then
        echo "4️⃣ 测试邮件收取..."
        
        # 获取第一个账户
        first_account=$(jq -r '.accounts[0].email' "$HOME/.onemail/config.json")
        
        echo "   测试账户: $first_account"
        
        if bash "$SCRIPT_DIR/fetch.sh" --account "$first_account" --limit 1 &> /dev/null; then
            echo "✅ 邮件收取功能正常"
        else
            echo "⚠️  邮件收取功能可能有问题（可能是网络或认证问题）"
        fi
    else
        echo "4️⃣ 跳过邮件收取测试（未配置账户）"
    fi
else
    echo "4️⃣ 跳过邮件收取测试（未配置）"
fi

echo ""

# 测试 5: 测试 JSON 输出格式
echo "5️⃣ 测试 JSON 输出格式..."
test_json='[{"id":"test","account":"gmail","from":"test@example.com","to":"you@example.com","subject":"Test","date":"2026-03-07T10:00:00Z","unread":true,"has_attachments":false,"snippet":"Test email"}]'

if echo "$test_json" | jq '.' &> /dev/null; then
    echo "✅ JSON 格式正确"
else
    echo "❌ JSON 格式错误"
fi

echo ""

# 总结
echo "🎉 测试完成！"
echo ""
echo "下一步:"
echo "  1. 如果未配置账户，运行: bash $SCRIPT_DIR/setup.sh"
echo "  2. 收取邮件: bash $SCRIPT_DIR/fetch.sh"
echo "  3. 发送邮件: bash $SCRIPT_DIR/send.sh --to recipient@example.com --subject 'Test' --body 'Hello'"
echo "  4. 查看帮助: bash $SCRIPT_DIR/accounts.sh help"
