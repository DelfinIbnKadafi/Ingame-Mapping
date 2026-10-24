// file where all registered commands

// new map
CMD:newmap(playerid, params[]) {
    if(MapOpened == true) return SendClientMessage(playerid, -1, "You already opened map, use /closemap to close curently map.");

    MapOpened = true;

    return 1;
}

// close map
CMD:closemap(playerid, params[]) {
    if(MapOpened == false) return SendClientMessage(playerid, -1, "You're not opened any map yet.");

    MapOpened = false;

    for(new i = 0; i < MAX_OBJECTS; i++) {
        if(IsValidObject(Object[i][ObjectID])) DestroyObject(Object[i][ObjectID]);
    }

    new msg[256];
    format(msg, sizeof msg, "Succesfuly closed %s map", MapName);
    SendClientMessage(playerid, -1, msg);

    return 1;
}

CMD:newobject(playerid, params[]) {
    if(MapOpened == false) return SendClientMessage(playerid, -1, "You're not opened any map yet.");

    if(MapCount == MAX_OBJECTS) return SendClientMessage(playerid, -1, "The object slot is max.");

    new modelid;
    if(sscanf(params, "i", modelid)) return SendClientMessage(playerid, -1, "Use : /newobject <modelid>");

    return 1;
}