//=============================================================================
// FreezedBlob.
//=============================================================================
class FreezedBlob expands FreezedPawn;

var bool freezedOwner;
var vector OwnerOffset;

simulated function BeginPlay()
{
	Super.BeginPlay();
	freezedOwner=(FreezedPawn(Owner)!=None);
	if (freezedOwner)
		OwnerOffset=(Location-Owner.Location);
}

function Landed(vector HitNormal)
{
	takedamage(10,Instigator,Location,vsize(velocity)*vect(0,0,1),'corroded');
}

simulated function tick(float DeltaTime)
{
	lifetime+=DeltaTime;
	if(lifetime>=7.5) 
		takedamage(10,Instigator,Location,v001,'corroded');
	
	if (lifetime>(itime+30*frand()))
	{
		itime=lifetime;
		
		if(skin==tex1) 
			skin=tex2;
		else 
			skin=tex1;
	}	

	if(freezedOwner)
	{
		if((Owner != None) && (FreezedPawn(Owner)==None)) 
			Destroy();
			
		SetLocation(Owner.Location+OwnerOffset);
	}	
}

simulated function fragme(vector momentum)
{
	PlaySound (Sound'BreakGlass');
	skinnedFrag(class'Fragment1',texture'freeze2_A00', momentum,0.7,drawscale*15);
}
auto state active
{
	function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, name damageType)
	{
		fragme(momentum);
		if((freezedOwner)&&(Owner!=None))Owner.Destroy();
		Instigator = InstigatedBy;
		if ( Instigator != None )
			MakeNoise(1.0);
	}

Begin:
}

defaultproperties
{
      freezedOwner=False
      OwnerOffset=(X=0.000000,Y=0.000000,Z=0.000000)
      AnimSequence="Splat"
      Style=STY_Translucent
      Mesh=LodMesh'UnrealI.MiniBlob'
      CollisionRadius=3.000000
      CollisionHeight=4.000000
}
