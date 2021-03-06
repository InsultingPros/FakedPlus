// Author NikC-
// https://github.com/InsultingPros/FakedPlus


class FakedPlus extends Mutator
    config(FakedPlus)
    abstract;


var() config bool bNoDrama;       // slomo switch
var() config bool bAdminOnly;     // forbid other players to use mutate
var() config bool bSoloMode;      // leave only 1 free slot

var() config int minNumPlayers;   // int for zed hp calculation

var int nFakes;                   // main int which controlls fakes amount
var int ReservedPlayerSlots;

var bool bLockOn;                 // detects server lock (mutate lock on)
var bool bRefreshMaxPlayers;
var bool bUseReservedSlots;

var KFGameType KFGT;

var int iOriginalSpectators;      // server's spectator slots
var int iOriginalPlayerSlots;     // server's player slots, in case of increased numbers

const lineSeparator="%w=============================";
const spaces16="                ";
const logMyName=">>> FAKED PLUS: ";


function PostBeginPlay()
{
    KFGT = KFGameType(level.game);
    // shut down if we can't find KFGameType!
    // since most of our code works with it
    if (KFGT == none)
    {
        log(logMyName $ "KFGameType not found. TERMINATING!");
        Destroy();
        return;
    }

    // keep in mind server's spectator count
    iOriginalSpectators = KFGT.MaxSpectators;
    iOriginalPlayerSlots = KFGT.MaxPlayers;

    SetTimer(1.0, true);
}


// my OCD doesnt like when empty servers are on top of the server browser
auto state waitForPlayers
{
    // state timer, overrides global
    event Timer()
    {
        // if in lobby state
        if (KFGT.IsInState('PendingMatch'))
        {
            // if no real players, add nothing
            if (intRealPlayers() == 0)
                KFGT.NumPlayers = 0;
            // if any player join, add all fakes
            else
                KFGT.NumPlayers = nFakes + intRealPlayers();
        }
        // break this and go to global state
        else
            GoToState('');
    }
begin:
    // start the overriden timer until game starts
    SetTimer(1.0, true);
}


// global timer
function Timer()
{
    // controll over slomo
    if (bNoDrama)
        KFGT.LastZedTimeEvent = Level.TimeSeconds;

    // apply bSoloMode or custom slot settings
    if (bRefreshMaxPlayers)
        AdjustPlayerSlots();

    if (KFGT.IsInState('MatchInProgress'))
    {
        KFGT.NumPlayers = nFakes + intRealPlayers();
        return;
    }

    // do this to make map voting less painfull and instant after we wipe
    else if (KFGT.IsInState('MatchOver'))
    {
        KFGT.NumPlayers = intRealPlayers();
    }
}


function AdjustPlayerSlots()
{
    bRefreshMaxPlayers = false;

    if (bSoloMode)
    {
        KFGT.MaxPlayers = nFakes + 1;
        return;
    }

    if (bUseReservedSlots)
        KFGT.MaxPlayers = nFakes + ReservedPlayerSlots;
}


// count non-spectator players
final private function int intRealPlayers()
{
    local Controller c;
    local int realPlayersCount;

    for (c = Level.ControllerList; c != none; c = c.NextController)
        if (c.IsA('PlayerController') && c.PlayerReplicationInfo != none && !c.PlayerReplicationInfo.bOnlySpectator)
            realPlayersCount++;

    return realPlayersCount;
}


// count currently alive players
final private function int intAlivePlayers()
{
    local Controller c;
    local int alivePlayersCount;

    for (c = Level.ControllerList; c != none; c = c.NextController)
        if (c.IsA('PlayerController') && c.Pawn != none && c.Pawn.Health > 0)
            alivePlayersCount ++;

    return alivePlayersCount;
}


// change zed health, works similar to HP config mut
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    local KFMonster monster;
    local int alivePlayersCount;

    // if (KFMonster(Other) != none)
    // {
    //     monster = KFMonster(Other);
    //     newHp= monster.Health / monster.NumPlayersHealthModifer() * hpScale(monster.PlayerCountHealthScale);
    //     newHeadHp= monster.HeadHealth / monster.NumPlayersHeadHealthModifer() * hpScale(monster.PlayerNumHeadHealthScale);
    //     if (newHp > monster.Health)
    //     {
    //         monster.Health= newHp;
    //         monster.HealthMax= newHp;
    //         monster.HeadHealth= newHeadHp;
    //         if(Level.Game.NumPlayers == 1 && minNumPlayers > 1) {
    //             monster.MeleeDamage/= 0.75;
    //         }
    //     }
    // }

    // FIXME pls ;_;
    if (KFMonster(Other) != none)
    {
        monster = KFMonster(Other);
        alivePlayersCount = intAlivePlayers();
        if (alivePlayersCount < minNumPlayers)
        {
            monster.Health *= hpScale(monster.PlayerCountHealthScale) / monster.NumPlayersHealthModifer();
            monster.HealthMax = monster.Health;
            monster.HeadHealth *= hpScale(monster.PlayerNumHeadHealthScale) / monster.NumPlayersHeadHealthModifer();

            monster.MeleeDamage /= 0.75;
            monster.ScreamDamage /= 0.75;
            monster.SpinDamConst /= 0.75;
            monster.SpinDamRand /= 0.75;
        }
    }

    return super.CheckReplacement(Other, bSuperRelevant);
}


