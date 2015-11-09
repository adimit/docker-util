FROM debian:jessie

MAINTAINER Aleksandar Dimitrov <aleks.dimitrov@gmail.com>

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y zsh git tmux php5-cli \
    netcat curl wget telnet nmap vim mysql-client postgresql-client

COPY zshrc /root/.zshrc
CMD /usr/bin/zsh
