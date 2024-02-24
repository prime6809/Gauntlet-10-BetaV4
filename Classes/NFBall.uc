//=============================================================================
// NFBall.
//=============================================================================
class NFBall expands Effects;

simulated function PostBeginPlay()
{
	spawn(Class'NFBall1');
	Super.PostBeginPlay();
	RandSpin(50000);
}

simulated function tick(float dtime)
{
	fatness+=(dtime*240);
	ScaleGlow-=(dtime*3);	
	drawscale+=(dtime*2.25);
}

simulated final function RandSpin(float spinRate)
{
	DesiredRotation.Yaw = 0;
	DesiredRotation.Pitch = 0;
	DesiredRotation.Roll = 0;
	RotationRate.Yaw = 30000;//spinRate * 2 *FRand() - spinRate;
	RotationRate.Pitch = 0;//spinRate * 2 *FRand() - spinRate;
	RotationRate.Roll = 15000;//spinRate * 2 *FRand() - spinRate;	
}

defaultproperties
{
      Physics=PHYS_Rotating
      RemoteRole=ROLE_SimulatedProxy
      LifeSpan=0.749000
      DrawType=DT_Mesh
      Style=STY_Translucent
      Texture=Texture'Gauntlet-10-BetaV4.Fire.Nfire_bright'
      Mesh=LodMesh'Gauntlet-10-BetaV4.Sphere'
      DrawScale=0.150000
      ScaleGlow=2.000000
      Fatness=96
      bUnlit=True
      bFixedRotationDir=True
      DesiredRotation=(Pitch=12000,Yaw=5666,Roll=2334)
}
