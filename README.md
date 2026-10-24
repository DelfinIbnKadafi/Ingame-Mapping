# Ingame Mapping

Ingame Mapping is a filterscripts for samp/openmp gamemode. Usually we use another gamemode/server only for making a new mapping,
but with Ingame Mapping, you can make mapping in your real time server, so all system, mapping, and all things in your server
will show in the Ingame Mapping. Beside mapping in game, your mapping also exported to txt files and fill with `CreateObject` function.

## Reqruirments

a_samp or open.mp and basic library usually use for samp/open.mp.
Pawncc if you want to recompile.
zcmd.
streamer.

## Installation

First clone this repository or install the latest version in the tab release.

In the folder of repository/latest version, you will seeing some pwn and one amx file. If you want to recompile it, you can compile
the INGAME.pwn with pawncc and copy/move the amx file to your filterscript folder. Else if you just want to add Ingame Mapping to
the server without any recompile, just move/copy the INGAME.amx file to your server filescripts folder.

After add INGAME.amx to your filterscripts folder, open your server.cfg or config.json and go to the `filterscripts` argument, and add
INGAME in the argument.

Example :

**Open MP config.json**

```json
"side_scripts": [
    "INGAME"
]
```

**SA-MP server.cfg**

```cfg
filterscripts INGAME
```

And then run your server like normally, makesure the INGAME.amx is exist in filterscripts folder.

## Features

| Features Name | Descriptions |
| ------------- | ------------ |
| Ingame Mapping | Mapping object ingame |
| Database Save | If you make new mapping, and you forgot to export the mapping, server will create db files for save the mapping, you can also use /savemap to make the db save files |
| Export Mapping | You can export mapping using /exportmap, and server will make txt files with CreateObject functions inside the files |
| Import Mapping | You can import your db files or txt files for import a mpping, make sure the format of txt and db files is valid |

## Commands List

| Commands | Descriptions |
| -------- | ------------ |
| /newmap | Make new mapping |
| /closemap | Close mapping map |
| /loadmap | Loda mapping from db files |
| /exportmap | Export your map into txt file |
| /importmap | Import mapping from txt files |
| /newobject | Make new object |
| /editobject | Edit object postion and rotation |
| /deleteobject | Delete object |
| /toggleid | Toggle 3d text id for object id |

And for another commands see in /help.

## Contribute and License

This project is open source, you can make fork and pull request for contribute.

MIT License.
