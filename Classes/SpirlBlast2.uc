//=============================================================================
// SpirlBlast2.
//=============================================================================
class SpirlBlast2 extends projectile;

//=============================================================================
// pbolt.
//=============================================================================

var() texture SpriteAnim[5];
var int SpriteFrame;
var SpirlBlast2 PlasmaBeam;
//var SpirlCap WallEffect;
var int Position;
var float BeamSize;

replication
{
	// Things the server should send to the client.
}
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	PlayAnim('All',1.0);
}
simulated function Destroyed()
{
	Super.Destroyed();
	if ( PlasmaBeam != None )
		PlasmaBeam.Destroy();
//	if ( WallEffect != None )
	//	WallEffect.Destroy();
}

simulated function CheckBeam(vector X, float DeltaTime)
{
	if ( Position >= 9 )
	{	
	//	WallEffect = Spawn(class'SpirlCap',,, Location + (BeamSize - 4) * X);
	}
	else
	{
		if ( PlasmaBeam == None )
		{
			PlasmaBeam = Spawn(class'SpirlBlast2',,, Location + BeamSize * X); 
			PlasmaBeam.Position = Position + 1;
		}
		else
			PlasmaBeam.UpdateBeam(self, X, DeltaTime);
	}
}

simulated function UpdateBeam(SpirlBlast2 ParentBolt, vector Dir, float DeltaTime)
{
//	local actor HitActor;
//	local vector HitLocation, HitNormal;

	SpriteFrame = ParentBolt.SpriteFrame;
	Skin = SpriteAnim[SpriteFrame];

	ScaleGlow = ParentBolt.ScaleGlow;

	drawscale = ParentBolt.drawscale;
	beamsize = ParentBolt.beamsize;

	SetLocation(ParentBolt.Location + BeamSize * Dir);
	SetRotation(ParentBolt.Rotation);
	CheckBeam(Dir, DeltaTime);
}

defaultproperties
{
      SpriteAnim(0)=Texture'Gauntlet-10-BetaV4.Skins.JSpirl0'
      SpriteAnim(1)=Texture'Gauntlet-10-BetaV4.Skins.JSpirl1'
      SpriteAnim(2)=Texture'Gauntlet-10-BetaV4.Skins.JSpirl2'
      SpriteAnim(3)=Texture'Gauntlet-10-BetaV4.Skins.JSpirl3'
      SpriteAnim(4)=Texture'Gauntlet-10-BetaV4.Skins.JSpirl4'
      SpriteFrame=0
      PlasmaBeam=None
      Position=0
      BeamSize=240.000000
      MaxSpeed=0.000000
      bNetTemporary=False
      Physics=PHYS_None
      RemoteRole=ROLE_None
      LifeSpan=0.990000
      Style=STY_Translucent
      Texture=Texture'Gauntlet-10-BetaV4.Skins.chr_blus'
      Skin=Texture'Gauntlet-10-BetaV4.Skins.JSpirl0'
      Mesh=Mesh'Gauntlet-10-BetaV4.SpirlBlast2'
      DrawScale=1.500000
      bUnlit=True
      bMeshCurvy=True
      bCollideActors=False
      bCollideWorld=False
      LightBrightness=255
      LightHue=200
      LightRadius=5
}
