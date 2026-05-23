#Author : Heapbytes <Gourav> (https://github.com/heapbytes)


PROMPT='╭─[%F{blue} %~%f] [%F{green} $(get_ip_address)%f] $(get_git_branch) $(get_venv)
╰─▶ '

RPROMPT='[%F{red}%?%f]'

get_ip_address() {
  local ip
  if [[ "$(uname)" =~ "Linux" ]]; then
    # WSLでのIPアドレス取得（WindowsホストマシンのIP）
    ip=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')
    echo "%{$fg[green]%}${ip}%{$reset_color%}"
  else
    if [[ "$(uname -r)" == "WSL" ]]; then
      # WSLでのIPアドレス取得（WindowsホストマシンのIP）
      ip=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')
      echo "%{$fg[green]%}${ip}%{$reset_color%}"
    else
      # 通常のLinux環境でのIPアドレス取得
      if [[ -n "$(ifconfig tun0 2>/dev/null)" ]]; then
        ip=$(ifconfig tun0 | awk '/inet / {print $2}')
      elif [[ -n "$(ifconfig wlan0 2>/dev/null)" ]]; then
        ip=$(ifconfig wlan0 | awk '/inet / {print $2}')
      else
        ip="No IP"
      fi
      echo "%{$fg[green]%}${ip}%{$reset_color%}"
    fi
  fi
}

get_git_branch() {
  local branch_name
  branch_name=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [[ -n "$branch_name" ]]; then
    echo "(%F{magenta}%{$fg[blue]%} %{$fg[blue]%}${branch_name}%{$reset_color%})"
  fi
}

get_venv() {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    echo "(%F{green} %{$fg[green]%}$(basename ${VIRTUAL_ENV})%{$reset_color%})"
  fi
}