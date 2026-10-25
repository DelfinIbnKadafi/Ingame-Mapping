
// make new database file
stock NewDatabase(const filename[]) {
    // make new db files
    new path[128];
    format(path, sizeof path, "%s/%s.db", DB_PATH, filename);
    DB:NewDB = db_open(path);

    // fill with default data
    new DBResult:result = db_query(Database, "CREATE TABLE IF NOT EXISTS objects (model INTEGER NOT NULL, x REAL NOT NULL, y REAL NOT NULL, z REAL NOT NULL, rx REAL NOT NULL, ry REAL NOT NULL, rz REAL NOT NULL)");

    if(result) {
        db_free_result(result);
        print("[DATABASE] Succesfully make new database.");
    }

    return 1;
}