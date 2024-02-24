//=============================================================================
// U4ePlasmaExpl.
//=============================================================================
class U4ePlasmaExpl extends UT_RingExplosion;

simulated function Tick( float DeltaTime )
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		if ( !bExtraEffectsSpawned )
			SpawnExtraEffects();
		ScaleGlow = (Lifespan/Default.Lifespan)*0.7;
		AmbientGlow = ScaleGlow * 255;		
	}
}

simulated function PostBeginPlay()
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		PlayAnim( 'Explo', 0.5, 0.0 );
		SpawnEffects();
	}	
	if ( Instigator != None )
		MakeNoise(0.5);
}

simulated function SpawnEffects()
{
	 Spawn(class'shockexplo');
}

simulated function SpawnExtraEffects()
{
	 Spawn(class'EnergyImpact');
	 bExtraEffectsSpawned = true;
}

defaultproperties
{
      bExtraEffectsSpawned=False
      Style=STY_Translucent
      Mesh=Mesh'Gauntlet-10-BetaV4.sheetX1'
      DrawScale=1.000000
      bFixedRotationDir=True
      RotationRate=(Roll=65000)
}
