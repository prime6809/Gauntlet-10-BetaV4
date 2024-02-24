//=============================================================================
// BoogerSlime.
//=============================================================================
class BoogerSlime expands booger;

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
      TimeBetweenAttacks=0.800000
      bHasRangedAttack=True
      RangedProjectile=Class'Botpack.BioGlob'
      Texture=Texture'Botpack.Jgreen'
      DrawScale=0.500000
      CollisionRadius=20.000000
      CollisionHeight=4.500000
}
