FROM ubuntu:16.04
MAINTAINER Kristian Haugene

VOLUME /data
VOLUME /config

# Update packages and install software
RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install software-properties-common wget git \
    && add-apt-repository ppa:transmissionbt/ppa \
    && wget -O - https://swupdate.openvpn.net/repos/repo-public.gpg | apt-key add - \
    && echo "deb http://build.openvpn.net/debian/openvpn/stable xenial main" > /etc/apt/sources.list.d/openvpn-aptrepo.list \
    && apt-get update \
    && apt-get install -y sudo transmission-cli transmission-common transmission-daemon curl rar unrar zip unzip ufw iputils-ping openvpn \
    && wget https://github.com/Secretmapper/combustion/archive/release.zip \
    && unzip release.zip -d /opt/transmission-ui/ \
    && rm release.zip \
    && git clone git://github.com/endor/kettu.git /opt/transmission-ui/kettu \
    && wget https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64.deb \
    && dpkg -i dumb-init_1.2.0_amd64.deb \
    && rm -rf dumb-init_1.2.0_amd64.deb \
    && curl -L https://github.com/jwilder/dockerize/releases/download/v0.5.0/dockerize-linux-amd64-v0.5.0.tar.gz | tar -C /usr/local/bin -xzv \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && groupmod -g 1000 users \
    && useradd -u 911 -U -d /config -s /bin/false abc \
    && usermod -G users abc \
    # Custom setup for QNAP devices
    && sudo mkdir -p /dev/net \
    && sudo mknod /dev/net/tun c 10 200 \
    && sudo chmod 600 /dev/net/tun

ADD openvpn/ /etc/openvpn/
ADD transmission/ /etc/transmission/

ENV OPENVPN_USERNAME=**None** \
    OPENVPN_PASSWORD=**None** \
    OPENVPN_PROVIDER=**None** \
    TRANSMISSION_DOWNLOAD_DIR=/data/completed \
    TRANSMISSION_DOWNLOAD_LIMIT_ENABLED=0 \
    TRANSMISSION_DOWNLOAD_QUEUE_ENABLED=true \
    TRANSMISSION_DOWNLOAD_QUEUE_SIZE=5 \
    TRANSMISSION_ENCRYPTION=1 \
    TRANSMISSION_INCOMPLETE_DIR=/data/incomplete \
    TRANSMISSION_INCOMPLETE_DIR_ENABLED=true \
    TRANSMISSION_RENAME_PARTIAL_FILES=true \
    TRANSMISSION_RPC_AUTHENTICATION_REQUIRED=false \
    TRANSMISSION_RPC_BIND_ADDRESS=0.0.0.0 \
    TRANSMISSION_RPC_ENABLED=true \
    TRANSMISSION_RPC_PASSWORD=password \
    TRANSMISSION_RPC_PORT=9091 \
    TRANSMISSION_RPC_USERNAME=username \
    TRANSMISSION_RPC_WHITELIST_ENABLED=false \
    TRANSMISSION_SEED_QUEUE_ENABLED=false \
    TRANSMISSION_START_ADDED_TORRENTS=true \
    TRANSMISSION_TRASH_ORIGINAL_TORRENT_FILES=false \
    TRANSMISSION_UMASK=2 \
    TRANSMISSION_WATCH_DIR=/data/watch \
    TRANSMISSION_WATCH_DIR_ENABLED=true \
    TRANSMISSION_HOME=/data/transmission-home \
    ENABLE_UFW=false \
    TRANSMISSION_WEB_UI= \

# Expose port and run
EXPOSE 9091
CMD ["dumb-init", "/etc/openvpn/start.sh"]
