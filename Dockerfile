FROM shadowsocks/shadowsocks-libev
WORKDIR /etc/shadowsocks
COPY v2ray-plugin_linux_amd64 /etc/shadowsocks/
COPY Shadowsocks.json /etc/shadowsocks/
VOLUME /ect/shadowsocks

#### Port variable is defined in the script ####
EXPOSE SSPort/tcp
EXPOSE SSPort/udp

CMD ss-server -c /etc/shadowsocks/shadowsocks.json
