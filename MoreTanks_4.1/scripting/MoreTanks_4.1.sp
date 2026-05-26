#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <left4dhooks>

#define PLUGIN_NAME "MoreTanks"
#define PLUGIN_VERSION "4.1"

ConVar g_hEnable;
ConVar g_hValue;

int g_iSpawnLock = 0;

public Plugin myinfo =
{
    name = PLUGIN_NAME,
    author = "こあ & イオ",
    description = "Stable multi-tank spawn via L4D2 Hook",
    version = PLUGIN_VERSION
};

public void OnPluginStart()
{
    g_hEnable = CreateConVar(
        "MoreTanks_Enable",
        "1",
        "-",
        FCVAR_NOTIFY,
        true, 0.0,
        true, 1.0
    );

    g_hValue = CreateConVar(
        "MoreTanks_Value",
        "2",
        "-",
        FCVAR_NOTIFY,
        true, 0.0,
        true, 20.0
    );

    AutoExecConfig(true, "MoreTanks_4.1");
}

// ----------------------------
// Tank spawn hook
// ----------------------------
public Action L4D_OnSpawnTank(const float vecPos[3], const float vecAng[3])
{
    if (!g_hEnable.BoolValue)
        return Plugin_Continue;

    if (g_iSpawnLock > 0)
        return Plugin_Continue;

    int count = g_hValue.IntValue;

    if (count <= 0)
        return Plugin_Continue;

    g_iSpawnLock = 1;

    for (int i = 0; i < count; i++)
    {
        float delay = 0.15 + (0.05 * float(i));

        DataPack pack;
        CreateDataTimer(delay, Timer_SpawnTank, pack);

        pack.WriteFloat(vecPos[0]);
        pack.WriteFloat(vecPos[1]);
        pack.WriteFloat(vecPos[2]);
    }

    CreateTimer(1.0, Timer_ResetLock);

    return Plugin_Continue;
}

// ----------------------------
// Spawn execution
// ----------------------------
public Action Timer_SpawnTank(Handle timer, DataPack pack)
{
    pack.Reset();

    float pos[3];

    pos[0] = pack.ReadFloat();
    pos[1] = pack.ReadFloat();
    pos[2] = pack.ReadFloat();

    L4D2_SpawnTank(pos, NULL_VECTOR);

    return Plugin_Stop;
}

// ----------------------------
// Lock reset
// ----------------------------
public Action Timer_ResetLock(Handle timer)
{
    g_iSpawnLock = 0;
    return Plugin_Stop;
}