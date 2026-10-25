# Ingame Mapping

Ingame Mapping is a filterscripts for samp/openmp gamemode. Usually we use another gamemode/server only for making a new mapping,
but with Ingame Mapping, you can make mapping in your real time server, so all system, mapping, and all things in your server
will show while you make the mapping. Beside mapping ingame, your mapping also exported to txt files with `CreateDynamicObject` functions.

## Requirements

- SA-MP 0.3.7 or open.mp server, with SQLite database support.
- Streamer plugin, matching the included `streamer.inc`.
- zcmd include, already in the includes folder.
- Pawn compiler 3.10.10 if you want to recompile.

This script dont need MySQL or sscanf plugin. SQLite is already provided by the server.
The included open.mp headers are used for both builds. The SA-MP build use old native names through `src/COMPAT.pwn`.

## Installation

1. Choose the AMX for your server:
   - open.mp: copy `src/INGAME.amx` to server `filterscripts/INGAME.amx`.
   - SA-MP: copy `src/INGAME_SAMP.amx` to server `filterscripts/INGAME_SAMP.amx`.
2. Copy the `scriptfiles/ingame_mapping` folder into your server `scriptfiles` folder. Keep the `save` and `exported` subfolders.
3. Load the Streamer plugin in your server config.
4. Add the matching filterscript name, then run your server like normally.

open.mp also try to create the data folders at filterscript init. For SA-MP you must copy/create the folders first.
Server must have write permission in these folders.

### Open.mp config.json

In the existing `pawn` section, add `INGAME` to `side_scripts`. Keep your other scripts.

```json
"side_scripts": [
    "INGAME"
]
```

Also keep Streamer loaded in `pawn.legacy_plugins`.

### SA-MP server.cfg

Add `INGAME_SAMP` to the existing filterscripts line. Keep your other filterscripts and plugins.

```cfg
filterscripts INGAME_SAMP
```

Dont use the open.mp AMX on SA-MP, because the database and edit native names are different.

## Compile

Compile `src/INGAME.pwn`, not the modular files separately.
Run these commands from the project root. Change `pawncc` to your compiler path if needed.

### Open.mp

```sh
pawncc src/INGAME.pwn -iincludes -osrc/INGAME.amx "-;+" "-(+" -d3 -C- -E+
```

### SA-MP

```sh
pawncc src/INGAME.pwn -iincludes -osrc/INGAME_SAMP.amx INGAME_SAMP=1 "-;+" "-(+" -d3 -C- -E+
```

If your compiler cant find the modular files, run from `src` instead:

```sh
pawncc INGAME.pwn -i../includes -oINGAME.amx "-;+" "-(+" -d3 -C- -E+
```

For SA-MP add `INGAME_SAMP=1` and change output to `INGAME_SAMP.amx`.
`-C-` make uncompressed AMX files. Both build use the same mapping code.
VS Code build tasks are included for both targets; change the compiler command to your own compiler path.

## Features

| Features Name | Descriptions |
| ------------- | ------------ |
| Ingame Mapping | Create, edit, and delete object ingame |
| Shared Map | One map opened for the whole server, all players can use the commands |
| Database Save | Every new object, confirmed edit, and delete is saved directly to SQLite |
| Extra Save | Also save on player disconnect, /savemap, /closemap, and normal filterscript/server shutdown |
| Export Mapping | /exportmap make txt with CreateDynamicObject, current player name in header and filename |
| Import Mapping | /loadmap open saved db, /importmap read supported txt into a new db |
| Object ID | /toggleid show or hide object id labels for all players |
| Shared Editor | One object can only edited by one player at the same time |
| Object Slots | Max 1000 objects, id start from 1 to 1000, deleted id can use again |

All players share the same opened map. If someone use /closemap, it close the map for everyone.
Different players can edit different objects at the same time.
Objects are visible in all virtual worlds and interiors, same like the original script.

## Commands List

| Commands | Descriptions |
| -------- | ------------ |
| /newmap <mapname> | Create new empty map and its db file, existing db wont be overwritten |
| /closemap | Save and close the shared map, remove its ingame objects and labels |
| /loadmap <mapname> | Open map from save folder, without .db extension |
| /savemap | Save all curently objects to db |
| /exportmap | Export the opened map with your current player name |
| /importmap <txtname> <newmapname> | Import txt from exported folder into a new map, without extensions |
| /newobject <modelid> | Create object near your player position |
| /editobject <index> | Edit position and rotation, must in radius 50 of the object |
| /deleteobject <index> | Delete object and its saved row |
| /toggleid | Toggle object id labels for everyone |
| /help | Show mapping commands |
| /mappinghelp | Another name for mapping help |

The filterscript also registers `/help`. If your gamemode already have `/help`, you can rename/remove this command in `COMMANDS.pwn`; `/mappinghelp` is also available.

Map name only use `A-Z`, `a-z`, `0-9`, `_`, and `-`, max 63 character.
Txt source name use the same characters, max 127 character, without `.txt`.

### Example

