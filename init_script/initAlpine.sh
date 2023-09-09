#!/bin/sh

## update
apk update && apk upgrade

## terminal
apk add zsh fish

## editor
apk add vim nano

## web
apk add curl wget

## tmux
apk add tmux
alias inimux='tmux source-file ~/tmux.conf'

echo "end"
