# 🔀 Claude Code Multi-Provider Switcher

> Seamlessly switch between **Anthropic**, **Kimi (Moonshot)**, **GLM-5 (Z.ai)**, and **MiniMax** APIs in Claude Code — with one command and a visual provider indicator.

![Version](https://img.shields.io/badge/version-2.0-blue)
![Shell](https://img.shields.io/badge/shell-bash%20%2F%20zsh-green)
![License](https://img.shields.io/badge/license-MIT-yellow)

---

## ✨ Features

- **🔀 One-command switching** — `cc-use kimi` and you're done
- **🎨 Visual provider banner** — see which provider is active every time you launch
- **🔐 Isolated key management** — keys stay in `~/.claude/.env`, never leaked between providers
- **🧹 Clean env switching** — all stale env vars are purged before each switch
- **📊 Status dashboard** — `cc-status` shows all providers and key health at a glance
- **⚡ Shortcut launchers** — `cc-kimi`, `cc-glm`, `cc-anthropic` for one-shot launches

---

## 🌐 Supported Providers

| Provider | Icon | Endpoint | Model | Key Variable |
|----------|------|----------|-------|--------------|
| **Anthropic** | 🟠 | `api.anthropic.com` | Claude Opus / Sonnet | `ANTHROPIC_API_KEY` |
| **Kimi** | 🌙 | `api.moonshot.ai/anthropic` | Kimi K2 | `KIMI_API_KEY` |
| **GLM** | 🔮 | `api.z.ai/api/anthropic` | GLM-5 | `ZAI_API_KEY` |
| **MiniMax** | ⚡ | `api.minimaxi.chat/anthropic` | MiniMax-Text-01 | `MINIMAX_API_KEY` |

All providers use Anthropic-compatible API endpoints, so Claude Code works natively with each one — no patching required.

---

## 🚀 Quick Start

### 1. Clone

```bash
git clone https://github.com/404kidwiz/claude-code-provider-setup.git
cd claude-code-provider-setup
```

### 2. Set Up API Keys

```bash
mkdir -p ~/.claude
cp .env.example ~/.claude/.env
```

Edit `~/.claude/.env` and paste your actual API keys:

```bash
# At least one key required
ANTHROPIC_API_KEY=sk-ant-api03-...
KIMI_API_KEY=sk-kimi-...
ZAI_API_KEY=9e77e7fd...
MINIMAX_API_KEY=sk-cp-...
```

### 3. Install the Switcher

```bash
cp provider-switch.sh ~/.claude/
echo '' >> ~/.zshrc
echo '# Claude Code Multi-Provider Switcher' >> ~/.zshrc
echo 'source ~/.claude/provider-switch.sh' >> ~/.zshrc
source ~/.zshrc
```

### 4. Switch and Launch

```bash
cc-use kimi    # Switch to Kimi
cc             # Launch Claude Code — banner shows active provider
```

---

## 📋 Commands

| Command | Description |
|---------|-------------|
| `cc-use anthropic` | 🟠 Switch to Anthropic Claude |
| `cc-use kimi` | 🌙 Switch to Kimi (Moonshot) |
| `cc-use glm` | 🔮 Switch to GLM-5 (Z.ai) |
| `cc-use minimax` | ⚡ Switch to MiniMax |
| `cc` | Launch Claude Code with active provider (shows banner) |
| `cc-status` | Dashboard: current provider + all key statuses |
| `cc-anthropic` | One-shot: switch to Anthropic → launch |
| `cc-kimi` | One-shot: switch to Kimi → launch |
| `cc-glm` | One-shot: switch to GLM → launch |
| `cc-minimax` | One-shot: switch to MiniMax → launch |

---

## 🎨 Provider Banner

Every time you switch or launch, you see a clear indicator:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🌙  PROVIDER: KIMI (Moonshot)
  Endpoint: api.moonshot.ai
  Model:    kimi-k2
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🔮  PROVIDER: GLM-5 (Z.ai)
  Endpoint: api.z.ai
  Model:    glm-5
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🟠  PROVIDER: ANTHROPIC
  Endpoint: api.anthropic.com
  Model:    claude-opus/sonnet
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

No more guessing which provider you're using! 🎯

---

## 🔧 How It Works

```
┌──────────────┐     ┌─────────────────────┐     ┌───────────────┐
│  cc-use kimi │ ──▶ │ provider-switch.sh  │ ──▶ │ Claude Code   │
│              │     │                     │     │               │
│  Writes to:  │     │ 1. Clean all vars   │     │ Uses:         │
│  provider.   │     │ 2. Load ~/.claude/  │     │ AUTH_TOKEN    │
│  current     │     │    .env             │     │ BASE_URL      │
│              │     │ 3. Set AUTH_TOKEN   │     │ MODEL (if     │
└──────────────┘     │ 4. Set BASE_URL     │     │  GLM)         │
                     │ 5. Empty API_KEY    │     └───────────────┘
                     └─────────────────────┘
```

**Key mechanism**: For third-party providers (Kimi, GLM, MiniMax), Claude Code needs:
- `ANTHROPIC_API_KEY=""` — set to **empty string** (not just unset) so Claude Code doesn't try Anthropic auth
- `ANTHROPIC_AUTH_TOKEN` — your provider's API key
- `ANTHROPIC_BASE_URL` — the provider's Anthropic-compatible endpoint

---

## 🐛 Troubleshooting

### 401 Authentication Error

Your API key isn't being picked up. Check:

```bash
cc-status                    # Are all keys showing ✅?
cat ~/.claude/.env           # Is the file there with your keys?
source ~/.zshrc              # Did you reload your shell?
```

### Wrong Provider / Model Confusion

The v2.0 switcher cleans ALL provider env vars on every switch. If you're still seeing stale values:

```bash
# Open a fresh terminal
source ~/.zshrc
cc-use kimi
cc-status   # Should show 🌙 KIMI
```

### "command not found: cc"

The switcher wasn't sourced. Add to your shell config:

```bash
echo 'source ~/.claude/provider-switch.sh' >> ~/.zshrc
source ~/.zshrc
```

### Electron/Squirrel Crash

If `claude` launches the Desktop app instead of the CLI:

```bash
# Check what claude points to
which claude

# Fix: ensure CLI version is first in PATH
npm install -g @anthropic-ai/claude-code
```

### Conflicting Provider Scripts

If you previously used `clawd/scripts/provider-helpers.sh` or other provider scripts, **remove them** from your `.zshrc`:

```bash
# ❌ Remove this line if present:
# source ~/Downloads/clawd/scripts/provider-helpers.sh

# ✅ Keep only this:
source ~/.claude/provider-switch.sh
```

---

## 📁 Files

| File | Location | Purpose |
|------|----------|---------|
| `provider-switch.sh` | `~/.claude/` | Core switching logic, banner, and shell functions |
| `.env.example` | This repo | Template for API keys |
| `~/.claude/.env` | Home dir | Your actual API keys (gitignored) |
| `~/.claude/provider.current` | Home dir | Stores active provider name (auto-created) |

---

## 🔑 Getting API Keys

| Provider | Where to Get Your Key |
|----------|----------------------|
| **Anthropic** | [console.anthropic.com](https://console.anthropic.com/) |
| **Kimi** | [platform.moonshot.ai](https://platform.moonshot.ai/) |
| **GLM (Z.ai)** | [open.bigmodel.cn](https://open.bigmodel.cn/) or [z.ai](https://z.ai) |
| **MiniMax** | [platform.minimaxi.com](https://platform.minimaxi.com/) |

---

## 🔒 Security

- **Never commit `.env` files** with real API keys — `.gitignore` protects you
- Keys are loaded into shell environment only when `cc` is launched
- Each switch **cleans** the previous provider's vars — no key leakage
- Only the active provider's key is exported to Claude Code

---

## 📄 License

MIT

---

<p align="center">
  <b>Built by <a href="https://github.com/404kidwiz">@404kidwiz</a></b><br>
  <sub>Stop switching config files. Just <code>cc-use</code> and go. 🚀</sub>
</p>
