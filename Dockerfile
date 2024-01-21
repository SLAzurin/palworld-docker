FROM cm2network/steamcmd:latest
USER steam

RUN mkdir -p /home/steam/PalDocker/config \
 && chown steam:steam /home/steam/PalDocker/config

RUN mkdir -p /home/steam/PalDocker/game \
 && chown steam:steam /home/steam/PalDocker/game

COPY --chown=steam:steam ./init.sh /home/steam/PalDocker/

WORKDIR /home/steam/PalDocker

ENV SKIPUPDATE="false" \
    STEAMAPPID="2394010" \
    STEAMUSER="anonymous" \
    STEAMPASSWORD="" \
    STEAM2FA="" \
    GAMEPLAYERS="16"

EXPOSE 8211/udp

ENTRYPOINT [ "bash" ]
CMD [ "-c", "/home/steam/PalDocker/init.sh" ]