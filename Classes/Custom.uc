class Custom extends FakedPlus;


var() config int nConfigFakes;
var() config int nReservedSlots;


function PostBeginPlay()
{
  ReservedPlayerSlots = Clamp(nReservedSlots,1,32);
  nFakes = Clamp(nConfigFakes,0,20);

  super.PostBeginPlay();
}


function EditConfigSlots(PlayerController pc, string mod)
{
  local int slots;

  slots = Clamp(Int(mod), 1, 32);
  
  nReservedSlots = slots;
  SaveConfig();
  SendMessage(pc, "%wConfig Reserved Player Slots are changed to - %b"$slots);
}


function EditConfigFakes(PlayerController pc, string mod)
{
  local int faked;

  faked = Clamp(Int(mod), 0, 20);

  nConfigFakes = faked;
  SaveConfig();
  SendMessage(pc, "%wConfig Faked Players are changed to - %b"$faked);
}


static function FillPlayInfo(PlayInfo PlayInfo)
{
  super.FillPlayInfo(PlayInfo);

  PlayInfo.AddSetting("Faked Plus", "nReservedSlots", "Reserved Player Slots", 0, 2, "Text", "6;1:32", "", False, False);
  PlayInfo.AddSetting("Faked Plus", "nConfigFakes", "Faked Players", 0, 2, "Text", "6;1:20", "", False, False);
}


static function string GetDescriptionText(string s)
{
  switch (s)
  {
    case "nConfigFakes":
      return "Forced Faked Players";
    case "nReservedSlots":
      return "Reserved Player Slots";
  }

  return super.GetDescriptionText(s);
}


static function string GetDisplayText(string PropName)
{
  switch (PropName)
  {
    case "nConfigFakes":
      return "Forced Faked Players";
    case "nReservedSlots":
      return "Reserved Player Slots";
  }

  return "Null";
}


defaultproperties
{
  FriendlyName="Choosen Amount of Faked Players"
  Description="For lulz and >6 fakes."

  nConfigFakes=6
  nReservedSlots=6
  bUseReservedSlots=true
}