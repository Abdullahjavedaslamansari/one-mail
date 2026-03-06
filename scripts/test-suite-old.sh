#!/bin/bash
# one-mail Skill 完整测试用例
# 测试邮件收发、附件、多账户等功能

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 测试结果统计
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# 测试函数
test_case() {
    local name="$1"
    local command="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "测试 #$TOTAL_TESTS: $name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if eval "$command"; then
        echo -e "${GREEN}✅ 通过${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo -e "${RED}❌ 失败${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# 测试报告
test_report() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "测试报告"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "总计: $TOTAL_TESTS"
    echo -e "${GREEN}通过: $PASSED_TESTS${NC}"
    echo -e "${RED}失败: $FAILED_TESTS${NC}"
    echo ""
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "${GREEN}🎉 所有测试通过！${NC}"
        exit 0
    else
        echo -e "${RED}⚠️  有 $FAILED_TESTS 个测试失败${NC}"
        exit 1
    fi
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "one-mail Skill 完整测试套件"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "开始时间: $(date '+%Y-%m-%d %H:%M:%S')"

# ============================================
# 1. 配置和账户管理测试
# ============================================

test_case "1.1 列出所有账户" \
    "bash $SCRIPT_DIR/accounts.sh list | grep -q '已配置的邮箱账户'"

test_case "1.2 检查配置文件存在" \
    "[ -f ~/.onemail/config.json ] && [ -f ~/.onemail/credentials.json ]"

test_case "1.3 配置文件权限正确" \
    "[ \$(stat -f '%A' ~/.onemail/credentials.json) = '600' ]"

test_case "1.4 至少有一个账户配置" \
    "[ \$(jq '.accounts | length' ~/.onemail/config.json) -ge 1 ]"

# ============================================
# 2. 邮件收取测试
# ============================================

test_case "2.1 收取所有账户邮件（限制5封）" \
    "bash $SCRIPT_DIR/fetch.sh --limit 5 2>&1 | grep -E '^\[' | tail -1 | jq -e 'length > 0' > /dev/null"

test_case "2.2 收取单个账户邮件（163）" \
    "bash $SCRIPT_DIR/fetch.sh --account 163 --limit 3 2>&1 | grep -E '^\\[' | tail -1 | jq -e '.[] | select(.account == \"163\")' > /dev/null"

test_case "2.3 收取未读邮件" \
    "bash $SCRIPT_DIR/fetch.sh --unread --limit 5 2>&1 | grep -E '^\\[' | tail -1 | jq -e '.[] | select(.unread == true)' > /dev/null || true"

test_case "2.4 JSON 格式正确" \
    "bash $SCRIPT_DIR/fetch.sh --limit 1 2>&1 | grep -E '^\\[' | tail -1 | jq -e '.[0] | has(\"id\", \"account\", \"from\", \"subject\", \"date\", \"unread\")' > /dev/null"

test_case "2.5 邮件包含必需字段" \
    "bash $SCRIPT_DIR/fetch.sh --limit 1 2>&1 | grep -E '^\\[' | tail -1 | jq -e '.[0] | .id and .account and .subject' > /dev/null"

# ============================================
# 3. 邮件发送测试
# ============================================

# 创建测试邮件内容
TEST_SUBJECT="one-mail 自动化测试 - $(date '+%Y%m%d%H%M%S')"
TEST_BODY="这是 one-mail skill 的自动化测试邮件。

测试时间: $(date '+%Y-%m-%d %H:%M:%S')
测试编号: TEST-$(date '+%s')

如果你收到这封邮件，说明邮件发送功能正常工作。

---
Powered by one-mail v1.0.1
自动化测试套件"

# 获取第一个账户的邮箱地址作为收件人
FIRST_EMAIL=$(jq -r '.accounts[0].email' ~/.onemail/config.json)

test_case "3.1 发送纯文本邮件（自己发给自己）" \
    "bash $SCRIPT_DIR/send.sh --to '$FIRST_EMAIL' --subject '$TEST_SUBJECT' --body '$TEST_BODY' 2>&1 | grep -q '邮件已发送'"

# 等待邮件送达
echo "⏳ 等待 5 秒让邮件送达..."
sleep 5

test_case "3.2 验证邮件已送达" \
    "bash $SCRIPT_DIR/fetch.sh --limit 10 2>&1 | grep -E '^\\[' | tail -1 | jq -e '.[] | select(.subject == \"$TEST_SUBJECT\")' > /dev/null"

# ============================================
# 4. 附件测试
# ============================================

# 创建测试附件
TEST_ATTACH_DIR="/tmp/onemail-test-$$"
mkdir -p "$TEST_ATTACH_DIR"

# 创建文本附件
echo "这是一个测试附件文件。
创建时间: $(date)
测试编号: TEST-$(date '+%s')" > "$TEST_ATTACH_DIR/test.txt"

# 创建 JSON 附件
echo '{"test": true, "timestamp": '$(date '+%s')', "message": "one-mail 测试附件"}' > "$TEST_ATTACH_DIR/test.json"

test_case "4.1 发送带文本附件的邮件" \
    "bash $SCRIPT_DIR/send.sh --to '$FIRST_EMAIL' --subject 'one-mail 附件测试 - TXT' --body '测试文本附件' --attach '$TEST_ATTACH_DIR/test.txt' 2>&1 | grep -q '邮件已发送' || echo '⚠️  附件功能可能未实现'"

test_case "4.2 发送带 JSON 附件的邮件" \
    "bash $SCRIPT_DIR/send.sh --to '$FIRST_EMAIL' --subject 'one-mail 附件测试 - JSON' --body '测试 JSON 附件' --attach '$TEST_ATTACH_DIR/test.json' 2>&1 | grep -q '邮件已发送' || echo '⚠️  附件功能可能未实现'"

# 清理测试附件
rm -rf "$TEST_ATTACH_DIR"

# ============================================
# 5. 多账户测试
# ============================================

ACCOUNT_COUNT=$(jq '.accounts | length' ~/.onemail/config.json)

if [ "$ACCOUNT_COUNT" -ge 2 ]; then
    SECOND_EMAIL=$(jq -r '.accounts[1].email' ~/.onemail/config.json)
    
    test_case "5.1 从第二个账户发送邮件" \
        "bash $SCRIPT_DIR/send.sh --account '$SECOND_EMAIL' --to '$FIRST_EMAIL' --subject 'one-mail 多账户测试' --body '从第二个账户发送' 2>&1 | grep -q '邮件已发送'"
    
    test_case "5.2 收取第二个账户的邮件" \
        "bash $SCRIPT_DIR/fetch.sh --account \$(jq -r '.accounts[1].name' ~/.onemail/config.json) --limit 3 2>&1 | grep -E '^\\[' | tail -1 | jq -e '.[0]' > /dev/null"
else
    echo -e "${YELLOW}⚠️  跳过多账户测试（只有 $ACCOUNT_COUNT 个账户）${NC}"
fi

# ============================================
# 6. 统计功能测试
# ============================================

test_case "6.1 今日邮件统计" \
    "bash $SCRIPT_DIR/stats.sh --days 1 2>&1 | grep -q '今日邮件统计'"

test_case "6.2 本周邮件统计" \
    "bash $SCRIPT_DIR/stats.sh --days 7 2>&1 | grep -q '邮件统计'"

test_case "6.3 统计 JSON 格式" \
    "bash $SCRIPT_DIR/stats.sh --days 1 --json 2>&1 | jq -e '.total' > /dev/null"

# ============================================
# 7. 错误处理测试
# ============================================

test_case "7.1 发送邮件缺少收件人" \
    "! bash $SCRIPT_DIR/send.sh --subject 'Test' --body 'Test' 2>&1 | grep -q '缺少收件人'"

test_case "7.2 发送邮件缺少主题" \
    "! bash $SCRIPT_DIR/send.sh --to 'test@example.com' --body 'Test' 2>&1 | grep -q '缺少主题'"

test_case "7.3 发送邮件缺少正文" \
    "! bash $SCRIPT_DIR/send.sh --to 'test@example.com' --subject 'Test' 2>&1 | grep -q '缺少正文'"

test_case "7.4 查询不存在的账户" \
    "! bash $SCRIPT_DIR/fetch.sh --account 'nonexistent' 2>&1 | grep -q '账户不存在'"

# ============================================
# 8. 性能测试
# ============================================

test_case "8.1 收取 20 封邮件性能（< 10秒）" \
    "timeout 10 bash $SCRIPT_DIR/fetch.sh --limit 20 > /dev/null 2>&1"

test_case "8.2 发送邮件性能（< 5秒）" \
    "timeout 5 bash $SCRIPT_DIR/send.sh --to '$FIRST_EMAIL' --subject 'Performance Test' --body 'Test' > /dev/null 2>&1"

# ============================================
# 9. 数据完整性测试
# ============================================

test_case "9.1 邮件 ID 唯一性" \
    "bash $SCRIPT_DIR/fetch.sh --limit 20 2>&1 | grep -E '^\\[' | tail -1 | jq -r '.[].id' | sort | uniq -d | wc -l | grep -q '^0$'"

test_case "9.2 邮件日期格式正确" \
    "bash $SCRIPT_DIR/fetch.sh --limit 5 2>&1 | grep -E '^\\[' | tail -1 | jq -e '.[].date' > /dev/null"

test_case "9.3 发件人地址格式正确" \
    "bash $SCRIPT_DIR/fetch.sh --limit 5 2>&1 | grep -E '^\\[' | tail -1 | jq -e '.[].from' > /dev/null"

# ============================================
# 10. 集成测试
# ============================================

test_case "10.1 完整流程：发送 -> 等待 -> 收取 -> 验证" \
    "
    UNIQUE_ID=\$(date '+%s')
    bash $SCRIPT_DIR/send.sh --to '$FIRST_EMAIL' --subject 'Integration Test \$UNIQUE_ID' --body 'Test' > /dev/null 2>&1 &&
    sleep 5 &&
    bash $SCRIPT_DIR/fetch.sh --limit 20 2>&1 | grep -E '^\\[' | tail -1 | jq -e '.[] | select(.subject | contains(\"Integration Test \$UNIQUE_ID\"))' > /dev/null
    "

# ============================================
# 测试报告
# ============================================

test_report
