// file where all registered commands

// new map
CMD:newmap(playerid, params[]) {
    if(MapOpened == true) return SendClientMessage(playerid, -1, "You already opened map, use /closemap to close curently map.");
    if(!ValidMapName(params)) return SendClientMessage(playerid, -1, "Use : /newmap <mapname>, only A-Z, a-z, 0-9, _ and -, max 63 character.");

    if(!NewDatabase(params)) return SendClientMessage(playerid, -1, "Can't create map, name already exist or save folder is not writable.");

    format(MapName, sizeof MapName, "%s", params);
    MapOpened = true;

    new msg[144];
    format(msg, sizeof msg, "Succesfuly created %s map, all changes will autosave.", MapName);
    SendClientMessage(playerid, -1, msg);
    return 1;
}

// close map, save first before remove all object
CMD:closemap(playerid, params[]) {
    if(MapOpened == false) return SendClientMessage(playerid, -1, "You're not opened any map yet.");
    if(!SaveMap()) return SendClientMessage(playerid, -1, "Can't save map, map is still opened. Check database permission or disk space.");

    new msg[144];
    format(msg, sizeof msg, "Succesfuly saved and closed %s map.", MapName);

    CancelMapEdit();
    ClearObjects();
    DB_Close(Database);
    Database = DB:0;
    MapOpened = false;
    MapName[0] = 0;

    SendClientMessage(playerid, -1, msg);
    return 1;
}

// load map from db files
CMD:loadmap(playerid, params[]) {
    if(MapOpened == true) return SendClientMessage(playerid, -1, "You're already opened map, use /closemap first.");
    if(!ValidMapName(params)) return SendClientMessage(playerid, -1, "Use : /loadmap <mapname>, without .db extension.");

    new filename[128];
    format(filename, sizeof filename, "%s/%s.db", DB_FOLDER, params);
    if(!fexist(filename)) return SendClientMessage(playerid, -1, "Can't find map in save folder.");

    Database = DB_Open(filename);
    if(Database == DB:0) return SendClientMessage(playerid, -1, "Can't open map database.");

    if(!MapQuery("PRAGMA synchronous = FULL") || !LoadObject()) {
        ClearObjects();
        DB_Close(Database);
        Database = DB:0;
        return SendClientMessage(playerid, -1, "Can't load map, database format or object data is invalid.");
    }

    format(MapName, sizeof MapName, "%s", params);
    MapOpened = true;

    new msg[144];
    format(msg, sizeof msg, "Succesfuly loaded %s map with %d objects.", MapName, ObjectCount);
    SendClientMessage(playerid, -1, msg);
    return 1;
}

// save map manually, also have autosave for every changes
CMD:savemap(playerid, params[]) {
    if(MapOpened == false) return SendClientMessage(playerid, -1, "You're not opened any map yet.");
    if(!SaveMap()) return SendClientMessage(playerid, -1, "Can't save map, check database permission or disk space.");

    new msg[144];
    format(msg, sizeof msg, "Succesfuly saved %s map with %d objects.", MapName, ObjectCount);
    SendClientMessage(playerid, -1, msg);
    return 1;
}

// export shared map with curently player name
CMD:exportmap(playerid, params[]) {
    if(MapOpened == false) return SendClientMessage(playerid, -1, "You're not opened any map yet.");
    if(!SaveMap()) return SendClientMessage(playerid, -1, "Can't save map before export, check database permission or disk space.");
    return ExportMap(playerid);
}

// import txt into new map, use /loadmap for db files
CMD:importmap(playerid, params[]) {
    if(MapOpened == true) return SendClientMessage(playerid, -1, "You're already opened map, use /closemap first.");

    new length = strlen(params), split, start;
    while(params[split] && params[split] > ' ') split++;
    start = split;
    while(params[start] && params[start] <= ' ') start++;

    new filename[128], namemap[64];
    if(split < 1 || split >= sizeof filename || length - start < 1 || length - start >= sizeof namemap) return SendClientMessage(playerid, -1, "Use : /importmap <txtname> <newmapname>, without .txt extension.");

    strmid(filename, params, 0, split, sizeof filename);
    strmid(namemap, params, start, length, sizeof namemap);
    if(!ValidMapName(filename, sizeof filename - 1) || !ValidMapName(namemap)) return SendClientMessage(playerid, -1, "Name only use A-Z, a-z, 0-9, _ and -. Map name max 63, txt name max 127 character.");

    return ImportMap(playerid, filename, namemap);
}

