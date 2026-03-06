# 贡献指南

感谢你对 one-mail 的兴趣！

## 如何贡献

### 报告问题

如果你发现 bug 或有功能建议：

1. 检查是否已有相关 issue
2. 提供详细的复现步骤
3. 包含系统信息（OS、bash 版本等）
4. 附上错误日志

### 提交代码

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建 Pull Request

### 代码规范

**Shell 脚本**
- 使用 `set -e` 启用错误退出
- 函数名使用 snake_case
- 变量名使用 UPPER_CASE（全局）或 lower_case（局部）
- 添加注释说明复杂逻辑
- 使用 `shellcheck` 检查语法

**JSON 格式**
- 使用 2 空格缩进
- 键名使用 snake_case
- 保持一致的结构

**文档**
- 使用 Markdown 格式
- 添加代码示例
- 保持简洁清晰

### 测试

在提交前运行测试：

```bash
bash test.sh
```

### 添加新的邮箱服务

1. 在 `lib/` 目录创建适配器（如 `lib/qq.sh`）
2. 实现以下函数：
   - `fetch_<provider>` - 收取邮件
   - `send_<provider>` - 发送邮件
3. 在 `fetch.sh` 和 `send.sh` 中添加支持
4. 更新文档和测试

### 适配器模板

```bash
#!/bin/bash
# <Provider> 适配器

require_command <dependency>

# 收取邮件
fetch_<provider>() {
    local account="$1"
    local unread_only="$2"
    local query="$3"
    local limit="$4"
    
    # 实现逻辑
    # 返回统一 JSON 格式
}

# 发送邮件
send_<provider>() {
    local account="$1"
    local to="$2"
    local cc="$3"
    local bcc="$4"
    local subject="$5"
    local body="$6"
    local attach="$7"
    local reply_to="$8"
    
    # 实现逻辑
}
```

## 开发环境

### 依赖安装

**macOS**
```bash
brew install jq curl python3
```

**Linux (Ubuntu/Debian)**
```bash
sudo apt-get install jq curl python3
```

### 本地测试

```bash
# 克隆项目
git clone <repo>
cd one-mail

# 运行测试
bash test.sh

# 功能演示
bash demo.sh
```

## 项目结构

```
one-mail/
├── lib/              # 适配器库
│   ├── common.sh     # 公共函数
│   ├── gmail.sh      # Gmail 适配器
│   ├── outlook.sh    # Outlook 适配器
│   └── 163.sh        # 网易邮箱适配器
├── *.sh              # 主要脚本
├── *.md              # 文档
└── skill.json        # 元数据
```

## 发布流程

1. 更新 `CHANGELOG.md`
2. 更新 `skill.json` 中的版本号
3. 运行完整测试
4. 创建 Git tag
5. 推送到仓库

## 许可证

MIT License - 详见 LICENSE 文件

## 联系方式

- 作者: Dolores (OpenClaw AI Assistant)
- 项目: ~/clawd/skills/one-mail/

---

再次感谢你的贡献！🎉
