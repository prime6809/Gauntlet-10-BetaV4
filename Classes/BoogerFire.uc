//=============================================================================
// BoogerFire.
//=============================================================================
class BoogerFire expands booger;

function PlayRangedAttack()
{
	PlayAnim('attack');
	FireProjectile( vect(1, 0, 0.8), 900);
}

function PlayMovingAttack()
{
	PlayRangedAttack();
}

// Time to Explode fiery death all over the player to spite them
function Died(pawn Killer, name damageType, vector HitLocation)
{
	local FireGlob fg;

	Spawn(class'FireRock',self);

	fg = Spawn(class'FireGlob',self);
	fg.GoToState('OnSurface');
	super.Died(Killer, damageType, HitLocation);
}

defaultproperties
{
      BiteDamage=100
      LungeDamage=150
      TimeBetweenAttacks=0.600000
      Aggressiveness=30.000000
      bHasRangedAttack=True
      RangedProjectile=Class'Gauntlet-10-BetaV4.ngfireGel'
      ProjectileSpeed=1100.000000
      GroundSpeed=480.000000
      WaterSpeed=200.000000
      AirSpeed=380.000000
      AccelRate=300.000000
      Health=380
      ReducedDamageType="Burned"
      ReducedDamagePct=1.000000
      Texture=WetTexture'Gauntlet-10-BetaV4.FireBoogerSkin'
      DrawScale=0.700000
      bUnlit=True
      CollisionRadius=24.000000
      CollisionHeight=6.500000
}
