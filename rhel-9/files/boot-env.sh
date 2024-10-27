#!/bin/bash

export ANSIBLE_DEPRECATION_WARNINGS=False
export AWS_PAGER=""
export PROMPT_COMMAND='$(history -w)'
export HISTSIZE=10000
export HISTTIMEFORMAT="%d/%m/%y %T "
export SYSTEMD_PAGER=cat
export ANSIBLE_FORCE_COLOR=1
alias gp="git pull &>/dev/null"
alias vi=vim
alias S='sudo -i'
alias gp='git pull'
alias gs='git stash'
alias A='alias | grep -v grep'
[ -f '/tmp/labautomation/.boot-env.sh' ] && source /tmp/labautomation/.boot-env.sh
