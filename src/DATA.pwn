// file for declarate all data of filterscripts like object data, etc
enum ObjectData {
    ObjectID,
    ModelID,
    Float:PosX,
    Float:PosY,
    Float:PosZ,
    Float:RotX,
    Float:RotY,
    Float:RotZ
}

// 1000 max objects for prototype
#define MAX_OBJECTS 1000 // id is start from 1 to 1000

new Object[MAX_OBJECTS][ObjectData];

// varibale for curently map opened
new bool:MapOpened = false;
new MapName[64];