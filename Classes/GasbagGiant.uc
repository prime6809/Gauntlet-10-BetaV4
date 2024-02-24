//=============================================================================
// GasbagGiant.
//=============================================================================
class GasbagGiant extends Gasbag;

var() class<actor> RangedProj2;

function SpawnBelch()
{
	local vector X,Y,Z, projStart;
	local actor P;
	 
	GetAxes(Rotation,X,Y,Z);
	projStart = Location + 0.5 * CollisionRadius * X - 0.3 * CollisionHeight * Z;
	
	if(frand()<0.7)
		P = spawn(RangedProjectile ,self,'',projStart,AdjustAim(ProjectileSpeed,
		projStart, 400, bLeadTarget, bWarnTarget));
	else
		P = spawn(RangedProj2 ,self,'',projStart,AdjustAim(ProjectileSpeed,
		projStart, 400, bLeadTarget, bWarnTarget));
}

defaultproperties
{
      RangedProj2=Class'Gauntlet-10-BetaV4.FireRockFall'
      PunchDamage=40
      PoundDamage=65
      RangedProjectile=Class'Gauntlet-10-BetaV4.FireRock'
      ProjectileSpeed=800.000000
      Health=600
      CombatStyle=0.500000
      DrawScale=2.250000
      CollisionRadius=120.000000
      CollisionHeight=81.000000
}
