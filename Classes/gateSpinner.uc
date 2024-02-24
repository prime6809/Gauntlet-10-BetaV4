//=============================================================================
// gateSpinner.
//=============================================================================
class gateSpinner expands spinner
config(GauntletScoreing);

// Here are some variable gauntlet will be using to handle scoring
var(U4eGauntlet) globalconfig int Value;

// Were going to let the game handle scoring!
function Died(pawn Killer, name damageType, vector HitLocation)
{
	u4egauntlet(level.game).MonsterKilled(Value,Killer,self);
	super.Died(Killer, damageType, HitLocation);
}

defaultproperties
{
      Value=4
      MenuName="Spinner"
      NameArticle="a "
}