final private function float hpScale(float hpScale)
{
    return 1.0 + (minNumPlayers - 1) * hpScale;
}


final private function bool bAllowExec(PlayerController Sender)
{
    local PlayerReplicationInfo pri;

    // if we are adimn, we are golden
    if (bAllowAdminsOnly(Sender))
        return true;

    pri = Sender.PlayerReplicationInfo;

    // no pri OR usual player in specs, commands NOT allowed 
    if (pri == none || (!pri.bAdmin && (pri.bOnlySpectator || bAdminOnly)))
        return false;

    // logged in admin OR usual player while not being a spec, commands allowed for everyone
    else if (pri.bAdmin || (!pri.bAdmin && !pri.bOnlySpectator && !bAdminOnly))
        return true;

    // fallback
    else
        return false;
}


final private function bool bAllowAdminsOnly(PlayerController Sender)
{
    // listened server, solo support + logged in admin
    return (Level.NetMode == NM_Standalone || Level.NetMode == NM_ListenServer)
            || (Sender.PlayerReplicationInfo != none && Sender.PlayerReplicationInfo.bAdmin);
}


function deduceHelp(PlayerController Sender, string arg)
{
    local int i;
    local array<string> arrStrings;

    class'Utility'.static.getHlpStrings(arg, arrStrings);
    for (i = 0; i < arrStrings.length; i++)
    {
        SendMessage(Sender, arrStrings[i]);
    }
}


final private function string getSenderName(PlayerController Sender)
{
    local PlayerReplicationInfo pri;
    local string s;

    pri = Sender.PlayerReplicationInfo;

    if (pri == none)
        s = "Someone";
    else
        s = pri.PlayerName;

    return "%w[%b" $ s $ " %wexecuted] ";
}


