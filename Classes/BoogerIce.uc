//=============================================================================
// BoogerIce.
//=============================================================================
class BoogerIce extends Booger;

function PlayRangedAttack()
{
	PlayAnim('attack');
	FireProjectile( vect(1, 0, 0.8), 900);
}

function PlayMovingAttack()
{
	PlayRangedAttack();
}

defaultproperties
{
      BiteDamage=25
      LungeDamage=50
      bHasRangedAttack=True
      RangedProjectile=Class'Gauntlet-10-BetaV4.BigFreezeBlob'
      Health=250
      ReducedDamageType="freezed"
      ReducedDamagePct=1.000000
      Texture=Texture'UnrealI.Skins.JBlob1'
      DrawScale=0.600000
      CollisionRadius=22.000000
      CollisionHeight=5.500000
}
