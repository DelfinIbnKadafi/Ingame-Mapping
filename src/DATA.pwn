// file for declarate all data of filterscripts like object data, etc
enum ObjectData {
    ObjectID,
    ModelID,
    Text3D:LabelID,
    Float:PosX,
    Float:PosY,
    Float:PosZ,
    Float:RotX,
    Float:RotY,
    Float:RotZ
}

// 1000 max objects for prototype
#define MAX_OBJECT 1000 // id is start from 1 to 1000

new Object[MAX_OBJECT][ObjectData];

new ObjectCount = 0;

// varibale for curently map opened
new bool:MapOpened = false;
new MapName[64];

// toggle label
new bool:ToggleLabel = true;