function Mutate(string MutateString, PlayerController Sender)
{
    local int i, zedHP;
    local array<String> wordsArray;
    local String command, mod;
    local array<String> modArray;

    // don't break the chain!
    super.Mutate(MutateString, Sender);

    // start our code
    // at first check if we can execute any command
    if (!bAllowExec(Sender))
    {
        SendMessage(Sender, "%bFAKED PLUS: %wmutate commands require %rADMIN %wprivileges!");
        return;
    }

    // ignore empty cmds and dont go further
    Split(MutateString, " ", wordsArray);
    if (wordsArray.Length == 0)
        return;

    // do stuff with our cmd
    command = wordsArray[0];
    if (wordsArray.Length > 1)
        mod = wordsArray[1];
    else
        mod = "";

    while (i + 1 < wordsArray.Length || i < 10)
    {
        if (i + 1 < wordsArray.Length)
        modArray[i] = wordsArray[i+1];
        else
        modArray[i] = "";
        i ++;
    }

    // 'mutate help <cmd>' and get detailed description
    if (command ~= "HELP" || command ~= "HLP" || command ~= "HALP")
    {
        deduceHelp(Sender, mod);
        return;
    }

    // changes fakes amount
    else if (command ~= "FAKED" || command ~= "FAKE" || command ~= "FAKES")
    {
        if (Int(mod) >= 0 && Int(mod) <= 5)
        {
            nFakes = Int(mod);
            if (bLockOn)
                KFGT.MaxPlayers = intRealPlayers() + nFakes;
            BroadcastText(getSenderName(Sender) $ "%wFaked players - %b"$Int(mod), true);
        }
        return;
    }

    // change zed health
    else if(command ~= "HEALTH" || command ~= "HP")
    {
        // limit health to 1-6
        zedHP = Clamp(Int(mod),1,6);

        minNumPlayers = zedHP;
        BroadcastText(getSenderName(Sender) $ "%wZeds minimal health is forced to - %b"$zedHP, true);
        return;
    }

    else if (command ~= "SOLO")
    {
        if (mod ~= "ON")
        {
            bSoloMode = true;
            SaveConfig();
            BroadcastText(getSenderName(Sender) $ "%wSolo mode - %b"$mod, true);
        }

        else if (mod ~= "OFF")
        {
            bSoloMode = false;
            SaveConfig();
            BroadcastText(getSenderName(Sender) $ "%wSolo mode - %b"$mod, true);
        }

        return;
    }

    // makes player slots equal to player+fakes amount, and prevents other people from joining
    else if (command ~= "LOCK" || command ~= "PLAYER" || command ~= "PLAYERS" || command ~= "SLOT")
    {
        if (mod ~= "ON")
        {
            KFGT.MaxPlayers = intRealPlayers() + nFakes;
            bLockOn = true;
            BroadcastText(getSenderName(Sender) $ "%wServer is %rLocked!", true);
        }

        else if (mod ~= "OFF")
        {
            KFGT.MaxPlayers = iOriginalPlayerSlots;
            bLockOn = false;
            BroadcastText(getSenderName(Sender) $ "%wServer is %rUnlocked!", true);
        }

        else
        {
            KFGT.MaxPlayers = Int(mod);
            BroadcastText(getSenderName(Sender) $ "%wPlayer slots are set to - %b"$Int(mod), true);
        }

        return;
    }

    // trader skip, doesnt work for actual waves
    else if (command ~= "SKIP" || command ~= "SKP")
    {
        if (!KFGT.bWaveInProgress && KFGT.waveNum <= KFGT.finalWave && KFGT.waveCountDown > 1)
        {
            KFGT.waveCountDown = 1;
            if (InvasionGameReplicationInfo(KFGT.GameReplicationInfo) != none)
                InvasionGameReplicationInfo(KFGT.GameReplicationInfo).waveNumber = KFGT.waveNum;
            BroadcastText(getSenderName(Sender) $ "%wTrader time skipped!", true);
        }
        return;
    }

    // prevents spectator joining or sets choosen amount of slots
    else if (command ~= "SPEC" || command ~= "SPECS" || command ~= "SPECTATOR" || command ~= "SPECTATORS")
    {
        if (mod ~= "DEFAULT")
        {
            KFGT.MaxSpectators = iOriginalSpectators;
            BroadcastText(getSenderName(Sender) $ "%wSpectator slots are restored to default!", true);
        }

        else if (mod ~= "OFF")
        {
            KFGT.MaxSpectators = 0;
            BroadcastText(getSenderName(Sender) $ "%wSpectator slots are disabled!", true);
        }

        else
        {
            KFGT.MaxSpectators = Int(mod);
            BroadcastText(getSenderName(Sender) $ "%wSpectator slots are set to - %b"$Int(mod), true);
        }

        return;
    }

    // a switch for slomo
    else if (command ~= "DRAMA" || command ~= "SLOMO")
    {
        if (mod ~= "ON")
        {
            bNoDrama = false;
            BroadcastText(getSenderName(Sender) $ "%wSlomo - %b"$mod, true);
        }

        else if (mod ~= "OFF")
        {
            bNoDrama = true;
            BroadcastText(getSenderName(Sender) $ "%wSlomo - %b"$mod, true);
        }

        return;
    }

    // disallow usual players to use mutate cmds
    else if (command ~= "ADMINONLY" || command ~= "ADMIN")
    {
        if (!bAllowAdminsOnly(Sender))
        {
            SendMessage(Sender, "%bFAKED PLUS: %wthis command require %rADMIN %wprivileges!");
            return;
        }

        if (mod ~= "ON")
        {
            bAdminOnly = true;
            BroadcastText(getSenderName(Sender) $ "%wOnly admins can use commands!", true);
        }

        else if (mod ~= "OFF")
        {
            bAdminOnly = false;
            BroadcastText(getSenderName(Sender) $ "%wAll players can use commands!", true);
        }

        return;
    }

    // save all changed stuff, since all other cmds dont touch the config
    else if (command ~= "SAVE")
    {
        if (!bAllowAdminsOnly(Sender))
        {
            SendMessage(Sender, "%bFAKED PLUS: %wthis command require %rADMIN %wprivileges!");
            return;
        }

        SaveConfig();
        SendMessage(Sender, "%rConfig is saved!");
        return;
    }

    else if (command ~= "STATUS" || command ~= "SETTINGS")
    {
        // make it as readable as posible
        SendMessage(Sender, lineSeparator);
        SendMessage(Sender, spaces16 $ "%rFAKED PLUS SETTINGS");
        SendMessage(Sender, lineSeparator);
        SendMessage(Sender, "%w  Fakes - %b " $ nFakes);
        SendMessage(Sender, "%w  Real Players - %b" $ intRealPlayers());
        SendMessage(Sender, "%w  Player Slots - %b" $ KFGT.MaxPlayers);
        SendMessage(Sender, "%w  Zeds Minimal Health - %b" $ minNumPlayers);
        SendMessage(Sender, "%w  Slomo disabled - %r" $ bNoDrama);
        SendMessage(Sender, "%w  AdminOnly - %r" $ bAdminOnly);
        SendMessage(Sender, "%w  SoloMode - %r" $ bSoloMode);
        SendMessage(Sender, "%w  Default Spectator Slots - %b" $ iOriginalSpectators);
        SendMessage(Sender, "%w  Current Spectator Slots - %b" $ KFGT.MaxSpectators);
        SendMessage(Sender, lineSeparator);
        return;
    }

    // why not?
    else if (command ~= "CREDITS")
    {
        SendMessage(Sender, "%wAuthor %bNikC-%w.");
        SendMessage(Sender, "%wSpecial thanks to %bdkanus%w, %ba1eat0r%w, %bbIbIbI(rus)%w, %bscary ghost%w, %bPoosh%w.");
        return;
    }

    else if (command ~= "ReservedSlots" || command ~= "rs")
    {
        EditConfigSlots(Sender, mod);
        return;
    }

    else if (command ~= "ConfigFakes" || command ~= "cf")
    {
        EditConfigFakes(Sender, mod);
        return;
    }
}


