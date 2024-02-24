//=============================================================================
// FreezedPawn.
//=============================================================================
class FreezedPawn expands Decoration;

var float itime,lifetime;
var() texture tex1,tex2;
var() sound FreezeSound;
var vector v001;

simulated function BeginPlay()
{
	Super.BeginPlay();
	lifetime=0;
	itime=0;
	skin=tex1;
	PlaySound (FreezeSound);	
	MakeNoise(1.0);		
	v001.X=0;
	v001.Y=0;
	v001.Z=1;
}

simulated function tick(float DeltaTime){
	lifetime+=DeltaTime;
	if(lifetime>=7.5) takedamage(10,Instigator,Location,v001,'Corroded');
	if (lifetime>(itime+30*frand())){
		itime=lifetime;
		if(skin==tex1) skin=tex2;
		else skin=tex1;
	}	
}

simulated function skinnedFrag(class<fragment> FragType, texture FragSkin, vector Momentum, float DSize, int NumFrags) 
{
	local int i;
	local Fragment s;

	for (i=0 ; i<NumFrags ; i++) 
	{
		s = Spawn( FragType, Owner);
		s.CalcVelocity(Momentum/100,0);
		s.Skin = FragSkin;
		s.DrawScale = DSize*0.5+0.7*DSize*FRand();
	}
	Destroy();
}

auto state active
{
	function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, name damageType)
	{
		PlaySound (Sound'BreakGlass');
		skinnedFrag(class'Fragment1',texture'freeze2_A00', Momentum,0.7,17);
		Instigator = InstigatedBy;
		if ( Instigator != None )
			MakeNoise(1.0);
	}

Begin:
}

defaultproperties
{
      itime=0.000000
      Lifetime=0.000000
      tex1=Texture'Gauntlet-10-BetaV4.Skins.freeze2_A00'
      tex2=Texture'Gauntlet-10-BetaV4.Skins.freeze2_A01'
      FreezeSound=None
      v001=(X=0.000000,Y=0.000000,Z=0.000000)
      bPushable=True
      bStatic=False
      Physics=PHYS_Falling
      RemoteRole=ROLE_SimulatedProxy
      LifeSpan=8.000000
      DrawType=DT_Mesh
      Skin=Texture'Gauntlet-10-BetaV4.Skins.freeze2_A00'
      CollisionRadius=35.000000
      CollisionHeight=46.000000
      bCollideActors=True
      bCollideWorld=True
      bBlockActors=True
      bBlockPlayers=True
}
