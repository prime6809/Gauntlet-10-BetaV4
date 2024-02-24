//=============================================================================
// GauntletMapList.
//=============================================================================
class GauntletMapList expands MapList;

var(Maps) config string Maps[100];
var config int MapNum;

function string GetNextMap()
{
	local string CurrentMap;
	local int i;

	CurrentMap = GetURLMap();
	if ( CurrentMap != "" )
	{
		if ( Right(CurrentMap,4) ~= ".unr" )
			CurrentMap = CurrentMap;
		else
			CurrentMap = CurrentMap$".unr";

		for ( i=0; i<ArrayCount(Maps); i++ )
		{
			if ( CurrentMap ~= Maps[i] )
			{
				MapNum = i;
				break;
			}
		}
	}

	// search vs. w/ or w/out .unr extension

	MapNum++;
	if ( MapNum > ArrayCount(Maps) - 1 )
		MapNum = 0;
	if ( Maps[MapNum] == "" )
		MapNum = 0;

	SaveConfig();
	return Maps[MapNum];
}

defaultproperties
{
      Maps(0)=""
      Maps(1)=""
      Maps(2)=""
      Maps(3)=""
      Maps(4)=""
      Maps(5)=""
      Maps(6)=""
      Maps(7)=""
      Maps(8)=""
      Maps(9)=""
      Maps(10)=""
      Maps(11)=""
      Maps(12)=""
      Maps(13)=""
      Maps(14)=""
      Maps(15)=""
      Maps(16)=""
      Maps(17)=""
      Maps(18)=""
      Maps(19)=""
      Maps(20)=""
      Maps(21)=""
      Maps(22)=""
      Maps(23)=""
      Maps(24)=""
      Maps(25)=""
      Maps(26)=""
      Maps(27)=""
      Maps(28)=""
      Maps(29)=""
      Maps(30)=""
      Maps(31)=""
      Maps(32)=""
      Maps(33)=""
      Maps(34)=""
      Maps(35)=""
      Maps(36)=""
      Maps(37)=""
      Maps(38)=""
      Maps(39)=""
      Maps(40)=""
      Maps(41)=""
      Maps(42)=""
      Maps(43)=""
      Maps(44)=""
      Maps(45)=""
      Maps(46)=""
      Maps(47)=""
      Maps(48)=""
      Maps(49)=""
      Maps(50)=""
      Maps(51)=""
      Maps(52)=""
      Maps(53)=""
      Maps(54)=""
      Maps(55)=""
      Maps(56)=""
      Maps(57)=""
      Maps(58)=""
      Maps(59)=""
      Maps(60)=""
      Maps(61)=""
      Maps(62)=""
      Maps(63)=""
      Maps(64)=""
      Maps(65)=""
      Maps(66)=""
      Maps(67)=""
      Maps(68)=""
      Maps(69)=""
      Maps(70)=""
      Maps(71)=""
      Maps(72)=""
      Maps(73)=""
      Maps(74)=""
      Maps(75)=""
      Maps(76)=""
      Maps(77)=""
      Maps(78)=""
      Maps(79)=""
      Maps(80)=""
      Maps(81)=""
      Maps(82)=""
      Maps(83)=""
      Maps(84)=""
      Maps(85)=""
      Maps(86)=""
      Maps(87)=""
      Maps(88)=""
      Maps(89)=""
      Maps(90)=""
      Maps(91)=""
      Maps(92)=""
      Maps(93)=""
      Maps(94)=""
      Maps(95)=""
      Maps(96)=""
      Maps(97)=""
      Maps(98)=""
      Maps(99)=""
      MapNum=0
}
