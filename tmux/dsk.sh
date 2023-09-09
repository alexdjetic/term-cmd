#!/bin/sh
iniTmux='tmux source-file /home/oem/conf/tmux.conf'
alias iniTmux=$iniTmux
tmux new-session -s main -n dev -c /home/oem
