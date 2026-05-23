#Author : Heapbytes <Gourav> (https://github.com/heapbytes)
export VIRTUAL_ENV_DISABLE_PROMPT=true

PROMPT='╭─[%F{blue} %~%f] [%F{green} $(get_ip_address)%f] $(get_git_branch) $(get_venv)
╰─▶ '
# RPROMPT='[%F{red}%?%f]'

get_ip_address() {
  if [[ -n "$(networksetup -getinfo Wi-Fi | grep 'Subnet mask: ')" ]]; then
    echo "%{$fg[green]%}$(ifconfig en0 | awk '/inet / {print $2}')%{$reset_color%}"
  else
    echo "%{$fg[red]%}No IP%{$reset_color%}"
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