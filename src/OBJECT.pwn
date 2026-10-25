// check name before use it for file path
stock ValidMapName(const name[], maxlength = 63) {
    new length = strlen(name);
    if(length < 1 || length > maxlength) return 0;

    for(new i = 0; i < length; i++) {
        if(name[i] >= 'a' && name[i] <= 'z') continue;
        if(name[i] >= 'A' && name[i] <= 'Z') continue;
        if(name[i] >= '0' && name[i] <= '9') continue;
        if(name[i] == '_' || name[i] == '-') continue;
        return 0;
    }
    return 1;
}

// read whole number, dont let big number overflow
stock ReadInteger(const text[], &value) {
    new i, number, digit, bool:minus;
    if(text[i] == '-' || text[i] == '+') {
        minus = text[i] == '-';
        i++;
    }
    if(!text[i]) return 0;

    for(; text[i]; i++) {
        if(text[i] < '0' || text[i] > '9') return 0;
        digit = text[i] - '0';
        if(number > 214748364 || (number == 214748364 && digit > 7)) return 0;
        number = number * 10 + digit;
    }

    value = minus ? -number : number;
    return 1;
}

// read float number from txt or database
stock ReadFloat(const text[], &Float:value) {
    new i, digits;
    if(text[i] == '+' || text[i] == '-') i++;
    while(text[i] >= '0' && text[i] <= '9') {
        digits++;
        i++;
    }
    if(text[i] == '.') {
        i++;
        while(text[i] >= '0' && text[i] <= '9') {
            digits++;
            i++;
        }
    }
    if(!digits) return 0;

    if(text[i] == 'e' || text[i] == 'E') {
        i++;
        if(text[i] == '+' || text[i] == '-') i++;
        digits = 0;
        while(text[i] >= '0' && text[i] <= '9') {
            digits++;
            i++;
        }
        if(!digits) return 0;
    }
    if(text[i]) return 0;

    value = floatstr(text);
    return ValidObjectFloat(value);
}

// dont accept nan, infinity, or too big position
stock ValidObjectFloat(Float:value) {
    if((_:value & 0x7F800000) == 0x7F800000) return 0;
    return value >= -1000000.0 && value <= 1000000.0;
}

// standard object model range
stock ValidObjectModel(modelid) {
    return modelid >= 321 && modelid <= 19999;
}

// check index before access the object data
stock ValidObjectIndex(index) {
    if(index < 1 || index > MAX_OBJECT) return 0;
    return Object[index][Index] == index;
}

// find empty slot, deleted id can use again
stock FreeObjectIndex() {
    for(new i = 1; i <= MAX_OBJECT; i++) {
        if(!Object[i][Index]) return i;
    }
    return 0;
}

// create label at the saved object position
stock UpdateObjectLabel(index) {
    if(IsValidDynamic3DTextLabel(Object[index][LabelID])) DestroyDynamic3DTextLabel(Object[index][LabelID]);
    Object[index][LabelID] = STREAMER_TAG_3D_TEXT_LABEL:INVALID_STREAMER_ID;

    if(ToggleLabel == false || !ValidObjectIndex(index)) return 1;

    new msg[16];
    format(msg, sizeof msg, "%d", index);
    Object[index][LabelID] = CreateDynamic3DTextLabel(msg, 0xffff00ff, Object[index][PosX], Object[index][PosY], Object[index][PosZ], 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1);
    return 1;
}

// remove one object and clear the data
stock ClearObject(index) {
    if(IsValidDynamicObject(Object[index][ObjectID])) DestroyDynamicObject(Object[index][ObjectID]);
    if(IsValidDynamic3DTextLabel(Object[index][LabelID])) DestroyDynamic3DTextLabel(Object[index][LabelID]);

    for(new i = 0; i < _:ObjectData; i++) Object[index][ObjectData:i] = 0;
    ObjectEditor[index] = INVALID_PLAYER_ID;
    return 1;
}

// clear all object from curently map
stock ClearObjects() {
    for(new i = 1; i <= MAX_OBJECT; i++) ClearObject(i);
    ObjectCount = 0;
    return 1;
}

// put saved data back to the streamer object
stock RestoreObject(index) {
    if(!ValidObjectIndex(index) || !IsValidDynamicObject(Object[index][ObjectID])) return 0;
    SetDynamicObjectPos(Object[index][ObjectID], Object[index][PosX], Object[index][PosY], Object[index][PosZ]);
    SetDynamicObjectRot(Object[index][ObjectID], Object[index][RotX], Object[index][RotY], Object[index][RotZ]);
    return 1;
}
