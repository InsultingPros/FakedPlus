class Utility extends object
    abstract;


// mutate help related stuff
final static function array<string> getHlpStrings(string arg, out array<string> locarr)
{
    if (arg == "")
    {
        locarr[locarr.Length] = "%rFaked Plus Mutator";
        locarr[locarr.Length] = "%wCommands that have ON / OFF switch: %gLOCK%w, %gSPEC%w, %gDRAMA%w,";
        locarr[locarr.Length] = "%gADMINONLY%w, %gSOLO%w.";
        locarr[locarr.Length] = "%wCommands that require int values: %gFAKED%w, %gHEALTH%w, %gSPEC%w,";
        locarr[locarr.Length] = "%gReservedSlots%w, %gConfigFakes%w.";
        locarr[locarr.Length] = "%wCommands that work as is: %gSKIP%w, %gSAVE%w, %gCREDITS%w, %gSTATUS%w.";
        locarr[locarr.Length] = "%wIf you want to know what command does what type '%gmutate help <cmd>%w'.";
        return locarr;
    }

    else if (arg ~= "SOLO")
    {
        locarr[locarr.Length] = "%gSOLO";
        locarr[locarr.Length] = "%wEnable Solo Mode. Leaves only 1 player slot.";
        return locarr;
    }

    else if (arg ~= "ConfigFakes" || arg ~= "cf")
    {
        locarr[locarr.Length] = "%gConfigFakes";
        locarr[locarr.Length] = "%wChange and save config value of faked players. Works only for %rCustom%w mode!";
        return locarr;
    }

    else if (arg ~= "ReservedSlots" || arg ~= "rs")
    {
        locarr[locarr.Length] = "%gReservedSlots";
        locarr[locarr.Length] = "%wChange and save config value of reserved player slots. Works only for %rCustom%w mode!";
        return locarr;
    }

    else if (arg ~= "SKIP" || arg ~= "SKP")
    {
        locarr[locarr.Length] = "%gSKIP";
        locarr[locarr.Length] = "%wSkip trader time.";
        return locarr;
    }

    else if (arg ~= "DRAMA" || arg ~= "SLOMO")
    {
        locarr[locarr.Length] = "%gSLOMO {ON / OFF}";
        locarr[locarr.Length] = "%wSwitch SloMo.";
        return locarr;
    }

    else if (arg ~= "ADMINONLY" || arg ~= "ADMIN")
    {
        locarr[locarr.Length] = "%gADMINONLY {ON / OFF}";
        locarr[locarr.Length] = "%wAllow non-admin players to use commands.";
        return locarr;
    }

    else if (arg ~= "HEALTH" || arg ~= "HP")
    {
        locarr[locarr.Length] = "%gHEALTH <num>";
        locarr[locarr.Length] = "%wForce zeds minimal health. Limited to 1-6.";
        return locarr;
    }

    else if (arg ~= "SAVE")
    {
        locarr[locarr.Length] = "%gSAVE";
        locarr[locarr.Length] = "%wSave all changed config variables.";
        return locarr;
    }

    else if (arg ~= "FAKED" || arg ~= "FAKE" || arg ~= "FAKES")
    {
        locarr[locarr.Length] = "%gFAKED <num>";
        locarr[locarr.Length] = "%wForce selected amount of fakes.";
        return locarr;
    }

    else if (arg ~= "LOCK" || arg ~= "PLAYER" || arg ~= "PLAYERS")
    {
        locarr[locarr.Length] = "%gLOCK {ON / OFF}";
        locarr[locarr.Length] = "%gLOCK <num>";
        locarr[locarr.Length] = "%wSet player slots.";
        return locarr;
    }

    else if (arg ~= "SPEC" || arg ~= "SPECS" || arg ~= "SPECTATOR" || arg ~= "SPECTATORS")
    {
        locarr[locarr.Length] = "%gSPEC {ON / OFF / DEFAULT}";
        locarr[locarr.Length] = "%gSPEC <num>";
        locarr[locarr.Length] = "%wSet spectator slots.";
        return locarr;
    }

    else if (arg ~= "STATUS")
    {
        locarr[locarr.Length] = "%wPrints all main settings that are currently used.";
        return locarr;
    }
}


defaultproperties{}