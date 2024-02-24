//=============================================================================
// BruteTorchurer.
//=============================================================================
class BruteTorchurer extends Brute;

var float fireticktime;
var int countLeft,countRight,countCenter;
var bool bLeft,bRight,bCenter;

function tick(float dt)
{
	fireticktime += dt;
	if(fireticktime > 0.025)
	{
		fireticktime -= 0.025;
		if(bLeft)
		{
			countLeft--;
			if(countLeft <= 0) bLeft = false;
			FireProjectile( vect(1.2,0.7,0.4), 750);
		}
		if(bRight)
		{
			countRight--;
			if(countRight <= 0) bRight = false;
			FireProjectile( vect(1.2,-0.7,0.4), 750);
		}
		if(bCenter)
		{
			countCenter--;
			if(countCenter <= 0) bCenter = false;
			FireProjectile( vect(1.2,-0.55,0.0), 800);
		}
		if(!(bLeft || bRight || bCenter))
		{
			AmbientSound=Default.AmbientSound;
			Disable('tick');
		}
	}
}
function SpawnLeftShot()
{
	countLeft = 25+Rand(15);
	bLeft = true;
	AmbientSound=Sound'UnrealShare.General.BRocket';
	Enable('tick');
}

function SpawnRightShot()
{
	countRight = 25+Rand(15);
	bRight = true;
	AmbientSound=Sound'UnrealShare.General.BRocket';
	Enable('tick');
}
function GutShotTarget()
{
	countCenter = 35+Rand(15);
	bCenter = true;
	AmbientSound=Sound'UnrealShare.General.BRocket';
	Enable('tick');
}

defaultproperties
{
      fireticktime=0.000000
      countLeft=0
      countRight=0
      countCenter=0
      bLeft=False
      bRight=False
      bCenter=False
      WhipDamage=35
      RefireRate=0.500000
      bLeadTarget=True
      RangedProjectile=Class'Gauntlet-10-BetaV4.Flame2'
      SightRadius=2000.000000
      Health=550
      ReducedDamageType="Burned"
      ReducedDamagePct=0.900000
      Skin=Texture'Gauntlet-10-BetaV4.TorcherSkin'
      DrawScale=1.150000
      TransientSoundVolume=6.000000
      CollisionRadius=60.000000
      CollisionHeight=60.000000
      Mass=500.000000
}
