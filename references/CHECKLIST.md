# one-mail 项目清单

## ✅ 已完成

### 核心功能
- [x] 多账户管理（Gmail、Outlook、网易邮箱）
- [x] 统一收发接口
- [x] 跨账户搜索
- [x] 附件支持（Gmail、网易邮箱）
- [x] JSON 输出格式
- [x] 安全凭证存储

### 脚本文件
- [x] setup.sh - 初始化配置
- [x] fetch.sh - 收取邮件
- [x] send.sh - 发送邮件
- [x] accounts.sh - 账户管理
- [x] stats.sh - 邮件统计
- [x] test.sh - 功能测试
- [x] demo.sh - 功能演示
- [x] install.sh - 系统安装
- [x] uninstall.sh - 系统卸载
- [x] onemail - CLI 主入口

### 适配器
- [x] lib/common.sh - 公共函数
- [x] lib/gmail.sh - Gmail 适配器
- [x] lib/outlook.sh - Outlook 适配器
- [x] lib/163.sh - 网易邮箱适配器

### 文档
- [x] SKILL.md - Skill 定义
- [x] README.md - 详细文档
- [x] QUICKSTART.md - 快速入门
- [x] EXAMPLES.md - 使用示例
- [x] PROJECT.md - 项目总结
- [x] CHANGELOG.md - 版本历史
- [x] CONTRIBUTING.md - 贡献指南
- [x] SUMMARY.md - 完成总结
- [x] LICENSE - MIT 许可证
- [x] CHECKLIST.md - 本清单

### 配置文件
- [x] skill.json - Skill 元数据
- [x] config.template.json - 配置模板
- [x] credentials.template.json - 凭证模板
- [x] Makefile - 任务管理
- [x] .gitignore - Git 忽略规则

### 测试
- [x] 依赖检查
- [x] 配置文件验证
- [x] JSON 格式验证
- [x] 基本功能测试

## ⏳ 待实现（v1.1.0）

### 功能增强
- [ ] view.sh - 邮件详情查看
- [ ] mark.sh - 邮件标记（已读/未读/星标）
- [ ] Outlook 附件支持
- [ ] 网易邮箱连接测试
- [ ] HTML 邮件支持

### 优化
- [ ] 性能优化（缓存机制）
- [ ] 错误处理增强
- [ ] 日志系统
- [ ] 进度显示

## 🔮 未来计划（v1.2.0+）

### 新邮箱支持
- [ ] QQ 邮箱
- [ ] Hotmail
- [ ] iCloud Mail
- [ ] ProtonMail

### 高级功能
- [ ] 邮件模板
- [ ] 邮件规则和过滤器
- [ ] 邮件标签和分类
- [ ] 邮件搜索优化
- [ ] 批量操作
- [ ] 邮件导出（PDF、HTML）

### 用户体验
- [ ] Web UI 界面
- [ ] TUI 界面（终端 UI）
- [ ] 多语言支持
- [ ] 配置向导优化
- [ ] 交互式命令

### 集成
- [ ] OpenClaw 深度集成
- [ ] Webhook 支持
- [ ] API 服务器
- [ ] 插件系统

## 📝 注意事项

### 已知限制
- Outlook 附件功能待实现
- 网易邮箱连接测试待实现
- 不支持 HTML 邮件编辑
- 不支持 Exchange Server

### 依赖要求
- bash 4.0+
- jq
- curl
- openssl
- python3
- gog (可选，Gmail 需要)

### 安全建议
- 使用应用专用密码
- 定期更新 OAuth token
- 不要提交凭证文件到 Git
- 保持配置文件权限为 600

## 🎯 下一步行动

1. [ ] 实际测试所有邮箱服务
2. [ ] 收集用户反馈
3. [ ] 优化错误处理
4. [ ] 添加更多使用示例
5. [ ] 发布到 ClawHub

---

**最后更新**: 2026-03-07  
**版本**: 1.0.0  
**状态**: ✅ 完成