```text
/newmap house
/newobject 12982
/editobject 1
/savemap
/exportmap
/closemap
/loadmap house
```

Click the editor save button to confirm an edit. Cancel/ESC return the object to its last saved position.
Unconfirmed preview is not written to database. Disconnect, death, or closing map also cancel that player's unfinished edit.
An object being edited cant be deleted until its edit is finished or canceled.

## Save Files

Database is saved inside:

```text
scriptfiles/ingame_mapping/save/house.db
```

The `objects` table stores `index`, `model`, `x`, `y`, `z`, `rx`, `ry`, and `rz`.
The new database use `index` as primary key. Old databases with the original eight columns also supported, even without primary key.

To use a saved db from another server, put it in the save folder and use `/loadmap <mapname>`.
The db must have the objects table with valid data. Duplicate indices, out of range indices, invalid numbers, or more than 1000 rows are rejected.

Every successful change is committed before script says it is saved. If saving a change fail, the script keep/restore the previous object state.
A full save use a transaction, so a failed save dont replace the db with half map.
`/closemap` keeps the map opened if the save cant finish.

During normal server shutdown, `OnFilterScriptExit` also save the map.
On crash, force kill, or power loss, a shutdown callback cant be guaranteed; recovery use the last database commit.
No TXT export is needed for database recovery. After restart, use `/loadmap` to open your saved map again.

## Exported Map

If player Delfin export the house map, the file is:

```text
scriptfiles/ingame_mapping/exported/house_Delfin.txt
```

```pawn
// Ingame Mapping

// Map: house
// Exported by Delfin
// Objects: 1
new ingame_mapping;
ingame_mapping = CreateDynamicObject(12982, 1000.000000000, 1000.000000000, 1000.000000000, 0.000000000, 0.000000000, 0.000000000, -1, -1, -1);
```

The header always use the actual current name of the player who runs `/exportmap`, including after a player name change.
Special characters in player name are replaced with `_` only for the filename.
Previous exports are kept. If the file already exist, the next files use `house_Delfin_1.txt`, `house_Delfin_2.txt`, etc.

Only confirmed object position and rotation are exported. Paste the generated calls inside your own mapping function.

## Import Mapping

Close the opened map first. Put the txt file in:

```text
scriptfiles/ingame_mapping/exported/
```

Example, importing the export above into another map:

```text
/importmap house_Delfin house_copy
```

The script create `save/house_copy.db` and open the imported map.
It never replace an existing destination db, and the source txt is kept.

### Supported TXT Format

One `CreateDynamicObject` call per line, with 7 or 10 parameters:

```pawn
CreateDynamicObject(12982, 1000.0, 1000.0, 1000.0, 0.0, 0.0, 0.0);
ingame_mapping = CreateDynamicObject(12982, 1000.0, 1000.0, 1000.0, 0.0, 0.0, 0.0, -1, -1, -1);
```

- The last three parameters, if present, must all be `-1` (shared world, interior, and player).
- Plain variable declarations like `new ingame_mapping;`, blank lines, and `//` comments are allowed.
- `new ingame_mapping = CreateDynamicObject(...);` is also accepted.
- Space, tab, CRLF/LF, UTF-8 BOM, decimal numbers, and scientific notation are accepted.
- Other Pawn statements, materials/textures, functions around the calls, multiline calls, and extra parameters are not supported. Invalid lines report their line number.
- Max file size is 1 MiB, max 1000 objects. Each line must have fewer than 511 characters including its line ending.
- Model id must in range 321 to 19999. Use an actual standard GTA/SA-MP object model from that range; not every number in the range is a real object.
- All position and rotation values must be finite and between -1000000.0 and 1000000.0. Custom negative model ids are not supported.
- Database and export use nine decimal places for position/rotation.

The importer reads numeric object data, it dont execute Pawn code.
It validates all lines before making the database. If import cant finish, the new map is removed so no partial map stay opened.

## Source Files

| File | Use |
| ---- | --- |
| src/INGAME.pwn | Entry point, init, disconnect, death, and shutdown callbacks |
| src/DATA.pwn | Shared map, player editor, and object data |
| src/OBJECT.pwn | Object slots, labels, and input checks |
| src/DATABASE.pwn | SQLite create, load, transactions, and save |
| src/EDIT_OBJECT.pwn | Editor locks, confirmed changes, and cancel |
| src/FILES.pwn | TXT export and import |
| src/COMMANDS.pwn | All registered commands |
| src/COMPAT.pwn | SA-MP native name compatibility |

## Validation

Both targets are compiled with the attached Pawn compiler 3.10.10.
Database, command, editor, and TXT logic are tested by running the compiled Pawn code with SQLite and simulated server/Streamer functions.
This checks saving, rollback, shared edits, export/import, invalid files, old db format, and the 1000 object limit.

Ingame visual editor, label rendering, and behavior alongside your real gamemode still need a live SA-MP/open.mp client test.
See `TESTING.md` for the result and a short ingame checklist.

## Contribute and License

This project is open source, you can make fork and pull request for contribute.

MIT License.
