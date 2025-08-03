FROM debian:12 AS builder

LABEL maintainer="Torsten Bronger <bronger@physik.rwth-aachen.de>"

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

ENV SIGH_VERSION=1607.1.6-tb5

ADD "https://github.com/bronger/sigh/archive/v${SIGH_VERSION}.tar.gz" /tmp/
COPY install-sigh.sh /
RUN /install-sigh.sh "${SIGH_VERSION}"


FROM debian:12

LABEL maintainer="Torsten Bronger <bronger@physik.rwth-aachen.de>"

ARG TERM=linux
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get dist-upgrade -y --no-install-recommends --autoremove && \
    apt-get install --no-install-recommends -y \
    ca-certificates \
    libboost-filesystem1.74.0 \
    libboost-program-options1.74.0 \
    libboost-system1.74.0 \
    libmilter1.0.1 \
    libsasl2-modules \
    locales \
    postfix \
    python-is-python3 \
    python3 \
    python3-pip \
    supervisor \
    telnet \
    tzdata \
    && rm -rf /var/lib/apt/lists/*
ENV PIP_BREAK_SYSTEM_PACKAGES=1
RUN apt-get update && apt-get install --no-install-recommends -y \
    g++ && \
    pip3 --disable-pip-version-check --no-cache-dir install psutil && \
    apt-get purge -y --autoremove g++ && \
    rm -rf /var/lib/apt/lists/*
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV TZ=UTC

ENV RELAY_PORT=587
RUN adduser filter --disabled-login --comment ""

ENV SIGH_ROOT=/var/lib/sigh
COPY --from=builder /usr/local/sbin/sigh /usr/local/sbin/
RUN mkdir /etc/sigh
COPY sigh.cfg /etc/sigh/
RUN mkdir "$SIGH_ROOT"; chown filter "$SIGH_ROOT"

RUN postconf -e "smtp_sasl_auth_enable=yes" && \
    postconf -e "smtp_tls_security_level=may" && \
    postconf -e "smtp_sasl_mechanism_filter=!ntlm,static:rest" && \
    postconf -e "smtp_tls_CAfile=/etc/ssl/certs/ca-certificates.crt" && \
    postconf -e "smtp_sasl_tls_security_options=noanonymous" && \
    postconf -e "smtp_sasl_password_maps=hash:/etc/postfix/relay_passwd" && \
    postconf -e "mynetworks=127.0.0.0/8 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 [::ffff:127.0.0.0]/104 [::1]/128" && \
    postconf -e "smtpd_milters=inet:localhost:4000" && \
    postconf -e "smtpd_tls_security_level=none" && \
    postconf -e "local_header_rewrite_clients=permit_mynetworks" && \
    postconf -M "submission/inet=submission inet n - n - - smtpd" && \
    postconf -M "smtp/unix=smtp unix - - n - - smtp"

COPY supervisord.conf /etc/supervisor/
COPY kill_supervisor.py /
COPY entrypoints /opt/entrypoints
COPY send_test_mail.py /usr/local/bin/

ENTRYPOINT ["/opt/entrypoints/entrypoint.sh"]
