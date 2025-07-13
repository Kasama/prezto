FZF_TAILSCALE_COMMAND="tailscale"

if [[ -z $commands[${FZF_TAILSCALE_COMMAND}] ]]; then
  return 0
fi

tailscale-ssh-select-widget() {
  if [[ ! "$LBUFFER" =~ ^"ssh".* ]]; then
    return 0
  fi

  CMD=$(tailscale status | awk '$5 != "offline"' | fzf | awk '{ print $2 }')

  LBUFFER="${LBUFFER} "
  RBUFFER="@${CMD}${RBUFFER}"
  zle reset-prompt
  return 0
}

if [[ "${FZF_TAILSCALE_COMMAND}" != "" ]]; then
  zle     -N            tailscale-ssh-select-widget
  bindkey -M emacs '^S' tailscale-ssh-select-widget
  bindkey -M vicmd '^S' tailscale-ssh-select-widget
  bindkey -M viins '^S' tailscale-ssh-select-widget
fi
