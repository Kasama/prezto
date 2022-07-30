setup_auto_dir_switch() {
  local cwdir_instructions_file=/tmp/auto-dir-switch.cfg
  local src=$1
  local dst=$2

  printf "$src\n$dst" >| "$cwdir_instructions_file"
}

TRAPUSR2() {
  local cwdir_instructions_file=/tmp/auto-dir-switch.cfg
  if [ -f "$cwdir_instructions_file" ]; then
    local dir_src=$(sed -n '1p' "$cwdir_instructions_file")
    local dir_dst=$(sed -n '2p' "$cwdir_instructions_file")

    if [[ -n "$dir_src" ]] && [[ -n "$dir_dst" ]]; then

      if [[ $PWD == "$dir_src"* ]]; then
        # echo "You fell for my trap! 1: $dir_src, 2: $dir_dst, pwd: $PWD"
        cd "$dir_dst"
      # else
      #   echo "You didnt fall for my trap! 1: $dir_src, 2: $dir_dst, pwd: $PWD"
      fi
    fi
  fi
}
