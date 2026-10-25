// remove space at start and end of the text
stock TrimText(text[]) {
    new length = strlen(text), start;
    while(length > 0 && text[length - 1] <= ' ') text[--length] = 0;
    while(text[start] && text[start] <= ' ') start++;
    if(start) strdel(text, 0, start);
    return strlen(text);
}

// check variable name from exported txt
stock ValidVariableName(const text[]) {
    if(!text[0]) return 0;

    for(new i = 0; text[i]; i++) {
        if(text[i] >= 'a' && text[i] <= 'z') continue;
        if(text[i] >= 'A' && text[i] <= 'Z') continue;
        if(text[i] == '_') continue;
        if(i > 0 && text[i] >= '0' && text[i] <= '9') continue;
        return 0;
    }
    return 1;
}

// read one line, 0 is comment, 1 is object, -1 is invalid
stock ReadObjectLine(line[], &modelid, Float:position[]) {
    // fread can give utf8 bom as one character or three bytes
    if(line[0] == 0xFEFF) strdel(line, 0, 1);
    else if((line[0] & 0xFF) == 0xEF && (line[1] & 0xFF) == 0xBB && (line[2] & 0xFF) == 0xBF) strdel(line, 0, 3);

    new comment = strfind(line, "//");
    if(comment != -1) line[comment] = 0;
    TrimText(line);
    if(!line[0]) return 0;

    new call = strfind(line, "CreateDynamicObject");
    new prefix[128], length = strlen(line);

    if(call == -1) {
        // only plain variable declaration is allowed beside object lines
        if(strfind(line, "new ") != 0 || line[length - 1] != ';') return -1;
        if(length - 5 >= sizeof prefix) return -1;
        strmid(prefix, line, 4, length - 1, sizeof prefix);
        TrimText(prefix);
        return ValidVariableName(prefix) ? 0 : -1;
    }

    if(call >= sizeof prefix) return -1;
    strmid(prefix, line, 0, call, sizeof prefix);
    TrimText(prefix);
    length = strlen(prefix);

    if(length) {
        if(prefix[length - 1] != '=') return -1;
        prefix[length - 1] = 0;
        TrimText(prefix);
        if(strfind(prefix, "new ") == 0) strdel(prefix, 0, 4);
        TrimText(prefix);
        if(!ValidVariableName(prefix)) return -1;
    }

    new start = call + 19;
    while(line[start] == ' ' || line[start] == '\t') start++;
    if(line[start] != '(') return -1;
    start++;

    new end = strfind(line, ")", false, start);
    if(end == -1) return -1;

    new tail = end + 1;
    while(line[tail] == ' ' || line[tail] == '\t') tail++;
    if(line[tail++] != ';') return -1;
    while(line[tail] == ' ' || line[tail] == '\t') tail++;
    if(line[tail]) return -1;

    new values[10][64], count;
    for(new i = start; i <= end; i++) {
        if(line[i] != ',' && i != end) continue;
        if(count >= 10 || i - start >= sizeof values[]) return -1;
        strmid(values[count], line, start, i, sizeof values[]);
        TrimText(values[count]);
        if(!values[count][0]) return -1;
        count++;
        start = i + 1;
    }

    if(count != 7 && count != 10) return -1;
    if(!ReadInteger(values[0], modelid) || !ValidObjectModel(modelid)) return -1;
    for(new i = 0; i < 6; i++) {
        if(!ReadFloat(values[i + 1], position[i])) return -1;
    }

    // shared objects use all world, all interior, and all player
    new value;
    for(new i = 7; i < count; i++) {
        if(!ReadInteger(values[i], value) || value != -1) return -1;
    }
    return 1;
}

