#!/usr/bin/env bash

# Claude Code Multi-Provider Switcher
# Seamlessly switch between Anthropic, Kimi, GLM, and MiniMax APIs

CLAUDE_PROVIDER_STATE_FILE="${CLAUDE_PROVIDER_STATE_FILE:-$HOME/.claude/provider.current}"
CLAUDE_PROVIDER_ENV_FILE="${CLAUDE_PROVIDER_ENV_FILE:-$HOME/.claude/.env}"

_cc_load_env_file() {
  if [ -f "$CLAUDE_PROVIDER_ENV_FILE" ]; then
    set -a
    . "$CLAUDE_PROVIDER_ENV_FILE"
    set +a
  fi
}

_cc_get_provider() {
  if [ -f "$CLAUDE_PROVIDER_STATE_FILE" ]; then
    tr -d '[:space:]' < "$CLAUDE_PROVIDER_STATE_FILE"
  else
    printf "anthropic"
  fi
}

cc-use() {
  local provider="$1"

  case "$provider" in
    anthropic|kimi|glm|minimax)
      printf "%s\n" "$provider" > "$CLAUDE_PROVIDER_STATE_FILE"
      printf "Claude provider set to: %s\n" "$provider"
      ;;
    *)
      echo "Usage: cc-use {anthropic|kimi|glm|minimax}"
      return 1
      ;;
  esac
}

_cc_apply_provider_env() {
  local provider
  provider="$(_cc_get_provider)"

  _cc_load_env_file

  case "$provider" in
    anthropic)
      unset ANTHROPIC_BASE_URL
      if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
        export ANTHROPIC_AUTH_TOKEN="$ANTHROPIC_API_KEY"
      else
        unset ANTHROPIC_AUTH_TOKEN
        echo "Warning: ANTHROPIC_API_KEY is not set. Run /login in Claude Code or add ANTHROPIC_API_KEY to $CLAUDE_PROVIDER_ENV_FILE."
      fi
      ;;
    kimi)
      local kimi_key
      kimi_key="${KIMI_API_KEY:-${MOONSHOT_API_KEY:-${KIMI_CODING_API_KEY:-}}}"
      if [ -z "$kimi_key" ]; then
        echo "Kimi key not found. Set KIMI_API_KEY (or MOONSHOT_API_KEY) in $CLAUDE_PROVIDER_ENV_FILE."
        return 1
      fi
      unset ANTHROPIC_API_KEY
      export ANTHROPIC_AUTH_TOKEN="$kimi_key"
      export ANTHROPIC_BASE_URL="https://api.moonshot.ai/anthropic"
      ;;
    glm)
      if [ -z "${ZAI_API_KEY:-}" ]; then
        echo "GLM key not found. Set ZAI_API_KEY in $CLAUDE_PROVIDER_ENV_FILE."
        return 1
      fi
      unset ANTHROPIC_API_KEY
      export ANTHROPIC_AUTH_TOKEN="$ZAI_API_KEY"
      export ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic"
      export CLAUDE_CODE_MODEL="glm-5"
      ;;
    minimax)
      if [ -z "${MINIMAX_API_KEY:-}" ]; then
        echo "MiniMax key not found. Set MINIMAX_API_KEY in $CLAUDE_PROVIDER_ENV_FILE."
        return 1
      fi
      unset ANTHROPIC_API_KEY
      export ANTHROPIC_AUTH_TOKEN="$MINIMAX_API_KEY"
      export ANTHROPIC_BASE_URL="https://api.minimaxi.chat/anthropic"
      ;;
    *)
      echo "Unknown provider '$provider'. Use: cc-use {anthropic|kimi|glm|minimax}"
      return 1
      ;;
  esac
}

cc-status() {
  local provider
  local anthropic_ok="no"
  local kimi_ok="no"
  local glm_ok="no"
  local minimax_ok="no"

  provider="$(_cc_get_provider)"
  _cc_load_env_file

  [ -n "${ANTHROPIC_API_KEY:-}" ] && anthropic_ok="yes"
  [ -n "${KIMI_API_KEY:-${MOONSHOT_API_KEY:-${KIMI_CODING_API_KEY:-}}}" ] && kimi_ok="yes"
  [ -n "${ZAI_API_KEY:-}" ] && glm_ok="yes"
  [ -n "${MINIMAX_API_KEY:-}" ] && minimax_ok="yes"

  echo "Current provider: $provider"
  echo "Anthropic key configured: $anthropic_ok"
  echo "Kimi key configured: $kimi_ok"
  echo "GLM key configured: $glm_ok"
  echo "MiniMax key configured: $minimax_ok"
}

cc() {
  _cc_apply_provider_env || return 1
  command claude "$@"
}

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
