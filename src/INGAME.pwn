#define FILTERSCRIPT
#define SAMP_COMPAT

#include "open.mp"
#include "zcmd"
#include "streamer"

// modular file
#include "COMPAT.pwn"
#include "DATA.pwn"
#include "OBJECT.pwn"
#include "DATABASE.pwn"
#include "EDIT_OBJECT.pwn"
#include "FILES.pwn"
#include "COMMANDS.pwn"

public OnFilterScriptInit() {
    // SA-MP dont have create directory native, copy scriptfiles folder first
    #if !defined INGAME_SAMP
        fcreatedir(MAP_FOLDER);
        fcreatedir(DB_FOLDER);
        fcreatedir(EXPORT_FOLDER);
    #endif

    for(new i = 1; i <= MAX_OBJECT; i++) ObjectEditor[i] = INVALID_PLAYER_ID;
    for(new i = 0; i < MAX_PLAYERS; i++) {
        EditingObject[i] = 0;
        if(IsPlayerConnected(i)) GetPlayerName(i, PlayerName[i], MAX_PLAYER_NAME);
    }

    printf("[Filterscript] Loaded Ingame Mapping");
    return 1;
}

public OnFilterScriptExit() {
    CancelMapEdit();
    if(MapOpened == true && !SaveMap()) print("[DATABASE] Can't save map on filterscript exit, previous autosave is still in database.");

    ClearObjects();
    if(Database != DB:0) DB_Close(Database);
    Database = DB:0;
    MapOpened = false;
    MapName[0] = 0;

    printf("[Filterscript] Unloaded Ingame Mapping");
    return 1;
}

public OnPlayerConnect(playerid) {
    EditingObject[playerid] = 0;
    GetPlayerName(playerid, PlayerName[playerid], MAX_PLAYER_NAME);
    return 1;
}

public OnPlayerDisconnect(playerid, reason) {
    CancelPlayerEdit(playerid);
    if(MapOpened == true && !SaveMap()) print("[DATABASE] Can't save map on player disconnect, previous autosave is still in database.");

    PlayerName[playerid][0] = 0;
    return 1;
}

public OnPlayerDeath(playerid, killerid, WEAPON:reason) {
    CancelPlayerEdit(playerid);
    return 1;
}
