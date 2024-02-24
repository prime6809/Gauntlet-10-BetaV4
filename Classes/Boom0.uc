//=============================================================================
// Boom0.
//=============================================================================
class Boom0 expands Actor;

function PostBeginPlay()
{
	PlayAnim('All',0.25);
}	

defaultproperties
{
      bAlwaysRelevant=True
      bNetOptional=True
      RemoteRole=ROLE_SimulatedProxy
      LifeSpan=1.950000
      DrawType=DT_Mesh
      Style=STY_Translucent
      Sprite=FireTexture'UnrealShare.Effect56.fireeffect56'
      Texture=WetTexture'Gauntlet-10-BetaV4.FireBoogerSkin'
      Skin=WetTexture'Gauntlet-10-BetaV4.FireBoogerSkin'
      Mesh=LodMesh'Gauntlet-10-BetaV4.Boom0'
      DrawScale=8.000000
      ScaleGlow=2.000000
      AmbientGlow=255
      bUnlit=True
      CollisionRadius=0.000000
      CollisionHeight=0.000000
}
