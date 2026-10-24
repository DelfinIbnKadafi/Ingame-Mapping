#include "a_samp"
#include "zcmd"
#include "sscanf2"
#include "streamer"

// modular file
#include "DATA.pwn"
#include "COMMANDS.pwn"

// delete warning 237
#pragma warning disable 237

public OnFilterScriptInit() {
    printf("[FIlterscript] Loaded Ingame Mapping");
    return 1;
}