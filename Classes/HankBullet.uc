//=============================================================================
// HankBullet.
//=============================================================================
class HankBullet extends Tracer;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	PlaySound(SpawnSound, SLOT_None, 1,,, 0.85);
}

simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
	local vector momentum;

	if ( (Other != Instigator) && (Projectile(Other) == None))
	{
		if ( Role == ROLE_Authority )
		{
			momentum = MomentumTransfer * Normal(Velocity);
			Other.TakeDamage( Damage, instigator, HitLocation, momentum, 'shot');
		}
		Destroy();
	}
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	Spawn(class'UT_WallHit',,, HitLocation+HitNormal*9, Rotator(HitNormal));
	Destroy();
}

defaultproperties
{
      Damage=5.000000
      MomentumTransfer=750
      SpawnSound=Sound'Gauntlet-10-BetaV4.M16.M16shot'
      Style=STY_Translucent
      MultiSkins(1)=FireTexture'UnrealShare.Effect1.FireEffect1u'
}
