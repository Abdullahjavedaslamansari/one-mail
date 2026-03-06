#!/bin/bash
# one-mail Skill 核心功能测试（最小化版本）

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# 测试结果
TOTAL=0
PASSED=0

# 辅助函数
extract_json() {
    sed '/^\[20/d'
}

test_case() {
    TOTAL=$((TOTAL + 1))
    echo -n "测试 #$TOTAL: $1 ... "
    if eval "$2" > /dev/null 2>&1; then
        echo -e "${GREEN}✅${NC}"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}❌${NC}"
    fi
}

echo "one-mail Skill 核心功能测试"
echo "=========================="
echo ""

# 1. 配置测试
test_case "配置文件存在" \
    "[ -f ~/.onemail/config.json ] && [ -f ~/.onemail/credentials.json ]"

test_case "至少有一个账户" \
    "[ \$(jq '.accounts | length' ~/.onemail/config.json) -ge 1 ]"

# 2. 邮件收取测试
test_case "收取邮件（3封）" \
    "bash $SCRIPT_DIR/fetch.sh --limit 3 2>&1 | extract_json | jq -e 'length > 0'"

test_case "JSON 格式正确" \
    "bash $SCRIPT_DIR/fetch.sh --limit 1 2>&1 | extract_json | jq -e '.[0] | has(\"id\", \"account\", \"subject\")'"

# 3. 邮件发送测试
FIRST_EMAIL=$(jq -r '.accounts[0].email' ~/.onemail/config.json)
TEST_SUBJECT="one-mail 测试 - $(date '+%H%M%S')"

test_case "发送邮件" \
    "bash $SCRIPT_DIR/send.sh --to '$FIRST_EMAIL' --subject '$TEST_SUBJECT' --body 'Test' 2>&1 | grep -q '邮件已发送'"

# 4. 多账户测试
ACCOUNT_COUNT=$(jq '.accounts | length' ~/.onemail/config.json)
if [ "$ACCOUNT_COUNT" -ge 2 ]; then
    test_case "多账户支持" \
        "bash $SCRIPT_DIR/fetch.sh --account \$(jq -r '.accounts[1].name' ~/.onemail/config.json) --limit 1 2>&1 | extract_json | jq -e '.[0]'"
fi

# 报告
echo ""
echo "=========================="
echo "结果: $PASSED/$TOTAL 通过"
if [ $PASSED -eq $TOTAL ]; then
    echo -e "${GREEN}🎉 所有测试通过！${NC}"
    exit 0
else
    echo -e "${RED}⚠️  有 $((TOTAL - PASSED)) 个测试失败${NC}"
    exit 1
fi
