FROM steamcmd/steamcmd:debian-12

RUN set -x \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y gosu xdg-user-dirs --no-install-recommends\
 && rm -rf /var/lib/apt/lists/* \
 && useradd -ms /bin/bash steam \
 && gosu nobody true

RUN mkdir -p /config \
 && chown steam:steam /config

RUN mkdir -p /game \
 && chown steam:steam /game

COPY init.sh /
COPY --chown=steam:steam run.sh /home/steam

WORKDIR /config

ENV SKIPUPDATE="false" \
    STEAMAPPID="2394010" \
    STEAMUSER="anonymous" \
    STEAMPASSWORD="" \
    STEAM2FA="" \
    GAMEPORT="8221" \
    GAMEPLAYERS="16" \
    MULTITHREAD="true"

EXPOSE 8221/udp

ENTRYPOINT [ "/init.sh" ]