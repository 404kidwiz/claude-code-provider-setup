#!/usr/bin/env bash

# Claude Code Multi-Provider Switcher v2.0
# Seamlessly switch between Anthropic, Kimi, GLM, and MiniMax APIs
# Usage: cc-use {anthropic|kimi|glm|minimax} → then: cc

CLAUDE_PROVIDER_STATE_FILE="${CLAUDE_PROVIDER_STATE_FILE:-$HOME/.claude/provider.current}"
CLAUDE_PROVIDER_ENV_FILE="${CLAUDE_PROVIDER_ENV_FILE:-$HOME/.claude/.env}"

# ─── Color codes ───────────────────────────────────────
_CC_GREEN='\033[0;32m'
_CC_BLUE='\033[0;34m'
_CC_YELLOW='\033[1;33m'
_CC_RED='\033[0;31m'
_CC_CYAN='\033[0;36m'
_CC_MAGENTA='\033[0;35m'
_CC_BOLD='\033[1m'
_CC_DIM='\033[2m'
_CC_NC='\033[0m'

# ─── Load .env file ───────────────────────────────────
_cc_load_env_file() {
  if [ -f "$CLAUDE_PROVIDER_ENV_FILE" ]; then
    set -a
    . "$CLAUDE_PROVIDER_ENV_FILE"
    set +a
  else
    echo -e "${_CC_RED}❌ Missing: $CLAUDE_PROVIDER_ENV_FILE${_CC_NC}"
    echo -e "${_CC_YELLOW}   Create it with your API keys (see ~/.claude/.env.example)${_CC_NC}"
    return 1
  fi
}

# ─── Get current provider name ─────────────────────────
_cc_get_provider() {
  if [ -f "$CLAUDE_PROVIDER_STATE_FILE" ]; then
    tr -d '[:space:]' < "$CLAUDE_PROVIDER_STATE_FILE"
  else
    printf "anthropic"
  fi
}

# ─── Clean all provider env vars ───────────────────────
_cc_clean_env() {
  # Unset all provider-specific vars to prevent leakage between switches
  unset ANTHROPIC_BASE_URL
  unset ANTHROPIC_AUTH_TOKEN
  unset CLAUDE_CODE_MODEL
  # Set ANTHROPIC_API_KEY to empty — critical for third-party providers
  # Claude Code checks this first; if it has a value, it ignores AUTH_TOKEN
  export ANTHROPIC_API_KEY=""
}

# ─── Switch provider ──────────────────────────────────
cc-use() {
  local provider="$1"

  case "$provider" in
    anthropic|kimi|glm|minimax)
      printf "%s\n" "$provider" > "$CLAUDE_PROVIDER_STATE_FILE"
      _cc_show_banner "$provider"
      ;;
    *)
      echo -e "${_CC_YELLOW}Usage: cc-use {anthropic|kimi|glm|minimax}${_CC_NC}"
      return 1
      ;;
  esac
}

# ─── Apply provider environment ────────────────────────
_cc_apply_provider_env() {
  local provider
  provider="$(_cc_get_provider)"

  # Step 1: Clean slate
  _cc_clean_env

  # Step 2: Load keys from .env
  _cc_load_env_file || return 1

  # Step 3: Configure for selected provider
  case "$provider" in
    anthropic)
      # Restore the real Anthropic key
      if [ -n "${ANTHROPIC_API_KEY:-}" ] && [ "$ANTHROPIC_API_KEY" != "" ]; then
        : # Key already loaded from .env, we're good
      else
        # Re-read just the key
        local anthro_key
        anthro_key="$(grep '^ANTHROPIC_API_KEY=' "$CLAUDE_PROVIDER_ENV_FILE" | cut -d'=' -f2-)"
        if [ -n "$anthro_key" ]; then
          export ANTHROPIC_API_KEY="$anthro_key"
        else
          echo -e "${_CC_YELLOW}⚠️  No ANTHROPIC_API_KEY found. Will use /login or OAuth.${_CC_NC}"
          unset ANTHROPIC_API_KEY
        fi
      fi
      # No custom base URL — use Anthropic's default
      unset ANTHROPIC_BASE_URL
      unset ANTHROPIC_AUTH_TOKEN
      unset CLAUDE_CODE_MODEL
      ;;

    kimi)
      local kimi_key
      kimi_key="${KIMI_API_KEY:-${MOONSHOT_API_KEY:-${KIMI_CODING_API_KEY:-}}}"
      if [ -z "$kimi_key" ]; then
        echo -e "${_CC_RED}❌ Kimi key not found.${_CC_NC}"
        echo -e "${_CC_YELLOW}   Set KIMI_API_KEY in $CLAUDE_PROVIDER_ENV_FILE${_CC_NC}"
        return 1
      fi
      export ANTHROPIC_API_KEY=""
      export ANTHROPIC_AUTH_TOKEN="$kimi_key"
      export ANTHROPIC_BASE_URL="https://api.moonshot.ai/anthropic"
      unset CLAUDE_CODE_MODEL
      ;;

    glm)
      if [ -z "${ZAI_API_KEY:-}" ]; then
        echo -e "${_CC_RED}❌ GLM key not found.${_CC_NC}"
        echo -e "${_CC_YELLOW}   Set ZAI_API_KEY in $CLAUDE_PROVIDER_ENV_FILE${_CC_NC}"
        return 1
      fi
      export ANTHROPIC_API_KEY=""
      export ANTHROPIC_AUTH_TOKEN="$ZAI_API_KEY"
      export ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic"
      export CLAUDE_CODE_MODEL="glm-5"
      ;;

    minimax)
      if [ -z "${MINIMAX_API_KEY:-}" ]; then
        echo -e "${_CC_RED}❌ MiniMax key not found.${_CC_NC}"
        echo -e "${_CC_YELLOW}   Set MINIMAX_API_KEY in $CLAUDE_PROVIDER_ENV_FILE${_CC_NC}"
        return 1
      fi
      export ANTHROPIC_API_KEY=""
      export ANTHROPIC_AUTH_TOKEN="$MINIMAX_API_KEY"
      export ANTHROPIC_BASE_URL="https://api.minimaxi.chat/anthropic"
      unset CLAUDE_CODE_MODEL
      ;;

    *)
      echo -e "${_CC_RED}Unknown provider '$provider'${_CC_NC}"
      return 1
      ;;
  esac
}

