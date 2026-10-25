// execute query and always free the result
stock MapQuery(const query[]) {
    if(Database == DB:0) return 0;

    new DBResult:result = DB_ExecuteQuery(Database, query);
    if(!result) {
        print("[DATABASE] Can't execute map query, check database permission or disk space.");
        return 0;
    }

    DB_FreeResultSet(result);
    return 1;
}

// make new database file
stock NewDatabase(const filename[]) {
    if(!ValidMapName(filename) || Database != DB:0) return 0;

    // dont replace map that already saved
    new path[128];
    format(path, sizeof path, "%s/%s.db", DB_FOLDER, filename);
    if(fexist(path)) return 0;

    Database = DB_Open(path);
    if(Database == DB:0) return 0;

    // fill with default data
    if(!MapQuery("PRAGMA synchronous = FULL") || !MapQuery("CREATE TABLE objects ([index] INTEGER PRIMARY KEY, model INTEGER NOT NULL, x REAL NOT NULL, y REAL NOT NULL, z REAL NOT NULL, rx REAL NOT NULL, ry REAL NOT NULL, rz REAL NOT NULL)")) {
        DB_Close(Database);
        Database = DB:0;
        fremove(path);
        return 0;
    }

    print("[DATABASE] Successfully created database.");
    return 1;
}

// insert one object, caller is handle the transaction
stock InsertObject(index) {
    new query[512];
    format(query, sizeof query, "INSERT INTO objects ([index], model, x, y, z, rx, ry, rz) VALUES (%d, %d, %.9f, %.9f, %.9f, %.9f, %.9f, %.9f)", index, Object[index][ModelID], Object[index][PosX], Object[index][PosY], Object[index][PosZ], Object[index][RotX], Object[index][RotY], Object[index][RotZ]);
    return MapQuery(query);
}

// autosave only the changed object
stock SaveObject(index) {
    if(!ValidObjectIndex(index) || !MapQuery("BEGIN IMMEDIATE TRANSACTION")) return 0;

    // delete first so old db without primary key also work
    new query[96];
    format(query, sizeof query, "DELETE FROM objects WHERE [index] = %d", index);
    if(!MapQuery(query) || !InsertObject(index) || !MapQuery("COMMIT")) {
        MapQuery("ROLLBACK");
        return 0;
    }
    return 1;
}

// save all object, dont read position from unfinished editor
stock SaveMap() {
    if(MapOpened == false || !MapQuery("BEGIN IMMEDIATE TRANSACTION")) return 0;

    if(!MapQuery("DELETE FROM objects")) {
        MapQuery("ROLLBACK");
        return 0;
    }

    for(new i = 1; i <= MAX_OBJECT; i++) {
        if(!ValidObjectIndex(i)) continue;
        if(!InsertObject(i)) {
            MapQuery("ROLLBACK");
            return 0;
        }
    }

    if(!MapQuery("COMMIT")) {
        MapQuery("ROLLBACK");
        return 0;
    }
    return 1;
}

// delete the saved row before remove object ingame
stock DeleteSavedObject(index) {
    new query[96];
    format(query, sizeof query, "DELETE FROM objects WHERE [index] = %d", index);
    return MapQuery(query);
}

// dont read clipped field as valid number
stock ReadMapField(DBResult:result, field, output[], size) {
    output[0] = 0;
    if(!DB_GetFieldString(result, field, output, size)) return 0;
    return strlen(output) < size - 1;
}

// load object from database
stock LoadObject() {
    new DBResult:result = DB_ExecuteQuery(Database, "SELECT [index], model, x, y, z, rx, ry, rz FROM objects ORDER BY [index]");
    if(!result) return 0;

    new count = DB_GetRowCount(result);
    new index, modelid, text[64], bool:ok = count <= MAX_OBJECT;
    new Float:position[6];

    // check all rows first, dont leave half loaded map
    for(new i = 0; i < count && ok; i++) {
        if(!ReadMapField(result, 0, text, sizeof text) || !ReadInteger(text, index)) {
            ok = false;
            break;
        }
        if(index < 1 || index > MAX_OBJECT) {
            ok = false;
            break;
        }
        if(Object[index][Index]) {
            ok = false;
            break;
        }

        if(!ReadMapField(result, 1, text, sizeof text) || !ReadInteger(text, modelid) || !ValidObjectModel(modelid)) {
            ok = false;
            break;
        }

        for(new j = 0; j < 6; j++) {
            if(!ReadMapField(result, j + 2, text, sizeof text) || !ReadFloat(text, position[j])) {
                ok = false;
                break;
            }
        }
        if(!ok) break;

        Object[index][Index] = index;
        Object[index][ModelID] = modelid;
        Object[index][PosX] = position[0];
        Object[index][PosY] = position[1];
        Object[index][PosZ] = position[2];
        Object[index][RotX] = position[3];
        Object[index][RotY] = position[4];
        Object[index][RotZ] = position[5];

        if(i < count - 1 && !DB_SelectNextRow(result)) ok = false;
    }

    DB_FreeResultSet(result);
    if(!ok) {
        ClearObjects();
        return 0;
    }

    for(new i = 1; i <= MAX_OBJECT; i++) {
        if(!ValidObjectIndex(i)) continue;
        Object[i][ObjectID] = CreateDynamicObject(Object[i][ModelID], Object[i][PosX], Object[i][PosY], Object[i][PosZ], Object[i][RotX], Object[i][RotY], Object[i][RotZ], -1, -1, -1);
        if(!IsValidDynamicObject(Object[i][ObjectID])) {
            ClearObjects();
            return 0;
        }
        ObjectCount++;
        UpdateObjectLabel(i);
    }
    return 1;
}
