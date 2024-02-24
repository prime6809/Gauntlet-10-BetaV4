//=============================================================================
// EggProj. - Asgard - for RTNP2U
//   http://ammo.at/napali  http://www.angelfire.com/empire/napali/
//=============================================================================
class EggProj extends Projectile;

var() int FragChunks;
var() Float Fragsize;
var bool  bnorepeat;
var Spikeexplosion se;
var() sound hatchsound;
var spinner spider;

simulated function PostBeginPlay()
{
	Super.PostbeginPlay();
 if ( Level.NetMode != NM_DedicatedServer )
				{ 
			DesiredRotation = RotRand();
		 RotationRate.Yaw = 200000*FRand() - 100000;
		 RotationRate.Pitch = 200000*FRand() - 100000;
		 RotationRate.Roll = 200000*FRand() - 100000;
   bFixedRotationDir=True;

		PlaySound( SpawnSound );
	}
}

function Destroyed()
{
 local Rotator newRot;
 
 newRot = Rotation;    
 newRot.Pitch = 0; 
 newRot.Roll = 0;    
 spider=spawn(class'spinner',,,,newRot);
	super.Destroyed();
}

auto state Flying
{
		
	simulated function ProcessTouch( Actor Other, Vector HitLocation )
	{
  local vector momentum;

		if ( Spinner( Other ) == None )
		{
    momentum = 70000.0 * Normal(Velocity);
    if ( Role == ROLE_Authority )
				Other.TakeDamage(Damage, instigator, Location, momentum, 'crushed');
				Explode( Location, Normal(Velocity) );
		}
	}  
	
	simulated function Bump( Actor Other)
	{
  local vector momentum;

		if ( Spinner( Other ) == None )
		{
    momentum = 70000.0 * Normal(Velocity);
    if ( Role == ROLE_Authority )
				Other.TakeDamage(Damage, instigator, Location, momentum, 'crushed');
				Explode( Location, Normal(Velocity) );
		}
	}     
	
 simulated function Landed(vector HitNormal)
	{
  HitWall(  HitNormal, none );
	}	
    
 simulated function HitWall( vector HitNormal, actor Wall )
	{
 	SetPhysics(PHYS_None);
		Explode( Location, HitNormal );
	}

	simulated function Explode( vector HitLocation, vector HitNormal )
	{
  local GreenBloodPuff GBP;

  MakeNoise(1.0);
  PlaySound(hatchsound);
  if ( Level.NetMode != NM_DedicatedServer )
  {
   GBP=spawn(class'GreenBloodPuff',,,HitLocation);
   if(GBP!=none)
    GBP.drawscale=2.0;
   spawn(class'splash2',,,HitLocation);
   spawn(class'GreenGelPuff',,,HitLocation);
		} 
   skinnedFrag(class'Fragment1', texture'Jseed1', location, Fragsize, FragChunks);
	}

	function BeginState()         
	{
		if ( Role == ROLE_Authority )
		{
			Velocity = Vector(Rotation) * Speed;
			Velocity.z += 120;
			if( Region.zone.bWaterZone )
				Velocity=Velocity*0.7;
		}
 }	

Begin:
	Sleep( LifeSpan - 0.3 ); 
	Explode( Location, vect(0,0,0) );
}

simulated function skinnedFrag(class<fragment> FragType, texture FragSkin, vector Momentum, float DSize, int NumFrags) 
{
	local int i;
//	local actor A, Toucher;
	local Fragment s;

	if ( Region.Zone.bDestructive )
	{
		Destroy();
		return;
	}
	for (i=0 ; i<NumFrags ; i++) 
	{
		s = Spawn( FragType, Owner);
		s.CalcVelocity(Momentum/100,0);
		s.Skin = FragSkin;
		s.DrawScale = DSize*0.5+0.7*DSize*FRand();
	}  
	Destroy();
}

defaultproperties
{
      FragChunks=12
      Fragsize=1.000000
      bnorepeat=False
      se=None
      hatchsound=Sound'UnrealShare.Generic.LavaEn'
      spider=None
      speed=1000.000000
      MaxSpeed=1200.000000
      Damage=40.000000
      SpawnSound=Sound'Gauntlet-10-BetaV4.spinner.spFire'
      ImpactSound=Sound'Gauntlet-10-BetaV4.spinner.spHit'
      Physics=PHYS_Falling
      RemoteRole=ROLE_SimulatedProxy
      LifeSpan=9.000000
      Skin=Texture'UnrealI.Skins.Jseed1'
      Mesh=LodMesh'UnrealShare.BioRGel'
      DrawScale=4.000000
      AmbientGlow=255
      Fatness=244
      bMeshCurvy=True
      MultiSkins(1)=Texture'UnrealI.Skins.Jseed1'
      CollisionRadius=33.000000
      CollisionHeight=23.000000
      bBlockActors=True
      bBlockPlayers=True
}
