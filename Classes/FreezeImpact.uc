//=============================================================================
// FreezeImpact.
//=============================================================================
class FreezeImpact expands Effects;

simulated function PostBeginPlay()
{
	local actor a;
	if ( Level.NetMode != NM_DedicatedServer )
	{
		PlayAnim( 'All', 1.0 );
		PlaySound(Sound'Explg02',,6.0);
		 a = Spawn(class'EffectLight');
		 a.RemoteRole = ROLE_None;
		 a = Spawn(class'ParticleBurst2');
		 a.RemoteRole = ROLE_None;	 
	}	
	if ( Instigator != None )
		MakeNoise(0.5);
}

defaultproperties
{
      RemoteRole=ROLE_SimulatedProxy
      LifeSpan=0.400000
      DrawType=DT_Mesh
      Mesh=LodMesh'UnrealShare.WaterImpactM'
}
