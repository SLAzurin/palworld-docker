# qmarchi/palworld

A simple docker container to download and run the Dedicated Palworld Server

## Setup

### Environment Variables (Optional)

| Variable      | Default Value | Description                                                   |
| ------------- | ------------- | ------------------------------------------------------------- |
| SKIPUPDATE    | false         | Bypasses `steamcmd` and directly runs the game.               |
| STEAMUSER     | anonymous     | Defines a login user for `steamcmd`                           |
| STEAMPASSWORD | <blank>       | Defines a login password for `steamcmd`                       |
| STEAM2FA      | <blank>       | Defines a login 2fa for `steamcmd`                            |
| GAMEPLAYERS   | 16            | Sets the maximum number of players that the server will allow |

### Mounts (Highly Recommended)

| Location                   | Description          |
| -------------------------- | -------------------- |
| /home/steam/PalDocker/game | The Root Game Folder |

## Docker Source

Source for this Docker container is available at: here!