// export map with the name of player who export it
stock ExportMap(playerid) {
    GetPlayerName(playerid, PlayerName[playerid], MAX_PLAYER_NAME);

    // replace special character only for file name, header use real name
    new filenameplayer[MAX_PLAYER_NAME];
    format(filenameplayer, sizeof filenameplayer, "%s", PlayerName[playerid]);
    for(new i = 0; filenameplayer[i]; i++) {
        if(filenameplayer[i] >= 'a' && filenameplayer[i] <= 'z') continue;
        if(filenameplayer[i] >= 'A' && filenameplayer[i] <= 'Z') continue;
        if(filenameplayer[i] >= '0' && filenameplayer[i] <= '9') continue;
        if(filenameplayer[i] == '_' || filenameplayer[i] == '-') continue;
        filenameplayer[i] = '_';
    }

    // keep previous export, add number if file already exist
    new path[192], number;
    format(path, sizeof path, "%s/%s_%s.txt", EXPORT_FOLDER, MapName, filenameplayer);
    while(fexist(path) && number < 10000) {
        number++;
        format(path, sizeof path, "%s/%s_%s_%d.txt", EXPORT_FOLDER, MapName, filenameplayer, number);
    }
    if(fexist(path)) return SendClientMessage(playerid, -1, "Too many exported files for this map.");

    new File:file = fopen(path, io_write);
    if(!file) return SendClientMessage(playerid, -1, "Can't create txt file, check exported folder and permission.");

    new line[512], bool:ok = true;
    format(line, sizeof line, "// Ingame Mapping\r\n\r\n// Map: %s\r\n// Exported by %s\r\n// Objects: %d\r\nnew ingame_mapping;\r\n", MapName, PlayerName[playerid], ObjectCount);
    if(fwrite(file, line) != strlen(line)) ok = false;

    for(new i = 1; i <= MAX_OBJECT && ok; i++) {
        if(!ValidObjectIndex(i)) continue;
        format(line, sizeof line, "ingame_mapping = CreateDynamicObject(%d, %.9f, %.9f, %.9f, %.9f, %.9f, %.9f, -1, -1, -1);\r\n", Object[i][ModelID], Object[i][PosX], Object[i][PosY], Object[i][PosZ], Object[i][RotX], Object[i][RotY], Object[i][RotZ]);
        if(fwrite(file, line) != strlen(line)) ok = false;
    }

    if(!fclose(file)) ok = false;
    if(!ok) {
        fremove(path);
        return SendClientMessage(playerid, -1, "Can't finish export, the incomplete txt file is removed.");
    }

    new msg[256];
    format(msg, sizeof msg, "Succesfuly exported %d objects to scriptfiles/%s", ObjectCount, path);
    SendClientMessage(playerid, -1, msg);
    return 1;
}

// clean new database when import cant finish
stock DiscardImportedMap(const name[]) {
    ClearObjects();
    if(Database != DB:0) DB_Close(Database);
    Database = DB:0;
    MapOpened = false;
    MapName[0] = 0;

    new path[128];
    format(path, sizeof path, "%s/%s.db", DB_FOLDER, name);
    fremove(path);
    return 1;
}

// import txt as new map, source file is never changed
stock ImportMap(playerid, const filename[], const name[]) {
    new path[192];
    format(path, sizeof path, "%s/%s.db", DB_FOLDER, name);
    if(fexist(path)) return SendClientMessage(playerid, -1, "That map database already exist, use another new map name.");

    format(path, sizeof path, "%s/%s.txt", EXPORT_FOLDER, filename);
    if(!fexist(path)) return SendClientMessage(playerid, -1, "Can't find txt file in exported folder.");

    new File:file = fopen(path, io_read);
    if(!file) return SendClientMessage(playerid, -1, "Can't open txt file.");
    if(flength(file) > MAX_IMPORT_SIZE) {
        fclose(file);
        return SendClientMessage(playerid, -1, "Txt file is too big, max 1 MiB.");
    }

    new line[512], linenumber, read, status, modelid, bool:ok = true;
    new Float:position[6];

    while((read = fread(file, line, sizeof line)) > 0) {
        linenumber++;
        if(read >= sizeof line - 1) {
            ok = false;
            break;
        }

        status = ReadObjectLine(line, modelid, position);
        if(status == 0) continue;
        if(status == -1 || ObjectCount >= MAX_OBJECT) {
            ok = false;
            break;
        }

        ObjectCount++;
        Object[ObjectCount][Index] = ObjectCount;
        Object[ObjectCount][ModelID] = modelid;
        Object[ObjectCount][PosX] = position[0];
        Object[ObjectCount][PosY] = position[1];
        Object[ObjectCount][PosZ] = position[2];
        Object[ObjectCount][RotX] = position[3];
        Object[ObjectCount][RotY] = position[4];
        Object[ObjectCount][RotZ] = position[5];
    }

    if(!fclose(file)) ok = false;
    if(!ok) {
        ClearObjects();
        new msg[144];
        format(msg, sizeof msg, "Can't import line %d, check txt format and max %d objects. No map is created.", linenumber, MAX_OBJECT);
        return SendClientMessage(playerid, -1, msg);
    }

    if(!NewDatabase(name)) {
        ClearObjects();
        return SendClientMessage(playerid, -1, "Can't create imported map database, check save folder and permission.");
    }

    for(new i = 1; i <= MAX_OBJECT; i++) {
        if(!ValidObjectIndex(i)) continue;
        Object[i][ObjectID] = CreateDynamicObject(Object[i][ModelID], Object[i][PosX], Object[i][PosY], Object[i][PosZ], Object[i][RotX], Object[i][RotY], Object[i][RotZ], -1, -1, -1);
        if(!IsValidDynamicObject(Object[i][ObjectID])) {
            DiscardImportedMap(name);
            return SendClientMessage(playerid, -1, "Can't create imported object, the import is canceled.");
        }
        UpdateObjectLabel(i);
    }

    format(MapName, sizeof MapName, "%s", name);
    MapOpened = true;
    if(!SaveMap()) {
        DiscardImportedMap(name);
        return SendClientMessage(playerid, -1, "Can't save imported objects, the import is canceled.");
    }

    new msg[144];
    format(msg, sizeof msg, "Succesfuly imported %d objects to %s map.", ObjectCount, MapName);
    SendClientMessage(playerid, -1, msg);
    return 1;
}
