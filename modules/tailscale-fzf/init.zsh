FZF_TAILSCALE_COMMAND="tailscale"

tailscale-ssh-select-widget() {
  [[ "$LBUFFER" =~ ^ssh.* ]] || return 0

  local cmd mt_status candidates selected

  # Prefer the live multitail daemon when available and authorized.
  if (( $+commands[tsmultitail] && $+commands[jq] )) &&
    mt_status=$(tsmultitail status --json 2>/dev/null); then

  candidates=$(
    print -r -- "$mt_status" |
      jq -r '
    .targets[]
    | select(.kind == "node" and .online == true and .fqdn != null)
    | "[\(.profile_name)]\t\(.canonical_ip)\t\(.fqdn | sub("\\.$"; ""))"
    '
  )

  selected=$(print -r -- "$candidates" | fzf)
  cmd=$(print -r -- "$selected" | awk '{ print $3 }')

elif (( $+commands[$FZF_TAILSCALE_COMMAND] )); then
  # Native Tailscale fallback.
  cmd=$(
    "$FZF_TAILSCALE_COMMAND" status |
      awk '$5 != "offline"' |
      fzf |
      awk '{ print $2 }'
    )
  else
    return 0
  fi

  [[ -n "$cmd" ]] || return 0

  LBUFFER+=" "
  RBUFFER="@${cmd}${RBUFFER}"
  zle reset-prompt
}

zle -N tailscale-ssh-select-widget
bindkey -M emacs '^S' tailscale-ssh-select-widget
bindkey -M vicmd '^S' tailscale-ssh-select-widget
bindkey -M viins '^S' tailscale-ssh-select-widget
