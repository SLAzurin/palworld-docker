# qmarchi/palworld

A simple docker container to download and run the Dedicated Palworld Server

## Setup

### Environment Variables (Optional)

| Variable        | Default Value | Description                                                                                                                     |
| --------------- | ------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| SKIPUPDATE      | false         | Bypasses `steamcmd` and directly runs the game.                                                                                 |
| STEAMUSER       | anonymous     | Defines a login user for `steamcmd`                                                                                             |
| STEAMPASSWORD   | <blank>       | Defines a login password for `steamcmd`                                                                                         |
| STEAM2FA        | <blank>       | Defines a login 2fa for `steamcmd`                                                                                              |
| GAMEPORT        | 8211          | Sets the port that the game runs inside the container                                                                           |
| GAMEPLAYERS     | 16            | Sets the maximum number of players that the server will allow                                                                   |
| MULTITHREAD     | true          | Enabled the [recommended](https://tech.palworldgame.com/dedicated-server-guide#settings) server options for multi-threaded CPUs |
| DISCORD_WEBHOOK | <blank>       | Posts startup status in a discord webhook                                                                                       |

### Mounts (Highly Reccomended)

| Location | Description          |
| -------- | -------------------- |
| /game    | The Root Game Folder |

## Docker Source

Source for this Docker container is available at: here!
