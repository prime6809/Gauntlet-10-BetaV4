//=============================================================================
// Splash2.
//=============================================================================
class Splash2 extends Effects;


simulated function PostBeginPlay()
{
	local rotator NewRot;

	Super.PostBeginPlay();

		NewRot.Yaw = FRand()*65536;
		NewRot.Pitch = 0;
		NewRot.Roll = 0;
		SetRotation(NewRot);
} 

auto simulated state play
{
	Begin:
  if ( Level.NetMode != NM_DedicatedServer )
		PlayAnim  ( 'Burst', 2.0 );
} 
 
simulated function AnimEnd()
{
	Destroy();
}

defaultproperties
{
      bNetOptional=True
      RemoteRole=ROLE_SimulatedProxy
      LifeSpan=3.000000
      DrawType=DT_Mesh
      Mesh=LodMesh'UnrealShare.WaterImpactM'
}
