FROM debian:12-slim

# Variáveis
ENV ASTERISK_VERSION=18.21.1

# Atualiza e instala dependências
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    git \
    subversion \
    libusb-1.0-0-dev \
    libnewt-dev \
    libssl-dev \
    libasound2-dev \
    libxml2-dev \
    libsqlite3-dev \
    uuid-dev \
    usb-modeswitch \
    psmisc \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Instala o Asterisk
RUN cd /usr/src && \
    wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-${ASTERISK_VERSION}.tar.gz && \
    tar zxvf asterisk-${ASTERISK_VERSION}.tar.gz && \
    cd asterisk-${ASTERISK_VERSION} && \
    contrib/scripts/install_prereq install && \
    ./configure && make menuselect.makeopts && \
    make && make install && make samples && make config

# Instalar chan_dongle
RUN cd /usr/src && \
    git clone https://github.com/bg111/asterisk-chan-dongle.git && \
    cd asterisk-chan-dongle && \
    ./bootstrap && ./configure --with-astversion=18.19.0 && make && make install

# Copiar arquivos de configuração
COPY configs /etc/asterisk/

# Script de inicialização
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 5060/udp 5038 8088

ENTRYPOINT ["/entrypoint.sh"]
