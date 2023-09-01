FROM python:3.11.4-slim-bullseye
ARG MOVIEPILOT_VERSION
ENV LANG="C.UTF-8" \
    HOME="/moviepilot" \
    TERM="xterm" \
    TZ="Asia/Shanghai" \
    PUID=99 \
    PGID=100 \
    UMASK=022 \
    MOVIEPILOT_AUTO_UPDATE=true \
    NGINX_PORT=3000 \
    CONFIG_DIR="/config" \
    API_TOKEN="GQAGKKHLEBTAXSYH" \
    AUTH_SITE="iyuu" \
    IYUU_SIGN="IYUU20553Tdaafb0c109352c8baf815c254a4464f271c0e97a" \
    PROXY_HOST="http://10.0.0.5:6152" \
    DOWNLOAD_PATH="/downloads" \
    DOWNLOAD_MOVIE_PATH="/downloads/mv" \
    DOWNLOAD_TV_PATH="/downloads/tv" \
    DOWNLOAD_ANIME_PATH="/downloads/other" \
    DOWNLOAD_CATEGORY="false" \
    DOWNLOAD_SUBTITLE="false" \
    REFRESH_MEDIASERVER="false" \
    SCRAP_METADATA="true" \
    TORRENT_TAG="MOVIEPILOT" \
    LIBRARY_PATH="/downloads/link" \
    LIBRARY_MOVIE_NAME="mv" \
    LIBRARY_TV_NAME="tv" \
    LIBRARY_ANIME_NAME="other" \
    LIBRARY_CATEGORY="false" \
    TRANSFER_TYPE="link" \
    COOKIECLOUD_HOST="http://10.0.0.5:8088" \
    COOKIECLOUD_KEY="nrV4CNGE47D8c32CfpB9PQ" \
    COOKIECLOUD_PASSWORD="pZuK3DnxuUTCZqB6M7DGsu" \
    MESSAGER="telegram" \
    TELEGRAM_TOKEN="" \
    TELEGRAM_CHAT_ID="" \
    DOWNLOADER="qbittorrent" \
    QB_HOST="10.0.0.5:8080" \
    QB_USER="" \
    QB_PASSWORD="" \
    MEDIASERVER="plex" \
    PLEX_HOST="http://10.0.0.5:32400" \
    PLEX_TOKEN="QBfYepuQYAZz76LXpNrW" \
    BIG_MEMORY_MODE="true"
WORKDIR "/app"
COPY . .
RUN apt-get update \
    && apt-get -y install \
        musl-dev \
        nginx \
        gettext-base \
        locales \
        procps \
        gosu \
        bash \
        wget \
        curl \
        busybox \
        dumb-init \
        jq \
    && \
    if [ "$(uname -m)" = "x86_64" ]; \
        then ln -s /usr/lib/x86_64-linux-musl/libc.so /lib/libc.musl-x86_64.so.1; \
    elif [ "$(uname -m)" = "aarch64" ]; \
        then ln -s /usr/lib/aarch64-linux-musl/libc.so /lib/libc.musl-aarch64.so.1; \
    fi \
    && cp -f /app/nginx.conf /etc/nginx/nginx.template.conf \
    && cp -f /app/update /usr/local/bin/mp_update \
    && cp -f /app/entrypoint /entrypoint \
    && chmod +x /entrypoint /usr/local/bin/mp_update \
    && mkdir -p ${HOME} \
    && groupadd -r moviepilot -g 911 \
    && useradd -r moviepilot -g moviepilot -d ${HOME} -s /bin/bash -u 911 \
    && apt-get install -y build-essential \
    && pip install --upgrade pip \
    && pip install -r requirements.txt \
    && playwright install-deps chromium \
    && python_ver=$(python3 -V | awk '{print $2}') \
    && echo "/app/" > /usr/local/lib/python${python_ver%.*}/site-packages/app.pth \
    && echo 'fs.inotify.max_user_watches=5242880' >> /etc/sysctl.conf \
    && echo 'fs.inotify.max_user_instances=5242880' >> /etc/sysctl.conf \
    && locale-gen zh_CN.UTF-8 \
    && FRONTEND_VERSION=$(curl -sL "https://api.github.com/repos/jxxghp/MoviePilot-Frontend/releases/latest" | jq -r .tag_name) \
    && curl -sL "https://github.com/jxxghp/MoviePilot-Frontend/releases/download/${FRONTEND_VERSION}/dist.zip" | busybox unzip -d / - \
    && mv /dist /public \
    && apt-get remove -y build-essential \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf \
        /tmp/* \
        /moviepilot/.cache \
        /var/lib/apt/lists/* \
        /var/tmp/*
EXPOSE 3000
VOLUME ["/config"]
ENTRYPOINT [ "/entrypoint" ]
