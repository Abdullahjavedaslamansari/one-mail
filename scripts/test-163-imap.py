#!/usr/bin/env python3
# 测试网易邮箱 IMAP ID 命令

import imaplib
import sys

# 扩展 IMAP4_SSL 类以支持 ID 命令
class IMAP4_SSL_ID(imaplib.IMAP4_SSL):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # 添加 ID 命令支持
        imaplib.Commands['ID'] = ('AUTH',)
    
    def id_(self, *args):
        """发送 ID 命令"""
        name = 'ID'
        typ, dat = self._simple_command(name, *args)
        return self._untagged_response(typ, dat, name)

def test_163_imap(email, password):
    """测试网易邮箱 IMAP 连接"""
    try:
        print(f"连接到 imap.163.com...")
        mail = IMAP4_SSL_ID('imap.163.com')
        
        print("发送 ID 命令...")
        try:
            typ, dat = mail.id_('("name" "oneMail" "version" "1.0.0" "vendor" "OpenClaw")')
            print(f"ID 命令响应: {typ} - {dat}")
        except Exception as e:
            print(f"ID 命令失败（可能不支持）: {e}")
        
        print(f"登录账户: {email}")
        mail.login(email, password)
        
        print("选择收件箱...")
        mail.select('INBOX')
        
        print("搜索邮件...")
        typ, data = mail.search(None, 'ALL')
        email_ids = data[0].split()
        
        print(f"✅ 成功！找到 {len(email_ids)} 封邮件")
        
        mail.close()
        mail.logout()
        
        return True
        
    except Exception as e:
        print(f"❌ 错误: {e}")
        return False

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("用法: python3 test-163-imap.py <email> <password>")
        sys.exit(1)
    
    email = sys.argv[1]
    password = sys.argv[2]
    
    success = test_163_imap(email, password)
    sys.exit(0 if success else 1)
