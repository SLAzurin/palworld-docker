#!/bin/bash

set -e

if [[ "${SKIPUPDATE,,}" != "false" ]] && [ ! -f "/game/PalServer.sh" ]; then
    printf "%s Skip update is set, but no game files exist. Updating anyway\\n" "${MSGWARNING}"
    SKIPUPDATE="false"
fi

if [[ "${MULTITHREAD,,}" == "true" ]]; then
    GAMEOPTIONS="-useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS"
fi
if [[ "${SKIPUPDATE,,}" != "true" ]]; then
    
    STORAGEAVAILABLE=$(stat -f -c "%a*%S" .)
    STORAGEAVAILABLE=$((STORAGEAVAILABLE/1024/1024/1024))
    printf "Checking available storage...%sGB detected\\n" "$STORAGEAVAILABLE"

    if [[ "$STORAGEAVAILABLE" -lt 8 ]]; then
        printf "You have less than 8GB (%sGB detected) of available storage to download the game.\\nIf this is a fresh install, it will probably fail.\\n" "$STORAGEAVAILABLE"
    fi

    printf "Downloading the latest version of the game...\\n"
    steamcmd +force_install_dir /game +login "$STEAMUSER" "$STEAMPASSWORD" "$STEAM2FA" +app_update "$STEAMAPPID" validate +quit
else
    printf "Skipping update as flag is set\\n"
fi

if [ ! -L /home/steam/.steam/sdk64 ] ; then
  ln -s /game/linux64/ /home/steam/.steam/sdk64
fi

cd /game || exit 1

exec ./PalServer.sh -port $GAMEPORT -players $GAMEPLAYERS $GAMEOPTIONS "$@"
