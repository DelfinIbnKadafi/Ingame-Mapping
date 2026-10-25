// function to save edited object
stock SaveEditObject(index, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz) {
    if(!ValidObjectIndex(index)) return 0;
    if(!ValidObjectFloat(x) || !ValidObjectFloat(y) || !ValidObjectFloat(z) || !ValidObjectFloat(rx) || !ValidObjectFloat(ry) || !ValidObjectFloat(rz)) return 0;

    // keep old position if database cant save the edit
    new Float:oldposition[6];
    oldposition[0] = Object[index][PosX];
    oldposition[1] = Object[index][PosY];
    oldposition[2] = Object[index][PosZ];
    oldposition[3] = Object[index][RotX];
    oldposition[4] = Object[index][RotY];
    oldposition[5] = Object[index][RotZ];

    Object[index][PosX] = x;
    Object[index][PosY] = y;
    Object[index][PosZ] = z;
    Object[index][RotX] = rx;
    Object[index][RotY] = ry;
    Object[index][RotZ] = rz;

    if(!SaveObject(index)) {
        Object[index][PosX] = oldposition[0];
        Object[index][PosY] = oldposition[1];
        Object[index][PosZ] = oldposition[2];
        Object[index][RotX] = oldposition[3];
        Object[index][RotY] = oldposition[4];
        Object[index][RotZ] = oldposition[5];
        RestoreObject(index);
        return 0;
    }

    RestoreObject(index);
    UpdateObjectLabel(index);
    return 1;
}

// stop player edit and release object for another player
stock CancelPlayerEdit(playerid) {
    new index = EditingObject[playerid];
    EditingObject[playerid] = 0;

    if(ValidObjectIndex(index) && ObjectEditor[index] == playerid) {
        ObjectEditor[index] = INVALID_PLAYER_ID;
        RestoreObject(index);
        if(IsPlayerConnected(playerid)) CancelEdit(playerid);
    }
    return 1;
}

// stop all unfinished edit before close the map
stock CancelMapEdit() {
    for(new i = 0; i < MAX_PLAYERS; i++) {
        if(EditingObject[i]) CancelPlayerEdit(i);
    }
    return 1;
}

// function to handle player edit object
public OnPlayerEditDynamicObject(playerid, STREAMER_TAG_OBJECT:objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz) {
    new index = EditingObject[playerid];
    if(MapOpened == false || !ValidObjectIndex(index)) return 1;
    if(Object[index][ObjectID] != objectid || ObjectEditor[index] != playerid) return 1;

    // update is only preview, save when player click the save button
    if(response == _:EDIT_RESPONSE_UPDATE) return 1;
    if(response != _:EDIT_RESPONSE_FINAL && response != _:EDIT_RESPONSE_CANCEL) return 1;

    EditingObject[playerid] = 0;
    ObjectEditor[index] = INVALID_PLAYER_ID;

    if(response == EDIT_RESPONSE_FINAL) {
        if(!SaveEditObject(index, x, y, z, rx, ry, rz)) {
            RestoreObject(index);
            SendClientMessage(playerid, -1, "Can't save edit, the old position is restored.");
            return 1;
        }
        SendClientMessage(playerid, -1, "Succesfuly edited and saved object.");
    } else {
        RestoreObject(index);
        SendClientMessage(playerid, -1, "Object edit canceled.");
    }
    return 1;
}
