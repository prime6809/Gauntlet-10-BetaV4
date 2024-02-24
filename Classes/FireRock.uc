//=============================================================================
// FireRock.
//=============================================================================
class FireRock extends GasBagBelch;

var ChildBBall cbb,cbb1;

simulated function PostBeginPlay()
{
	SetUp();
	Super.PostBeginPlay();
	if ( Level.NetMode != NM_DedicatedServer )
	{
		i=6*frand();
		Texture = SpriteAnim[i];
		SetTimer(0.01,True);
	}
}
simulated function Timer()
{
	if(Texture.AnimNext!=None)Texture=Texture.AnimNext;
	else
	{
		i=6*frand();
		Texture = SpriteAnim[i];
	}

}
auto state Flying
{

simulated function Landed( vector HitNormal )
{
		Explode(Location, Vect(0,0,0));
}
simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
	if ((Other != instigator) && (Other != Owner))
	{
		if ( Role == ROLE_Authority )
			Other.TakeDamage(Damage, instigator,HitLocation,
					15000.0 * Normal(velocity), MyDamageType);
		Explode(HitLocation, Vect(0,0,0));
	}
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local UT_SpriteBallExplosion s;

	if ( Role == ROLE_Authority )
		HurtRadius(Damage, 200, MyDamageType, MomentumTransfer*2, HitLocation );

	spawn(class'NFBall',,,HitLocation);

	if ( (Role == ROLE_Authority) && (FRand() < 0.5) )
		MakeNoise(1.0); //FIXME - set appropriate loudness

	s = Spawn(class'UT_SpriteBallExplosion',,,HitLocation+HitNormal*9);
	s.RemoteRole = ROLE_None;
	cbb.Destroy();
	cbb1.Destroy();
	Destroy();
}

simulated function BeginState()
{
	local vector x,y,z;
	GetAxes(Rotation,x,y,z);
	z=7*normal(z);	
	cbb=spawn(class'ChildBBall',self,,Location-z);
	cbb.drawscale=0.25;
	cbb1=spawn(class'ChildBBall',self,,Location-z);
	cbb1.drawscale=0.15;
	cbb1.bMeshEnviroMap=false;
}
Begin:
	Sleep(8);
	Explode(Location, Vect(0,0,0));
}

defaultproperties
{
      cbb=None
      cbb1=None
      SpriteAnim(0)=Texture'UnrealShare.MainEffect.e1_a02'
      SpriteAnim(1)=Texture'UnrealShare.MainEffect.e2_a02'
      SpriteAnim(2)=Texture'UnrealShare.MainEffect.e3_a02'
      SpriteAnim(3)=Texture'UnrealShare.MainEffect.e4_a02'
      SpriteAnim(4)=Texture'UnrealShare.MainEffect.e5_a02'
      SpriteAnim(5)=Texture'UnrealShare.MainEffect.e3_a02'
      speed=800.000000
      Damage=35.000000
      MyDamageType="Burned"
      DrawType=DT_SpriteAnimOnce
      DrawScale=1.250000
      CollisionRadius=24.000000
      CollisionHeight=24.000000
      LightType=LT_None
}
