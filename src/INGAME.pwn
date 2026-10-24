#include "open.mp"
#include "zcmd"
#include "sscanf2"
#include "streamer"

// modular file
#include "DATA.pwn"
#include "EDIT_OBJECT.pwn"
#include "COMMANDS.pwn"

#define FILTERSCRIPT

public OnFilterScriptInit() {
    printf("[FIlterscript] Loaded Ingame Mapping");
    return 1;
}