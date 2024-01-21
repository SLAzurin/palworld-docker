#!/bin/bash
# Only use with ghcr.io/slazurin/palworld:alpha
set -e

# Force set IDs
PGID=1000
PUID=1000
ROOTLESS=true

CURRENTUID=1000
HOME="/home/steam"
MSGERROR="@@@ !!! ERROR !!! @@@ "
MSGWARNING="@@@ !!! WARNING !!! @@@ "
NUMCHECK='^[0-9]+$'
RAMAVAILABLE=$(awk '/MemAvailable/ {printf( "%d\n", $2 / 1024000 )}' /proc/meminfo)
USER="steam"

if [[ "${DEBUG,,}" == "true" ]]; then
    printf "Debugging enabled (the container will exit after printing the debug info)\\n\\nPrinting environment variables:\\n"
    export

    echo "
System info:
OS:  $(uname -a)
CPU: $(lscpu | grep 'Model name:' | sed 's/Model name:[[:space:]]*//g')
RAM: $(awk '/MemAvailable/ {printf( "%d\n", $2 / 1024000 )}' /proc/meminfo)GB/$(awk '/MemTotal/ {printf( "%d\n", $2 / 1024000 )}' /proc/meminfo)GB
HDD: $(df -h | awk '$NF=="/"{printf "%dGB/%dGB (%s used)\n", $3,$2,$5}')"
    printf "\\nCurrent user:\\n%s" "$(id)"
    printf "\\nProposed user:\\nuid=%s(?) gid=%s(?) groups=%s(?)\\n" "$PUID" "$PGID" "$PGID"
    printf "\\nExiting...\\n"
    exit 1
fi

printf "Checking available memory...%sGB detected\\n" "$RAMAVAILABLE"
if [[ "$RAMAVAILABLE" -lt 8 ]]; then
    printf "${MSGWARNING} You have less than the required 8GB minmum (%sGB detected) of available RAM to run the game server.\\nIt is likely that the server will fail to load properly.\\n" "$RAMAVAILABLE"
fi

# check if the user and group IDs have been set
if [[ "$CURRENTUID" -ne "0" ]] && [[ "${ROOTLESS,,}" != "true" ]]; then
    printf "${MSGERROR} Current user (%s) is not root (0)\\nPass your user and group to the container using the PGID and PUID environment variables\\nDo not use the --user flag (or user: field in Docker Compose) without setting ROOTLESS=true\\n" "$CURRENTUID"
    exit 1
fi

if ! [[ "$PGID" =~ $NUMCHECK ]]; then
    printf "%s Invalid group id given: %s\\n" "$MSGWARNING" "$PGID"
    PGID="1000"
elif [[ "$PGID" -eq 0 ]]; then
    printf "%s PGID/group cannot be 0 (root)\\n" "$MSGERROR"
    exit 1
fi

if ! [[ "$PUID" =~ $NUMCHECK ]]; then
    printf "%s Invalid user id given: %s\\n" "$PUID" "$MSGWARNING"
    PUID="1000"
elif [[ "$PUID" -eq 0 ]]; then
    printf "%s PUID/user cannot be 0 (root)\\n" "$MSGERROR"
    exit 1
fi

if [[ "${ROOTLESS,,}" != "true" ]]; then
    if [[ $(getent group "$PGID" | cut -d: -f1) ]]; then
        usermod -a -G "$PGID" steam
    else
        groupmod -g "$PGID" steam
    fi

    if [[ $(getent passwd "$PUID" | cut -d: -f1) ]]; then
        USER=$(getent passwd "$PUID" | cut -d: -f1)
    else
        usermod -u "$PUID" steam
    fi
fi

printf "\nStarting Server...\n"

if [[ "${ROOTLESS,,}" != "true" ]]; then
    echo Please set "ROOTLESS=true" "PGID=1000" "PUID=1000" env vars
    echo this will not work otherwise
    exit 1
fi

if [[ "${SKIPUPDATE,,}" != "false" ]] && [ ! -f "/home/steam/PalDocker/game/PalServer.sh" ]; then
    printf "%s Skip update is set, but no game files exist. Updating anyway\\n" "${MSGWARNING}"
    SKIPUPDATE="false"
fi

if [[ "${SKIPUPDATE,,}" != "true" ]]; then
    STORAGEAVAILABLE=$(stat -f -c "%a*%S" .)
    STORAGEAVAILABLE=$((STORAGEAVAILABLE / 1024 / 1024 / 1024))
    printf "Checking available storage...%sGB detected\\n" "$STORAGEAVAILABLE"

    if [[ "$STORAGEAVAILABLE" -lt 8 ]]; then
        printf "You have less than 8GB (%sGB detected) of available storage to download the game.\\nIf this is a fresh install, it will probably fail.\\n" "$STORAGEAVAILABLE"
    fi

    printf "Downloading the latest version of the game...\\n"
    /home/steam/steamcmd/steamcmd.sh +force_install_dir /home/steam/PalDocker/game +login "$STEAMUSER" "$STEAMPASSWORD" "$STEAM2FA" +app_update "$STEAMAPPID" validate +quit
else
    printf "Skipping update as flag is set\\n"
fi

if [ ! -L /home/steam/PalDocker/game/linux64 ]; then
    ln -s /home/steam/PalDocker/game/linux64 /home/steam/.steam/sdk64
fi


cd "/home/steam/PalDocker/game" || exit 1
chmod +x ./Pal/Binaries/Linux/PalServer-Linux-Test
./Pal/Binaries/Linux/PalServer-Linux-Test Pal -port 8211 -players "$GAMEPLAYERS" -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS "$@"