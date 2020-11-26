FROM debian:stretch as builder

MAINTAINER Torsten Bronger <bronger@physik.rwth-aachen.de>

ARG TERM=linux
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get dist-upgrade -y --no-install-recommends --autoremove && \
    apt-get install -y \
    cmake \
    g++ \
    libboost-filesystem-dev \
    libboost-program-options-dev \
    libboost-system-dev \
    libmilter-dev \
    libssl-dev

ENV SIGH_VERSION=1607.1.6

ADD "https://github.com/croessner/sigh/archive/v${SIGH_VERSION}.tar.gz" /tmp/
COPY install-sigh.sh /
RUN /install-sigh.sh "${SIGH_VERSION}"


FROM python:3.6-slim-stretch

MAINTAINER Torsten Bronger <bronger@physik.rwth-aachen.de>

ARG TERM=linux
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get dist-upgrade -y --no-install-recommends --autoremove && \
    apt-get install -y \
    ca-certificates \
    g++ \
    libboost-filesystem1.62.0 \
    libboost-program-options1.62.0 \
    libboost-system1.62.0 \
    libmilter1.0.1 \
    libsasl2-modules \
    libssl1.1 \
    locales \
    postfix \
    rsyslog \
    supervisor \
    tzdata \
    && rm -rf /var/lib/apt/lists/* && \
    pip3 --no-cache-dir install psutil && \
    apt-get purge -y --autoremove g++
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV TZ=UTC

ENV RELAY_PORT=587
RUN adduser filter --disabled-login --gecos ""

ENV SIGH_ROOT=/var/lib/sigh
COPY --from=builder /usr/local/sbin/sigh /usr/local/sbin/
RUN mkdir /etc/sigh
COPY sigh.cfg /etc/sigh/
RUN mkdir "$SIGH_ROOT"; chown filter "$SIGH_ROOT"

RUN postconf -e "smtp_sasl_auth_enable=yes" && \
    postconf -e "smtp_use_tls=yes" && \
    postconf -e "smtp_tls_CAfile=/etc/ssl/certs/ca-certificates.crt" && \
    postconf -e "smtp_sasl_tls_security_options=noanonymous" && \
    postconf -e "smtp_sasl_password_maps=hash:/etc/postfix/relay_passwd" && \
    postconf -e "mynetworks=127.0.0.0/8 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 [::ffff:127.0.0.0]/104 [::1]/128" && \
    postconf -e "smtpd_milters=inet:localhost:4000" && \
    postconf -M "submission/inet=submission inet n - n - - smtpd"

COPY supervisord.conf /etc/supervisor/
COPY entrypoint.sh configure_sigh.py kill_supervisor.py postfix.sh rsyslog.sh /

ENTRYPOINT ["/entrypoint.sh"]
