
# Dockerized LunarVim 

Here you have more info about lunarvim:  https://www.lunarvim.org/docs/installation

This is a dockerized version of LunarVim

## Why
Cause we live in a world where people is freaked out or too lazy to update their systems, or they live in a too restrictive systems


## How to run:

For running just:
`docker run -it --rm patovala/docker-lunarvim lvim`

With volumes attached and oh-my-zsh:
`docker run -it -v $(pwd):/home/patovala/src patovala/docker-lunarvim zsh`

Also you can create a nice alias to run it automatically

`alias lvim='docker run -it -v $(pwd):/home/patovala/src lvim'`
