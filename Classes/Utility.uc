class Utility extends object
    abstract;


const lineSeparator="%w=============================";
const spaces16="                ";

// mutate help related stuff
final static function array<string> getHlpStrings(string arg, out array<string> str)
{
    if (arg == "")
    {
        // make it more readable and fancy!
        str[str.Length] = lineSeparator;
        str[str.Length] = spaces16 $ "%rFAKED PLUS HELPER";
        str[str.Length] = lineSeparator;
        str[str.Length] = "%w  Commands with ON / OFF switch: %gLOCK%w, %gSPEC%w, %gDRAMA%w, %gADMINONLY%w, %gSOLO%w.";
        str[str.Length] = "%w  Commands with int values: %gFAKED%w, %gHEALTH%w, %gSPEC%w,%gReservedSlots%w, %gConfigFakes%w.";
        str[str.Length] = "%w  Commands that work as is: %gSKIP%w, %gSAVE%w, %gCREDITS%w, %gSTATUS%w.";
        str[str.Length] = "%w  If you want to know what command does what - type '%gmutate help <cmd>%w'.";
        str[str.Length] = lineSeparator;
        return str;
    }

    else if (arg ~= "SOLO")
    {
        str[str.Length] = "%gSOLO";
        str[str.Length] = "%wEnable Solo Mode. Leaves only 1 player slot.";
        return str;
    }

    else if (arg ~= "ConfigFakes" || arg ~= "cf")
    {
        str[str.Length] = "%gConfigFakes";
        str[str.Length] = "%wChange and save config value of faked players. Works only for %rCustom%w mode!";
        return str;
    }

    else if (arg ~= "ReservedSlots" || arg ~= "rs")
    {
        str[str.Length] = "%gReservedSlots";
        str[str.Length] = "%wChange and save config value of reserved player slots. Works only for %rCustom%w mode!";
        return str;
    }

    else if (arg ~= "SKIP" || arg ~= "SKP")
    {
        str[str.Length] = "%gSKIP";
        str[str.Length] = "%wSkip trader time.";
        return str;
    }

    else if (arg ~= "DRAMA" || arg ~= "SLOMO")
    {
        str[str.Length] = "%gSLOMO {ON / OFF}";
        str[str.Length] = "%wSwitch SloMo.";
        return str;
    }

    else if (arg ~= "ADMINONLY" || arg ~= "ADMIN")
    {
        str[str.Length] = "%gADMINONLY {ON / OFF}";
        str[str.Length] = "%wAllow non-admin players to use commands.";
        return str;
    }

    else if (arg ~= "HEALTH" || arg ~= "HP")
    {
        str[str.Length] = "%gHEALTH <num>";
        str[str.Length] = "%wForce zeds minimal health. Limited to 1-6.";
        return str;
    }

    else if (arg ~= "SAVE")
    {
        str[str.Length] = "%gSAVE";
        str[str.Length] = "%wSave all changed config variables.";
        return str;
    }

    else if (arg ~= "FAKED" || arg ~= "FAKE" || arg ~= "FAKES")
    {
        str[str.Length] = "%gFAKED <num>";
        str[str.Length] = "%wForce selected amount of fakes.";
        return str;
    }

    else if (arg ~= "LOCK" || arg ~= "PLAYER" || arg ~= "PLAYERS")
    {
        str[str.Length] = "%gLOCK {ON / OFF}";
        str[str.Length] = "%gLOCK <num>";
        str[str.Length] = "%wSet player slots.";
        return str;
    }

    else if (arg ~= "SPEC" || arg ~= "SPECS" || arg ~= "SPECTATOR" || arg ~= "SPECTATORS")
    {
        str[str.Length] = "%gSPEC {ON / OFF / DEFAULT}";
        str[str.Length] = "%gSPEC <num>";
        str[str.Length] = "%wSet spectator slots.";
        return str;
    }

    else if (arg ~= "STATUS")
    {
        str[str.Length] = "%wPrints all main settings that are currently used.";
        return str;
    }
}


defaultproperties{}