# ─── Provider banner/footer ────────────────────────────
_cc_show_banner() {
  local provider="${1:-$(_cc_get_provider)}"
  local icon label color endpoint model

  case "$provider" in
    anthropic)
      icon="🟠" label="ANTHROPIC" color="$_CC_YELLOW"
      endpoint="api.anthropic.com" model="claude-opus/sonnet"
      ;;
    kimi)
      icon="🌙" label="KIMI (Moonshot)" color="$_CC_CYAN"
      endpoint="api.moonshot.ai" model="kimi-k2"
      ;;
    glm)
      icon="🔮" label="GLM-5 (Z.ai)" color="$_CC_MAGENTA"
      endpoint="api.z.ai" model="glm-5"
      ;;
    minimax)
      icon="⚡" label="MINIMAX" color="$_CC_BLUE"
      endpoint="api.minimaxi.chat" model="minimax-text-01"
      ;;
  esac

  echo ""
  echo -e "${_CC_DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${_CC_NC}"
  echo -e "  ${icon}  ${color}${_CC_BOLD}PROVIDER: ${label}${_CC_NC}"
  echo -e "  ${_CC_DIM}Endpoint: ${endpoint}${_CC_NC}"
  echo -e "  ${_CC_DIM}Model:    ${model}${_CC_NC}"
  echo -e "${_CC_DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${_CC_NC}"
  echo ""
}

# ─── Status check ──────────────────────────────────────
cc-status() {
  local provider
  provider="$(_cc_get_provider)"
  _cc_load_env_file 2>/dev/null

  echo ""
  echo -e "${_CC_BOLD}Claude Code Provider Status${_CC_NC}"
  echo -e "${_CC_DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${_CC_NC}"

  # Current provider
  _cc_show_banner "$provider"

  # Key status
  echo -e "${_CC_BOLD}API Key Status:${_CC_NC}"
  local anthro_key kimi_key glm_key minimax_key
  anthro_key="$(grep '^ANTHROPIC_API_KEY=' "$CLAUDE_PROVIDER_ENV_FILE" 2>/dev/null | cut -d'=' -f2-)"
  kimi_key="${KIMI_API_KEY:-${MOONSHOT_API_KEY:-${KIMI_CODING_API_KEY:-}}}"
  glm_key="${ZAI_API_KEY:-}"
  minimax_key="${MINIMAX_API_KEY:-}"

  [ -n "$anthro_key" ] && echo -e "  ${_CC_GREEN}✅${_CC_NC} Anthropic" || echo -e "  ${_CC_RED}❌${_CC_NC} Anthropic"
  [ -n "$kimi_key" ]    && echo -e "  ${_CC_GREEN}✅${_CC_NC} Kimi"      || echo -e "  ${_CC_RED}❌${_CC_NC} Kimi"
  [ -n "$glm_key" ]     && echo -e "  ${_CC_GREEN}✅${_CC_NC} GLM"       || echo -e "  ${_CC_RED}❌${_CC_NC} GLM"
  [ -n "$minimax_key" ] && echo -e "  ${_CC_GREEN}✅${_CC_NC} MiniMax"   || echo -e "  ${_CC_RED}❌${_CC_NC} MiniMax"

  echo ""
  echo -e "${_CC_DIM}Switch: cc-use {anthropic|kimi|glm|minimax}${_CC_NC}"
  echo -e "${_CC_DIM}Launch: cc${_CC_NC}"
  echo ""
}

# ─── Launch Claude Code with provider ──────────────────
cc() {
  _cc_apply_provider_env || return 1
  _cc_show_banner
  command claude "$@"
}

# ─── Shortcut launchers ────────────────────────────────
cc-anthropic() {
  cc-use anthropic || return 1
  cc "$@"
}

cc-kimi() {
  cc-use kimi || return 1
  cc "$@"
}

cc-glm() {
  cc-use glm || return 1
  cc "$@"
}

cc-minimax() {
  cc-use minimax || return 1
  cc "$@"
}
