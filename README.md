# chameleon-vim
Natural Language Code Completion for Vim

## Docker Repo
Docker Repo: [https://cloud.docker.com/app/chameleonplugins/repository/docker/chameleonplugins/chameleon-vim-plugins/general](https://cloud.docker.com/app/chameleonplugins/repository/docker/chameleonplugins/chameleon-vim-plugins/general)

## Purpose
This repository contains the code for enabling Natural Language Code
Completion for Vim, using Chameleon.

## Problem Solved
Often someone doesn't know the correct syntax to use
for a given programming language or configuration file type.

## The Solution

With Chameleon-vim, just open or create a new file with
Chameleon for vim, and say what you want to do.  For example,
create a new Dockerfile, and say "start a docker file," and
Chameleon will get you started with some commands and
comments to get you started quickly.

Synonyms are used, so that no matter how you say it,
you should get to where you want to go.  If not,
add the synonym to the Chameleon template, and
help make Chameleon even more user friendly...

## How to use

### Make an alias

`alias edit='docker run -ti --rm -v $(pwd):/home/developer/workspace chameleonplugins/chameleon-vim-plugins'`

### Edit a local file

`edit some.file`

### Getting updates

To get the latest docker updates, run:

`./docker_pull.sh`

## Requirements

This Docker container requires Docker to be installed.  The Docker
image leverages a public vim Docker image, and adds Chameleon
plugin and templates.

## How to build

`./docker_build.sh`

Yes, it's that easy...  Just run the provided ./docker_build.sh script
to build the docker container.

### How to push

`./docker_push.sh`

Yes, there's a script to push the build image to Docker, too.

### How to clean

`./docker_clean.sh`

We have also included a script to remove dangling images.
Use this if `docker images` shows too many <none>:<none>
(dangling) images.

## License

Chameleon is public open source.  See more info on GitHub.

## How to contribute

There are many ways to contribute...  Here are a few...

* Create your own personal templates

* Create templates and submit a pull request

