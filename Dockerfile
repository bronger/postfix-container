FROM debian:stretch

MAINTAINER Torsten Bronger <bronger@physik.rwth-aachen.de>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y nano procps htop
ENV TERM xterm

RUN apt-get install -y \
    postfix \
    rsyslog \
    supervisor

ENV PORT 587
RUN postconf -e "smtp_sasl_auth_enable=yes" && \
    postconf -e "smtp_sasl_password_maps=hash:/etc/postfix/relay_passwd"

COPY entrypoint.sh heartbeat.sh /
COPY supervisord.conf /etc/supervisor/

ENTRYPOINT ["/entrypoint.sh"]
