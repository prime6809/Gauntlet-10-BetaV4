//=============================================================================
// Rail2Proj.
//=============================================================================
class Rail2Proj expands Projectile;

auto state Flying
{
	function ProcessTouch (Actor Other, vector HitLocation)
	{
		If (Other!=Instigator  && Rail2Proj(Other)==None)
		{
		if ( Other.IsA('Pawn') && (HitLocation.Z - Other.Location.Z > 0.69 * Other.CollisionHeight) 
			&& (instigator.IsA('PlayerPawn') || (instigator.skill > 1)) )
			Other.TakeDamage(1.5*Damage,Instigator, HitLocation,
				MomentumTransfer*Normal(Velocity/*HitLocation-Other.Location*/), 'decapitated');
		else
			Other.TakeDamage(Damage,Instigator, HitLocation,
				MomentumTransfer*Normal(Velocity/*HitLocation-Other.Location*/),'jolted');
		}
	}
	simulated function BeginState()
	{
		PlaySound(SpawnSound, SLOT_Misc, 0.6,,,1.0);
		Velocity = vector(Rotation) * speed;
	}
}

defaultproperties
{
      speed=50000.000000
      MaxSpeed=50000.000000
      Damage=70.000000
      MomentumTransfer=20000
      SpawnSound=Sound'Gauntlet-10-BetaV4.RailGun.RailFire'
      bAlwaysRelevant=True
      RemoteRole=ROLE_SimulatedProxy
      LifeSpan=1.000000
      Texture=Texture'Gauntlet-10-BetaV4.Skins.chr_blus'
      Mesh=LodMesh'Gauntlet-10-BetaV4.lasers'
      AmbientGlow=255
      bUnlit=True
      bMeshEnviroMap=True
      SoundRadius=255
      SoundVolume=64
      SoundPitch=128
      CollisionRadius=5.000000
      CollisionHeight=5.000000
      bCollideWorld=False
      LightType=LT_Steady
      LightEffect=LE_NonIncidence
      LightBrightness=240
      LightHue=200
      LightSaturation=96
      LightRadius=16
}
