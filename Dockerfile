FROM debian:12-slim

ENV ASTERISK_VERSION=18.26.4

RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    git \
    subversion \
    libedit-dev \
    uuid-dev \
    libjansson-dev \
    libxml2-dev \
    libsqlite3-dev \
    libncurses5-dev \
    libssl-dev \
    libnewt-dev \
    libusb-1.0-0-dev \
    usb-modeswitch \
    psmisc \
    curl \
    pkg-config \
    xmlstarlet \
    python3 \
    python3-dev \
    libcurl4-openssl-dev \
    libspeex-dev \
    libsrtp2-dev \
    libogg-dev \
    libvorbis-dev \
    libspandsp-dev \
    libgsm1-dev \
    libiksemel-dev \
    libneon27-gnutls-dev \
    libusb-dev \
    && rm -rf /var/lib/apt/lists/*

RUN cd /usr/src && \
    wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-${ASTERISK_VERSION}.tar.gz && \
    tar zxvf asterisk-${ASTERISK_VERSION}.tar.gz && \
    cd asterisk-${ASTERISK_VERSION} && \
    ./configure --with-jansson-bundled && \
    make menuselect.makeopts && \
    make -j$(nproc) && make install && \
    make samples && make config

RUN cd /usr/src && \
    git clone https://github.com/bg111/asterisk-chan-dongle.git && \
    cd asterisk-chan-dongle && \
    ./bootstrap && ./configure && \
    make && make install

COPY configs /etc/asterisk/
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 5060/udp 5038 8088

ENTRYPOINT ["/entrypoint.sh"]
