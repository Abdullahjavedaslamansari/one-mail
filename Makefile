# oneMail Makefile

.PHONY: help install uninstall setup test demo clean

help:
	@echo "oneMail - 统一邮箱管理工具"
	@echo ""
	@echo "可用命令:"
	@echo "  make install    - 安装 onemail 命令到系统"
	@echo "  make uninstall  - 卸载 onemail 命令"
	@echo "  make setup      - 初始化配置"
	@echo "  make test       - 运行测试"
	@echo "  make demo       - 功能演示"
	@echo "  make clean      - 清理临时文件"
	@echo ""

install:
	@bash install.sh

uninstall:
	@bash uninstall.sh

setup:
	@bash setup.sh

test:
	@bash test.sh

demo:
	@bash demo.sh

clean:
	@echo "清理临时文件..."
	@find . -name "*.pyc" -delete
	@find . -name "__pycache__" -delete
	@echo "✅ 清理完成"
