# Ingame Mapping Testing

## Build Result

- Compiler: supplied Pawn 3.10.10 Linux compiler.
- open.mp: `src/INGAME.amx`, 0 errors and 0 warnings.
- SA-MP: `src/INGAME_SAMP.amx`, 0 errors and 0 warnings.
- Options: `-;+ -(+ -d3 -C- -E+`, plus `INGAME_SAMP=1` for SA-MP.

## Logic Checks

60 automated checks passed for each target. The tests execute compiled Pawn code in a Pawn interpreter, use real SQLite files, and simulate the server/Streamer native functions. These tests do not run a real SA-MP/open.mp server or game client.

| Area | Checked |
| ---- | ------- |
| Init | Filterscript command hook, folders, connected players |
| Map | Create, close, save, load, existing file protection |
| Shared map | Two players create objects in the same map |
| Editor | Shared locks, confirmed edit, preview, cancel, disconnect, death |
| Autosave | Create, final edit, delete, disconnect, normal shutdown |
| Failure | Insert, full save, delete, import commit, Streamer creation, TXT write |
| Rollback | Old database and object position stay after failed save |
| Object IDs | Invalid indices, deleted slot reuse, sparse db IDs, ID 1000 |
| Labels | Correct ID after editing, show/hide, load, cleanup |
| Export | Player attribution, filename, duplicate exports, object data |
| Import | Export roundtrip, empty map, long filename, 1000 objects |
| Parser | 7/10 parameters, comments, variables, BOM, decimals, scientific numbers |
| Invalid input | Overflow, NaN, infinity, trailing statements, unsupported arguments |
| Database | Legacy schema, duplicate/outside IDs, bad models, null/text/long fields |
| Cleanup | No leftover map objects, labels, DB results, connections, or file handles |

Both final AMX files also receive a command/save/export/reload/shutdown smoke test. Native names are checked so the SA-MP build does not depend on open.mp-only database, directory, or edit natives.

## Ingame Check

Use the matching AMX and Streamer plugin with your real server. The visual editor, rendering, plugin version, and interaction with your gamemode need this client test.

1. Join with two players. Run `/newmap test_map` then `/newobject 12982` from either player.
2. Confirm both players see the same objects and ID labels. Use `/toggleid` to hide/show them.
3. Use `/editobject 1`. Confirm another player cannot edit/delete object 1 while it is locked, but can edit another object.
4. Move/rotate object 1 and click save. Edit again and cancel; confirm it returns to the saved position.
5. Disconnect while editing and reconnect. Confirm another player can edit the object, and unfinished preview was canceled.
6. Delete an object, create another, and confirm its deleted ID can be reused.
7. Run `/exportmap` from both players. Check each TXT header and filename use the player who exported it.
8. Run `/closemap` and `/loadmap test_map`. Confirm objects, rotations, and labels return.
9. Close the map, then import one exported TXT using `/importmap <txtname> test_copy`.
10. Restart the server normally. Run `/loadmap test_copy` and confirm the saved map returns.

TXT files and DB files are in `scriptfiles/ingame_mapping`. Keep existing data folders when installing updates.
