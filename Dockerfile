# chameleon-vim
# Vim plugin-for Chameleon Natural Language Code Completion

#FROM ubuntu:14.04
#FROM jare/vim-bundle:latest
#FROM jare/vim-wrapper:latest
FROM jare/vim-pathogen:latest
#FROM jare/alpine-vim:latest
#FROM jare/alpine:latest

#FROM mbrt/vim-rust
#FROM mbrt/rust

# https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/

#If color doesn't show up, you may need to add this in your environment
#ENV TERM=xterm-256color
#ansi needed to work on Docker Quickstart Terminal for Windows
ENV TERM=ansi
ENV DISABLE=""

COPY run /usr/local/bin/
COPY vim/plugin /home/developer/.vim/plugin
COPY docker_build.sh /home/developer/
COPY docker_clean.sh /home/developer/
COPY docker_push.sh /home/developer/
COPY docker_run.sh /home/developer/

#RUN mkdir -p /ext && echo " " > /ext/.vimrc

ENTRYPOINT ["sh", "/usr/local/bin/run"]
#ENTRYPOINT ["vim"]


