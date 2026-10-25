// file for declarate all data of filterscripts like object data, etc
enum ObjectData {
    Index,
    ObjectID,
    ModelID,
    STREAMER_TAG_3D_TEXT_LABEL:LabelID,
    Float:PosX,
    Float:PosY,
    Float:PosZ,
    Float:RotX,
    Float:RotY,
    Float:RotZ
}

// 1000 max objects for prototype
#define MAX_OBJECT 1000 // id is start from 1 to 1000

new Object[MAX_OBJECT + 1][ObjectData];
new ObjectCount = 0;

// varibale for curently map opened
new bool:MapOpened = false;
new MapName[64];

// player data
new PlayerName[MAX_PLAYERS][MAX_PLAYER_NAME];
new EditingObject[MAX_PLAYERS];
new ObjectEditor[MAX_OBJECT + 1];

// toggle label for shared map
new bool:ToggleLabel = true;

// data folder, all path is inside scriptfiles
#define MAP_FOLDER "ingame_mapping"
#define DB_FOLDER "ingame_mapping/save"
#define EXPORT_FOLDER "ingame_mapping/exported"
#define MAX_IMPORT_SIZE (1024 * 1024)

// database
new DB:Database = DB:0;
