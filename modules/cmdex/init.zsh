# cmdex zsh plugin (MVP)
#
# Usage:
#   source /path/to/cmdex.plugin.zsh
#   bindkey '^x^e' cmdex
#
# Then type an instruction in your prompt and press the keybinding.
# cmdex will run its interactive TUI for clarifications and, on success,
# will replace the current BUFFER with the generated shell command.

# Allow overriding the cmdex binary location.
: "${CMDEX_BIN:=cmdex}"

function __cmdex_zsh_helper() {
  emulate -L zsh
  setopt localoptions noshwordsplit

  local instruction="$BUFFER"

  # Run cmdex. It may open a full-screen TUI.
  local out
  out=$("$CMDEX_BIN" -- "$instruction")
  local code=$?

  if [[ $code -eq 0 ]]; then
    BUFFER="$out"
    CURSOR=${#BUFFER}
    zle reset-prompt
    return 0
  fi

  if [[ $code -eq 3 ]]; then
    # Blocked by safety filter. cmdex prints JSON to stdout.
    zle -M "cmdex: blocked (see output / rerun in terminal)"
    return 3
  fi

  zle -M "cmdex: failed ($code)"
  return $code
}

zle -N __cmdex_zsh_helper
bindkey '^x' __cmdex_zsh_helper
