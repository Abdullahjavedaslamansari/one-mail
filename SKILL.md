---
name: one-mail
description: Unified email management tool for Gmail, Outlook, and NetEase Mail. Manage multiple email accounts from a single CLI interface. Use when you need to manage multiple email accounts, search across accounts, automate email processing, or integrate email into scripts.
---

# one-mail

Unified email management tool for Gmail, Outlook, and NetEase Mail.

## Quick Start

```bash
# Initialize configuration
bash scripts/setup.sh

# Fetch emails from all accounts
bash scripts/fetch.sh

# Send email
bash scripts/send.sh \
  --to "recipient@example.com" \
  --subject "Hello" \
  --body "Email content"
```

## Features

- **Multi-account management** - Gmail, Outlook, NetEase Mail (163.com)
- **Unified interface** - Single CLI for all accounts
- **Cross-account search** - Search emails across all accounts
- **Attachment support** - Send and receive attachments
- **JSON output** - Easy integration with scripts
- **Secure storage** - OAuth 2.0 and encrypted credentials

## Supported Providers

### Gmail
- OAuth 2.0 authentication
- Requires: `gog` CLI (optional)
- Features: fetch, send, search, attachments

### Outlook
- OAuth 2.0 authentication
- Microsoft Graph API
- Features: fetch, send, search, attachments (< 3MB)

### NetEase Mail (163.com)
- IMAP/SMTP with app password
- Automatic IMAP ID support
- Features: fetch, send, search, attachments

## Configuration

Configuration files are stored in `~/.onemail/`:

- `config.json` - Account settings
- `credentials.json` - Encrypted credentials (600 permissions)

## Usage

### Fetch Emails

```bash
# All accounts
bash scripts/fetch.sh

# Specific account
bash scripts/fetch.sh --account gmail

# Unread only
bash scripts/fetch.sh --unread

# Search
bash scripts/fetch.sh --query "urgent"

# Limit results
bash scripts/fetch.sh --limit 10
```

### Send Emails

```bash
# Basic send
bash scripts/send.sh \
  --to "recipient@example.com" \
  --subject "Subject" \
  --body "Message"

# With attachment
bash scripts/send.sh \
  --to "recipient@example.com" \
  --subject "Report" \
  --body "See attachment" \
  --attach "/path/to/file.pdf"

# From specific account
bash scripts/send.sh \
  --account outlook \
  --to "recipient@example.com" \
  --subject "Hello" \
  --body "Message"
```

### Account Management

```bash
# List accounts
bash scripts/accounts.sh list

# Add account
bash scripts/accounts.sh add

# Remove account
bash scripts/accounts.sh remove --name gmail

# Set default
bash scripts/accounts.sh set-default --name gmail

# Test connection
bash scripts/accounts.sh test --name gmail
```

## Output Format

All emails are output in JSON format:

```json
[
  {
    "id": "msg_123",
    "account": "gmail",
    "from": "sender@example.com",
    "to": "you@gmail.com",
    "subject": "Meeting tomorrow",
    "date": "2026-03-07T10:30:00Z",
    "unread": true,
    "has_attachments": false,
    "snippet": "Let's meet at 3pm..."
  }
]
```

## Dependencies

- `bash` 4.0+
- `jq` - JSON processing
- `curl` - HTTP requests
- `python3` - IMAP/SMTP (NetEase Mail)
- `gog` - Gmail operations (optional)

## Documentation

- [Quick Start Guide](references/QUICKSTART.md)
- [Examples](references/EXAMPLES.md)
- [Test Cases](references/TEST-CASES.md)
- [IMAP ID Support](references/IMAP-ID.md)
- [Contributing](references/CONTRIBUTING.md)

## Testing

```bash
# Minimal test (recommended)
bash scripts/test-minimal.sh

# Quick test
bash scripts/test-quick.sh

# Full test suite
bash scripts/test-suite.sh
```

## Security

- OAuth 2.0 for Gmail and Outlook
- App-specific passwords for NetEase Mail
- Credentials stored with 600 permissions
- No plaintext passwords in config files

## Troubleshooting

### Gmail Connection Failed

Ensure `gog` CLI is configured:

```bash
gog gmail list --limit 1
```

### Outlook Authorization Failed

1. Check Client ID and Client Secret
2. Verify redirect URI: `http://localhost`
3. Ensure scopes: `Mail.ReadWrite`, `Mail.Send`

### NetEase Mail Connection Failed

1. Enable IMAP/SMTP in mail settings
2. Use app-specific password (not login password)
3. Check firewall for ports 993/465
4. Test connection:

```bash
python3 scripts/test-163-imap.py your@163.com your_app_password
```

## License

MIT License - see [LICENSE](LICENSE)

## Author

Huang Baixun ([@huangbaixun](https://github.com/huangbaixun))

## Links

- GitHub: https://github.com/huangbaixun/one-mail
- Issues: https://github.com/huangbaixun/one-mail/issues
