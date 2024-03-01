#!/usr/bin/env fish

function fish_prompt
    set_color FF0
    echo -n (prompt_pwd)"/> "
    set_color normal
end

if status is-interactive
    # Commands to run in interactive sessions can go here
    set fish_greeting # Disable greeting

    alias copy='cp -i -v'
    alias cls='clear'
    alias cp='cp -i -v'
    alias chrome='chromium --no-sandbox --disable-dev-shm-usage --disable-gpu'
    alias dir='ls -lF --color=auto'
    alias grep='grep --color=auto'
    alias ls='ls --color=auto'
    alias md='mkdir'
    alias move='mv -i -v'
    alias mv='mv -i -v'
    alias rd='rmdir -v'
    alias ren='mv -i -v'
    alias rm='rm -i -v'
    alias rmdir='rmdir -v'
    alias vi='nvim'
    set PATH ~/$REPL_SLUG/bin:$PATH
end

git config --global user.email "naminx@gmail.com"
git config --global user.name "Nawamin M."

if test ! -L /home/runner/.mansuki
    ln -s /home/runner/mansuki/.config/mansuki /home/runner/.mansuki
end

starship init fish | source