function EditConfigFakes(PlayerController pc, string mod)
{
    SendMessage(pc, "%wThis is meant to be used in %rCustom%w mode!");
}


function EditConfigSlots(PlayerController pc, string mod)
{
    SendMessage(pc, "%wThis is meant to be used in %rCustom%w mode!");
}

//============================== BROADCASTING ==============================
// send message to exact player
function SendMessage(PlayerController pc, coerce string message)
{
    if (pc == none || message == "")
        return;

    // clear all tags for WebAdmin
    if (pc.playerReplicationInfo.PlayerName ~= "WebAdmin" && pc.PlayerReplicationInfo.PlayerID == 0)
        message = StripFormattedString(message);
    // color me for usual player controllers
    else
        message = ParseFormattedLine(message);

    pc.teamMessage(none, message, 'FakedPlayers');
}


// send message to everyone and save to server log file
function BroadcastText(string message, optional bool bSaveToLog)
{
    local Controller c;

    for (c = level.controllerList; c != none; c = c.nextController)
    {
        if (c.IsA('PlayerController'))
            SendMessage(PlayerController(c), message);
    }

    if (bSaveToLog)
    {
        // remove color codes for server log
        message = StripFormattedString(message);
        log(logMyName $ message);
    }
}


// color codes for messages
static function string ParseFormattedLine(string input)
{
    ReplaceText(input, "%r", chr(27) $ chr(200) $ chr(1)   $ chr(1));
    ReplaceText(input, "%g", chr(27) $ chr(1)   $ chr(200) $ chr(1));
    ReplaceText(input, "%b", chr(27) $ chr(1)   $ chr(100) $ chr(200));
    ReplaceText(input, "%w", chr(27) $ chr(200) $ chr(200) $ chr(200));
    ReplaceText(input, "%y", chr(27) $ chr(200) $ chr(200) $ chr(1));
    ReplaceText(input, "%p", chr(27) $ chr(200) $ chr(1)   $ chr(200));

    return input;
}


// remove color codes
function string StripFormattedString(string input)
{
    ReplaceText(input, "%r", "");
    ReplaceText(input, "%g", "");
    ReplaceText(input, "%b", "");
    ReplaceText(input, "%w", "");
    ReplaceText(input, "%y", "");
    ReplaceText(input, "%p", "");

    return input;
}


//=========================================================================
static function FillPlayInfo(PlayInfo PlayInfo)
{
    super.FillPlayInfo(PlayInfo);

    PlayInfo.AddSetting("Faked Plus", "bNoDrama", "Disable SloMo", 0, 0, "check");
    PlayInfo.AddSetting("Faked Plus", "bAdminOnly", "Only Admins can use commands", 0, 0, "check");
    PlayInfo.AddSetting("Faked Plus", "bSoloMode", "Solo Mode", 0, 0, "check");
    PlayInfo.AddSetting("Faked Plus", "minNumPlayers", "Mimimal zed health", 0, 1, "Text", "4;0:6", "", False, False);
}


static function string GetDescriptionText(string SettingName)
{
    switch (SettingName)
    {
        case "bNoDrama":
            return "Enable/disable SloMo system";
        case "bAdminOnly":
            return "Only Admins can use commands";
        case "bSoloMode":
            return "Leaves only 1 avialable player slot";
        case "minNumPlayers":
            return "Force minimal health for zeds";
    }

    return super.GetDescriptionText(SettingName);
}


//=========================================================================
defaultproperties
{
    GroupName="KF-FakedPlus"
    FriendlyName="Faked Plus"
    Description="Simulate extra players for challenge. You can edit faked players amount in the config file."

    minNumPlayers=1
    ReservedPlayerSlots=0
    nFakes=0
    bSoloMode=false
    bLockOn=false
    bNoDrama=false
    bAdminOnly=true
    bUseReservedSlots=false
    bRefreshMaxPlayers=true
}