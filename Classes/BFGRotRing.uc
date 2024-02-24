//=============================================================================
// BFGRotRing.
//=============================================================================
class BFGRotRing expands Effects;

var float LifeTime;

simulated function BeginPlay()
{
	Super.BeginPlay();
	LifeTime=0;
	PlayAnim('All',5);
}	

simulated function tick(float DeltaTime)
{
	local vector X,Y,Z;
	if(Owner == None) {Destroy(); return;}
	SetLocation(Owner.Location);
	DrawScale=Default.DrawScale*(Owner.DrawScale/Owner.Default.DrawScale);
	LifeTime+=(DeltaTime*10);
	if(LifeTime>=(2*PI))LifeTime=0;
	GetAxes(Owner.Rotation,X,Y,Z);
	Z.X=0.5*sin(LifeTime);
	Z.Y=0.5*cos(LifeTime);
	SetRotation(Rotator(Normal(Z)));
}

defaultproperties
{
      Lifetime=0.000000
      RemoteRole=ROLE_SimulatedProxy
      DrawType=DT_Mesh
      Style=STY_None
      Texture=FireTexture'Gauntlet-10-BetaV4.BFG.BFGRingTex'
      Skin=FireTexture'Gauntlet-10-BetaV4.BFG.BFGRingTex'
      Mesh=LodMesh'UnrealShare.Ringex'
      DrawScale=0.250000
}
