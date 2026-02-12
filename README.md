# Claude Code Multi-Provider Setup

Seamlessly switch between Anthropic, Kimi, and GLM APIs in Claude Code without editing config files.

## Features

- **One-command provider switching**: `cc-use anthropic|kimi|glm`
- **Environment-based auth**: No hardcoded credentials in Claude config
- **Auto model selection**: GLM uses `glm-5` by default
- **Status checks**: `cc-status` shows all configured providers
- **Convenience aliases**: `cc-anthropic`, `cc-kimi`, `cc-glm` for one-shot launches

## Supported Providers

| Provider | Base URL | Model | Key Variable |
|----------|----------|-------|--------------|
| Anthropic | `https://api.anthropic.com` | Claude 3.5 Sonnet | `ANTHROPIC_API_KEY` |
| Kimi | `https://api.moonshot.ai/anthropic` | Kimi Coding Plan | `KIMI_API_KEY` |
| GLM | `https://api.z.ai/api/anthropic` | GLM-5 | `ZAI_API_KEY` |

## Quick Start

```bash
# 1. Clone this repo
git clone https://github.com/YOUR_USERNAME/claude-code-provider-setup.git
cd claude-code-provider-setup

# 2. Copy the env template and add your keys
cp .env.example ~/.claude/.env
# Edit ~/.claude/.env with your actual API keys

# 3. Install the provider switcher
mkdir -p ~/.claude
cp provider-switch.sh ~/.claude/
echo 'source ~/.claude/provider-switch.sh' >> ~/.zshrc  # or ~/.bashrc
source ~/.zshrc

# 4. Switch providers and launch
ccl-use glm
cc
```

## Commands

| Command | Description |
|---------|-------------|
| `cc-use anthropic` | Switch to Anthropic API |
| `cc-use kimi` | Switch to Kimi API |
| `cc-use glm` | Switch to GLM API |
| `cc-status` | Show current provider and key status |
| `cc` | Launch Claude Code with current provider |
| `cc-anthropic` | One-shot: switch to Anthropic and launch |
| `cc-kimi` | One-shot: switch to Kimi and launch |
| `cc-glm` | One-shot: switch to GLM and launch |

## Setup Details

### 1. Install Claude Code CLI

```bash
npm install -g @anthropic-ai/claude-code
```

### 2. Create Environment File

```bash
mkdir -p ~/.claude
cp .env.example ~/.claude/.env
```

Edit `~/.claude/.env`:

```bash
# Required: At least one of these
ANTHROPIC_API_KEY=sk-ant-api03-...
KIMI_API_KEY=sk-kimi-...
ZAI_API_KEY=...
```

### 3. Install Provider Switcher

```bash
cp provider-switch.sh ~/.claude/
echo 'source ~/.claude/provider-switch.sh' >> ~/.zshrc
source ~/.zshrc
```

### 4. Initialize Provider State

```bash
echo "anthropic" > ~/.claude/provider.current
```

## Troubleshooting

### Electron/Squirrel Crash

If you see errors like `Unable to find helper app`, your `claude` symlink points to the Desktop app instead of the CLI:

```bash
# Check current symlink
ls -la ~/.local/bin/claude

# Fix: Repoint to Node CLI
mv ~/.local/bin/claude ~/.local/bin/claude.bak
ln -s ~/.local/node/bin/claude ~/.local/bin/claude
```

### 401 Authentication Error

Ensure your API keys are set in `~/.claude/.env` and the file is sourced. The switcher maps:
- `ANTHROPIC_API_KEY` → `ANTHROPIC_AUTH_TOKEN`
- `KIMI_API_KEY` → `ANTHROPIC_AUTH_TOKEN`
- `ZAI_API_KEY` → `ANTHROPIC_AUTH_TOKEN`

### Provider Not Switching

1. Check current provider: `cc-status`
2. Verify env file is loaded: `cat ~/.claude/.env`
3. Source your shell config: `source ~/.zshrc`

## Files

| File | Purpose |
|------|---------|
| `provider-switch.sh` | Main switching logic and shell functions |
| `.env.example` | Template for API keys |
| `~/.claude/provider.current` | Stores current provider (auto-created) |
| `~/.claude/.env` | Your actual API keys (gitignored) |

## Security

- Never commit `.env` files with real API keys
- The switcher uses shell environment variables - keys stay in memory only
- Each provider's key is isolated; only the active provider's key is exported

## License

MIT
