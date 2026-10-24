// function to save edited object
stock SaveEditObject(index, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz) {
    SetDynamicObjectPos(Object[index][ObjectID], x, y, z);
    SetDynamicObjectRot(Object[index][ObjectID], rx, ry, rz);
    GetDynamicObjectPos(Object[ObjectCount][ObjectID], Object[ObjectCount][PosX], Object[ObjectCount][PosY], Object[ObjectCount][PosZ]);
    GetDynamicObjectRot(Object[ObjectCount][ObjectID], Object[ObjectCount][RotX], Object[ObjectCount][RotY], Object[ObjectCount][RotZ]);

    if(ToggleLabel == true) {
        Delete3DTextLabel(Object[index][LabelID]);
        new msg[8];
        format(msg, sizeof msg, "%d", ObjectCount);
        Object[ObjectCount][LabelID] = Create3DTextLabel(msg, 0xffff00ff, Object[ObjectCount][PosX], Object[ObjectCount][PosY], Object[ObjectCount][PosZ], 10.0, -1);
    }
}

// function to handle player edit object
public OnPlayerEditDynamicObject(playerid, STREAMER_TAG_OBJECT:objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz) {
    new bool:ok = false;
    new index;
    for(index = 0; index < MAX_OBJECT; index++) {
        if(objectid == Object[index][ObjectID]) {
            ok = true;
            break;
        }
    }
    
    if(response == _:EDIT_RESPONSE_FINAL && ok) {
        SaveEditObject(index, x, y, z, rx, ry, rz);
    }
    return 1;
}