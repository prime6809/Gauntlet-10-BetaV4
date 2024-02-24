//=============================================================================
// skeleton.
//=============================================================================
class skeleton extends Actor;

auto state fallingdown
{
Begin:
	PlayAnim('All',0.2);
}

defaultproperties
{
      Physics=PHYS_Falling
      RemoteRole=ROLE_SimulatedProxy
      LifeSpan=15.000000
      DrawType=DT_Mesh
      Mesh=LodMesh'Gauntlet-10-BetaV4.skeleton'
      CollisionRadius=17.000000
      CollisionHeight=39.000000
      bCollideWorld=True
}
