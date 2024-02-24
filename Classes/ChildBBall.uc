//=============================================================================
// ChildBBall.
//=============================================================================
class ChildBBall extends Effects;

var vector ofs;
var float oldDS;

simulated function PostBeginPlay()
{
	SetTimer(0.1*frand(),false);
	oldDS=drawscale;
	ofs=Location-owner.Location;
}

simulated function tick(float deltatime)
{
	if(Owner==None) Destroy();
	else SetLocation(Owner.Location+ofs);
}	

simulated function Timer()
{
	local vector v;
	local float xDS;
	v.x=1-2*frand();v.y=1-2*frand();v.z=1-2*frand();
	SetRotation(rotator(v));
	xDS=(1.4-0.8*frand());
//	DrawScale=oldDS*xDS;
	SetTimer(0.1*frand(),false);
}

defaultproperties
{
      Ofs=(X=0.000000,Y=0.000000,Z=0.000000)
      oldDS=0.000000
      RemoteRole=ROLE_SimulatedProxy
      DrawType=DT_Mesh
      Style=STY_Translucent
      Texture=FireTexture'UnrealShare.Effect55.fireeffect55'
      Skin=Texture'Gauntlet-10-BetaV4.BFG.afireball_A00'
      Mesh=LodMesh'Gauntlet-10-BetaV4.Sphere'
      DrawScale=0.500000
      bMeshEnviroMap=True
      LightType=LT_Steady
      LightEffect=LE_NonIncidence
      LightBrightness=255
      LightHue=12
      LightSaturation=32
      LightRadius=8
}
