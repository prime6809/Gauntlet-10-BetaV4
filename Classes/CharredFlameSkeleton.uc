//=============================================================================
// CharredFlameSkeleton.
//=============================================================================
class CharredFlameSkeleton expands skeleton;

auto state fallingdown
{
	simulated function timer()
	{
		spawn(class'BlackSmoke',self);
	}
	simulated function BeginState()
	{
		spawn(class'BlackSmoke',self);
		spawn(class'UT_SpriteBallExplosion',self);
	}
Begin:
	SetTimer(0.3,true);
	PlayAnim('All',0.2);
}

defaultproperties
{
      Skin=Texture'Gauntlet-10-BetaV4.Skins.Jskeleton0'
}
