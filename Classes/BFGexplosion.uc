//=============================================================================
// BFGexplosion.
//=============================================================================
class BFGexplosion expands Effects;

simulated function timer()
{
	if(Texture==Texture'bfgexplrays')	Texture=Texture'bfgexpl3'; else
	if(Texture==Texture'bfgexpl3')	Texture=Texture'bfgexpl2'; else
	if(Texture==Texture'bfgexpl2')	Texture=Texture'bfgexpl1'; else
	if(Texture==Texture'bfgexpl1')	Texture=Texture'bfgexpl0'; else
	{
		spawn(class'WeaponLight');
		Destroy();
	}		
	SetTimer(0.05,false);
}

simulated function BeginPlay()
{
	Super.BeginPlay();
	Texture=Texture'bfgexplrays';
	SetTimer(0.05,false);
	LightRadius = default.LightRadius*u4egauntlet(Level.Game).SafeLightScale;
}

defaultproperties
{
      RemoteRole=ROLE_SimulatedProxy
      DrawType=DT_Sprite
      Style=STY_Translucent
      Texture=Texture'Gauntlet-10-BetaV4.BFG.bfgexplrays'
      AmbientGlow=255
      bUnlit=True
      LightType=LT_Steady
      LightBrightness=160
      LightHue=80
      LightRadius=64
}
