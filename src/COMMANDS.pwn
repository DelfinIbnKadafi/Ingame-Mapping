// file where all registered commands

// new map
CMD:newmap(playerid, params[]) {
    if(MapOpened == true) return SendClientMessage(playerid, -1, "You already opened map, use /closemap to close curently map.");

    if(sscanf(params, "s[64]", MapName)) return SendClientMessage(playerid, -1, "Use : /newmap <mapname>");

    MapOpened = true;

    new msg[256];
    format(msg, sizeof msg, "Succesfuly created %s map", MapName);
    SendClientMessage(playerid, -1, msg);

    return 1;
}

// close map
CMD:closemap(playerid, params[]) {
    if(MapOpened == false) return SendClientMessage(playerid, -1, "You're not opened any map yet.");

    MapOpened = false;

    for(new i = 0; i <= MAX_OBJECT; i++) {
        if(IsValidDynamicObject(Object[i][ObjectID])) DestroyDynamicObject(Object[i][ObjectID]);
    }

    new msg[256];
    format(msg, sizeof msg, "Succesfuly closed %s map", MapName);
    SendClientMessage(playerid, -1, msg);

    return 1;
}

// create object
CMD:newobject(playerid, params[]) {
    if(MapOpened == false) return SendClientMessage(playerid, -1, "You're not opened any map yet.");

    if(ObjectCount == MAX_OBJECT) return SendClientMessage(playerid, -1, "The object slot is max.");

    new modelid;
    if(sscanf(params, "i", modelid)) return SendClientMessage(playerid, -1, "Use : /newobject <modelid>");

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    x += 3.0;
    y += 2.0;

    // if object is 0, and player make 1 object, id start from 1, and end on 1000
    ObjectCount++;

    Object[ObjectCount][ModelID] = modelid;

    Object[ObjectCount][ObjectID] = CreateDynamicObject(modelid, x, y, z, 0.0, 0.0, 0.0, -1, -1, -1);
    GetDynamicObjectPos(Object[ObjectCount][ObjectID], Object[ObjectCount][PosX], Object[ObjectCount][PosY], Object[ObjectCount][PosZ]);
    GetDynamicObjectRot(Object[ObjectCount][ObjectID], Object[ObjectCount][RotX], Object[ObjectCount][RotY], Object[ObjectCount][RotZ]);

    new msg[8];
    format(msg, sizeof msg, "%d", ObjectCount);

    if(ToggleLabel == true) {
        Object[ObjectCount][LabelID] = Create3DTextLabel(msg, 0xffff00ff, Object[ObjectCount][PosX], Object[ObjectCount][PosY], Object[ObjectCount][PosZ], 10.0, -1);
    }

    return 1;
}

// edit object
CMD:editobject(playerid, params[]) {
    if(MapOpened == false) return SendClientMessage(playerid, -1, "You're not opened any map yet.");

    new index;
    if(sscanf(params, "i", index)) return SendClientMessage(playerid, -1, "Use : /editobject <index>");
    
    if(!IsValidDynamicObject(Object[index][ObjectID])) return SendClientMessage(playerid, -1, "The object is'nt exist yet.");

    if(!IsPlayerInRangeOfPoint(playerid, 50.0, Object[index][PosX], Object[index][PosY], Object[index][PosZ])) return SendClientMessage(playerid, -1, "You must in radius 50 of the object.");

    EditDynamicObject(playerid, Object[index][ObjectID]);

    return 1;
}