#!/bin/bash
# one-mail Skill 快速测试（核心功能）

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

# 辅助函数：从 fetch.sh 输出中提取 JSON
extract_json() {
    sed '/^\[20/d'  # 删除日志行（格式：[2026-03-07 ...]）
}

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
echo "one-mail Skill 快速测试套件"
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
    "bash $SCRIPT_DIR/fetch.sh --limit 5 2>&1 | extract_json | jq -e 'length > 0' > /dev/null"

test_case "2.2 收取单个账户邮件（163）" \
    "bash $SCRIPT_DIR/fetch.sh --account 163 --limit 3 2>&1 | extract_json | jq -e '.[] | select(.account == \"163\")' > /dev/null"

test_case "2.3 JSON 格式正确" \
    "bash $SCRIPT_DIR/fetch.sh --limit 1 2>&1 | extract_json | jq -e '.[0] | has(\"id\", \"account\", \"from\", \"subject\", \"date\", \"unread\")' > /dev/null"

test_case "2.4 邮件包含必需字段" \
    "bash $SCRIPT_DIR/fetch.sh --limit 1 2>&1 | extract_json | jq -e '.[0] | .id and .account and .subject' > /dev/null"

# ============================================
# 3. 邮件发送测试
# ============================================

# 获取第一个账户的邮箱地址作为收件人
FIRST_EMAIL=$(jq -r '.accounts[0].email' ~/.onemail/config.json)

# 创建测试邮件内容
TEST_SUBJECT="one-mail 快速测试 - $(date '+%Y%m%d%H%M%S')"
TEST_BODY="这是 one-mail skill 的快速测试邮件。

测试时间: $(date '+%Y-%m-%d %H:%M:%S')
测试编号: TEST-$(date '+%s')

---
Powered by one-mail v1.0.1"

test_case "3.1 发送纯文本邮件（自己发给自己）" \
    "bash $SCRIPT_DIR/send.sh --to '$FIRST_EMAIL' --subject '$TEST_SUBJECT' --body '$TEST_BODY' 2>&1 | grep -q '邮件已发送'"

# 等待邮件送达
echo "⏳ 等待 5 秒让邮件送达..."
sleep 5

test_case "3.2 验证邮件已送达" \
    "bash $SCRIPT_DIR/fetch.sh --limit 10 2>&1 | extract_json | jq -e '.[] | select(.subject == \"$TEST_SUBJECT\")' > /dev/null"

# ============================================
# 4. 多账户测试
# ============================================

ACCOUNT_COUNT=$(jq '.accounts | length' ~/.onemail/config.json)

if [ "$ACCOUNT_COUNT" -ge 2 ]; then
    SECOND_EMAIL=$(jq -r '.accounts[1].email' ~/.onemail/config.json)
    
    test_case "4.1 从第二个账户发送邮件" \
        "bash $SCRIPT_DIR/send.sh --account '$SECOND_EMAIL' --to '$FIRST_EMAIL' --subject 'one-mail 多账户测试' --body '从第二个账户发送' 2>&1 | grep -q '邮件已发送'"
    
    test_case "4.2 收取第二个账户的邮件" \
        "bash $SCRIPT_DIR/fetch.sh --account \$(jq -r '.accounts[1].name' ~/.onemail/config.json) --limit 3 2>&1 | extract_json | jq -e '.[0]' > /dev/null"
else
    echo -e "${YELLOW}⚠️  跳过多账户测试（只有 $ACCOUNT_COUNT 个账户）${NC}"
fi

# ============================================
# 5. 数据完整性测试
# ============================================

test_case "5.1 邮件 ID 唯一性" \
    "bash $SCRIPT_DIR/fetch.sh --limit 20 2>&1 | extract_json | jq -r '.[].id' | sort | uniq -d | wc -l | grep -q '^       0$'"

test_case "5.2 邮件日期格式正确" \
    "bash $SCRIPT_DIR/fetch.sh --limit 5 2>&1 | extract_json | jq -e '.[].date' > /dev/null"

test_case "5.3 发件人地址格式正确" \
    "bash $SCRIPT_DIR/fetch.sh --limit 5 2>&1 | extract_json | jq -e '.[].from' > /dev/null"

# ============================================
# 测试报告
# ============================================

test_report