// create object
CMD:newobject(playerid, params[]) {
    if(MapOpened == false) return SendClientMessage(playerid, -1, "You're not opened any map yet.");
    if(ObjectCount >= MAX_OBJECT) return SendClientMessage(playerid, -1, "The object slot is max.");

    new modelid;
    if(!ReadInteger(params, modelid)) return SendClientMessage(playerid, -1, "Use : /newobject <modelid>");
    if(!ValidObjectModel(modelid)) return SendClientMessage(playerid, -1, "Model id must in standard object range 321 to 19999.");

    new index = FreeObjectIndex();
    if(!index) return SendClientMessage(playerid, -1, "The object slot is max.");

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    x += 3.0;
    y += 2.0;
    if(!ValidObjectFloat(x) || !ValidObjectFloat(y) || !ValidObjectFloat(z)) return SendClientMessage(playerid, -1, "Can't create object at invalid position.");

    Object[index][Index] = index;
    Object[index][ModelID] = modelid;
    Object[index][PosX] = x;
    Object[index][PosY] = y;
    Object[index][PosZ] = z;
    Object[index][ObjectID] = CreateDynamicObject(modelid, x, y, z, 0.0, 0.0, 0.0, -1, -1, -1);

    // dont leave object ingame if database cant save it
    if(!IsValidDynamicObject(Object[index][ObjectID]) || !SaveObject(index)) {
        ClearObject(index);
        return SendClientMessage(playerid, -1, "Can't create or save object, check streamer and database.");
    }

    ObjectCount++;
    UpdateObjectLabel(index);

    new msg[96];
    format(msg, sizeof msg, "Succesfuly created and saved object id %d, model %d.", index, modelid);
    SendClientMessage(playerid, -1, msg);
    return 1;
}

// edit object
CMD:editobject(playerid, params[]) {
    if(MapOpened == false) return SendClientMessage(playerid, -1, "You're not opened any map yet.");

    new index;
    if(!ReadInteger(params, index)) return SendClientMessage(playerid, -1, "Use : /editobject <index>");
    if(!ValidObjectIndex(index)) return SendClientMessage(playerid, -1, "The object is'nt exist yet.");
    if(!IsValidDynamicObject(Object[index][ObjectID])) return SendClientMessage(playerid, -1, "The streamer object is not exist.");
    if(EditingObject[playerid]) return SendClientMessage(playerid, -1, "Finish or cancel your curently edit first.");
    if(ObjectEditor[index] != INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "Another player is editing this object.");
    if(!IsPlayerInRangeOfPoint(playerid, 50.0, Object[index][PosX], Object[index][PosY], Object[index][PosZ])) return SendClientMessage(playerid, -1, "You must in radius 50 of the object.");

    EditingObject[playerid] = index;
    ObjectEditor[index] = playerid;
    Streamer_Update(playerid, STREAMER_TYPE_OBJECT);
    if(!EditDynamicObject(playerid, Object[index][ObjectID])) {
        EditingObject[playerid] = 0;
        ObjectEditor[index] = INVALID_PLAYER_ID;
        return SendClientMessage(playerid, -1, "Can't start edit, move closer to the object.");
    }
    return 1;
}

// delete object from ingame and database
CMD:deleteobject(playerid, params[]) {
    if(MapOpened == false) return SendClientMessage(playerid, -1, "You're not opened any map yet.");

    new index;
    if(!ReadInteger(params, index)) return SendClientMessage(playerid, -1, "Use : /deleteobject <index>");
    if(!ValidObjectIndex(index)) return SendClientMessage(playerid, -1, "The object is'nt exist yet.");
    if(ObjectEditor[index] != INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "That object is being edited, finish or cancel edit first.");
    if(!DeleteSavedObject(index)) return SendClientMessage(playerid, -1, "Can't delete saved object, object is still exist.");

    ClearObject(index);
    ObjectCount--;

    new msg[96];
    format(msg, sizeof msg, "Succesfuly deleted and saved object id %d.", index);
    SendClientMessage(playerid, -1, msg);
    return 1;
}

// toggle all object id label, shared for all players
CMD:toggleid(playerid, params[]) {
    if(MapOpened == false) return SendClientMessage(playerid, -1, "You're not opened any map yet.");

    ToggleLabel = !ToggleLabel;
    for(new i = 1; i <= MAX_OBJECT; i++) {
        if(ValidObjectIndex(i)) UpdateObjectLabel(i);
    }

    if(ToggleLabel == true) SendClientMessage(playerid, -1, "Object id label is now enabled for all players.");
    else SendClientMessage(playerid, -1, "Object id label is now disabled for all players.");
    return 1;
}

// list all mapping commands
CMD:help(playerid, params[]) {
    SendClientMessage(playerid, -1, "Ingame Mapping - one shared map, all players can use commands.");
    SendClientMessage(playerid, -1, "/newmap <name> | /closemap | /loadmap <name> | /savemap");
    SendClientMessage(playerid, -1, "/exportmap | /importmap <txtname> <newmapname> (without extension)");
    SendClientMessage(playerid, -1, "/newobject <modelid> | /editobject <index> | /deleteobject <index> | /toggleid");
    SendClientMessage(playerid, -1, "All finished changes autosave. Use editor save button to confirm, ESC to cancel.");
    return 1;
}

// another name if server already have /help
CMD:mappinghelp(playerid, params[]) {
    return cmd_help(playerid, params);
}
