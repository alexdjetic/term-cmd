#!/bin/sh

## update
apt update update && apt upgrade -y

## terminal
apt install zsh fish

## editor
apt install vim nano neovim

## web
apt install curl wget

## tmux
apt install tmux
alias inimux='tmux source-file ~/tmux.conf'

echo "end"
