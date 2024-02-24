//=============================================================================
// NFireBall.
//=============================================================================
class NFireBall expands Actor;

var() Texture SpriteAnim[8];
var int i;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	i=0;
	Texture = SpriteAnim[i];
	Skin = SpriteAnim[i];
	SetTimer(0.075,True);
}
simulated function Timer()
{
	if(i==7)i=0; else i++;
	Texture = SpriteAnim[i];
	Skin = SpriteAnim[i];
}
simulated function tick(float dtime)
{
	drawscale+=(dtime*5);
	fatness+=(dtime*160/1.25);
	ScaleGlow-=(dtime*2/1.25);	
}

defaultproperties
{
      SpriteAnim(0)=Texture'Botpack.UT_Explosions.exp1_a00'
      SpriteAnim(1)=Texture'Botpack.UT_Explosions.exp1_a01'
      SpriteAnim(2)=Texture'Botpack.UT_Explosions.exp1_a02'
      SpriteAnim(3)=Texture'Botpack.UT_Explosions.exp1_a03'
      SpriteAnim(4)=Texture'Botpack.UT_Explosions.exp1_a04'
      SpriteAnim(5)=Texture'Botpack.UT_Explosions.exp1_a05'
      SpriteAnim(6)=Texture'Botpack.UT_Explosions.exp1_a06'
      SpriteAnim(7)=Texture'Botpack.UT_Explosions.exp1_a07'
      i=0
      LifeSpan=1.249000
      DrawType=DT_Mesh
      Style=STY_Translucent
      Texture=None
      Mesh=LodMesh'Gauntlet-10-BetaV4.Sphere'
      DrawScale=0.250000
      ScaleGlow=2.000000
      Fatness=96
      bUnlit=True
      LightEffect=LE_NonIncidence
      LightBrightness=255
      LightHue=12
      LightSaturation=32
      LightRadius=8
}
