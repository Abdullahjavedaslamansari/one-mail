#!/bin/bash
# one-mail 安装检查脚本

echo "🔍 one-mail 安装检查"
echo "==================="
echo ""

# 检查脚本文件
echo "📁 检查脚本文件..."
required_files=(
    "setup.sh"
    "fetch.sh"
    "send.sh"
    "accounts.sh"
    "test.sh"
    "demo.sh"
    "lib/common.sh"
    "lib/gmail.sh"
    "lib/outlook.sh"
    "lib/163.sh"
)

missing_files=()
for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        missing_files+=("$file")
    fi
done

if [ ${#missing_files[@]} -eq 0 ]; then
    echo "✅ 所有脚本文件完整 (${#required_files[@]} 个)"
else
    echo "❌ 缺少文件: ${missing_files[*]}"
fi

echo ""

# 检查文档文件
echo "📚 检查文档文件..."
doc_files=(
    "SKILL.md"
    "README.md"
    "QUICKSTART.md"
    "EXAMPLES.md"
    "PROJECT.md"
    "skill.json"
)

missing_docs=()
for file in "${doc_files[@]}"; do
    if [ ! -f "$file" ]; then
        missing_docs+=("$file")
    fi
done

if [ ${#missing_docs[@]} -eq 0 ]; then
    echo "✅ 所有文档文件完整 (${#doc_files[@]} 个)"
else
    echo "❌ 缺少文档: ${missing_docs[*]}"
fi

echo ""

# 检查可执行权限
echo "🔐 检查可执行权限..."
executable_files=(
    "setup.sh"
    "fetch.sh"
    "send.sh"
    "accounts.sh"
    "test.sh"
    "demo.sh"
    "lib/common.sh"
    "lib/gmail.sh"
    "lib/outlook.sh"
    "lib/163.sh"
)

non_executable=()
for file in "${executable_files[@]}"; do
    if [ -f "$file" ] && [ ! -x "$file" ]; then
        non_executable+=("$file")
    fi
done

if [ ${#non_executable[@]} -eq 0 ]; then
    echo "✅ 所有脚本文件可执行"
else
    echo "⚠️  以下文件缺少可执行权限: ${non_executable[*]}"
    echo "   运行: chmod +x ${non_executable[*]}"
fi

echo ""

# 检查依赖
echo "🔧 检查系统依赖..."
dependencies=("bash" "jq" "curl" "python3" "openssl")
missing_deps=()

for dep in "${dependencies[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
        missing_deps+=("$dep")
    fi
done

if [ ${#missing_deps[@]} -eq 0 ]; then
    echo "✅ 所有必需依赖已安装"
else
    echo "❌ 缺少依赖: ${missing_deps[*]}"
fi

# 检查可选依赖
echo ""
echo "🔧 检查可选依赖..."
if command -v gog &> /dev/null; then
    echo "✅ gog CLI 已安装（Gmail 支持）"
else
    echo "⚠️  gog CLI 未安装（Gmail 功能将不可用）"
fi

echo ""

# 检查配置
echo "⚙️  检查配置..."
if [ -f "$HOME/.onemail/config.json" ]; then
    account_count=$(jq '.accounts | length' "$HOME/.onemail/config.json" 2>/dev/null || echo "0")
    echo "✅ 配置文件存在 ($account_count 个账户)"
else
    echo "ℹ️  配置文件不存在（首次使用需要运行 setup.sh）"
fi

echo ""

# 总结
echo "📊 安装总结"
echo "----------"
echo "脚本文件: ${#required_files[@]} 个"
echo "文档文件: ${#doc_files[@]} 个"
echo "总大小: $(du -sh . | awk '{print $1}')"
echo ""

if [ ${#missing_files[@]} -eq 0 ] && [ ${#missing_docs[@]} -eq 0 ] && [ ${#missing_deps[@]} -eq 0 ]; then
    echo "✅ one-mail 安装完整，可以使用！"
    echo ""
    echo "下一步："
    echo "  1. 运行配置: bash setup.sh"
    echo "  2. 查看演示: bash demo.sh"
    echo "  3. 运行测试: bash test.sh"
else
    echo "⚠️  安装不完整，请检查上述问题"
fi

echo ""
