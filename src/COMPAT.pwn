// only use old native names for SA-MP build, dont change the includes
#if defined INGAME_SAMP
    native DB:LegacyDBOpen(const filename[]) = db_open;
    native LegacyDBClose(DB:database) = db_close;
    native DBResult:LegacyDBQuery(DB:database, const query[]) = db_query;
    native LegacyDBFreeResult(DBResult:result) = db_free_result;
    native LegacyDBRows(DBResult:result) = db_num_rows;
    native LegacyDBNextRow(DBResult:result) = db_next_row;
    native LegacyDBField(DBResult:result, field, output[], size) = db_get_field;
    native LegacyCancelEdit(playerid) = CancelEdit;

    #define DB_Open LegacyDBOpen
    #define DB_Close LegacyDBClose
    #define DB_ExecuteQuery LegacyDBQuery
    #define DB_FreeResultSet LegacyDBFreeResult
    #define DB_GetRowCount LegacyDBRows
    #define DB_SelectNextRow LegacyDBNextRow
    #define DB_GetFieldString LegacyDBField
    #define CancelEdit LegacyCancelEdit
#endif
