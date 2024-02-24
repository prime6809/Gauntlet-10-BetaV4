//=============================================================================
// SpinnerChunks. RTNP2U - Asgard
//   http://ammo.at/napali  http://www.angelfire.com/empire/napali/
//=============================================================================


class SpinnerChunks extends CreatureChunks;


simulated function PostBeginPlay()
{
	Super(decoration).PostBeginPlay();
}

simulated function BeginPlay()
{
	if ( Region.Zone.bDestructive || ((Level.Game != None) && Level.Game.bLowGore) )
	{
		Destroy();
		return;
	}
 if ( Level.NetMode == NM_Client )
		SetTimer(0.05, false);
	Super.BeginPlay();
}

function Initfor(actor Other)
{
	local vector RandDir;
	local int i;

	if ( Other.IsA('Carcass') )
		PlayerOwner = Carcass(Other).PlayerOwner;
	bDecorative = false;
	DrawScale = Other.DrawScale;
	if ( DrawScale != 1.0 )
		SetCollisionSize(CollisionRadius * 0.5 * (1 + DrawScale), CollisionHeight * 0.5 * (1 + DrawScale));
	RotationRate.Yaw = Rand(200000) - 100000;
	RotationRate.Pitch = Rand(200000 - Abs(RotationRate.Yaw)) - 0.5 * (200000 - Abs(RotationRate.Yaw));
	RandDir = 700 * FRand() * VRand();
	RandDir.Z = 200 * FRand() - 50;
 bmeshenviromap=Other.bmeshenviromap;
 skin = Other.skin;
	texture=Other.texture;
	for ( i=0; i<4; i++ )
  Multiskins[i] = Other.MultiSkins[i];
	if ( bMasterChunk )
		SetAsMaster(Other);
	else
	{
		Velocity = (0.2 + FRand()) * (other.Velocity + RandDir);
		If (Region.Zone.bWaterZone)
			Velocity *= 0.5;
	}
	if ( TrailSize > 0 )
	{
		if ( CreatureCarcass(Other) != None )
			bGreenBlood = CreatureCarcass(Other).bGreenBlood;
		else if ( (CreatureChunks(Other) != None) )
			bGreenBlood = CreatureChunks(Other).bGreenBlood;
	}
			
	if ( FRand() < 0.3 )
		Buoyancy = 1.06 * Mass; // float corpse
	else
		Buoyancy = 0.94 * Mass;

	if ( bMasterChunk && (Level.NetMode != NM_Client) ) // only if server
		ClientExtraChunks(bMustSpawnChunks);
}      

simulated function ClientExtraChunks(bool bSpawnChunks)
{
	local SpinnerChunks carc;
	local bloodpuff Blood;
	local bloodspurt b;
	local int n;

	If ( Level.NetMode == NM_DedicatedServer )
		return;

	bMustSpawnChunks = false;
	b = Spawn(class 'Bloodspurt',,,,rot(16384,0,0));
	if ( bGreenBlood )
		b.GreenBlood();
	b.RemoteRole = ROLE_None;

	if ( !bSpawnChunks || (CarcassClass == None) )
		return;

	n = 1;

	while ( (n<8) && (CarcassClass.Default.bodyparts[n] != none) )
	{
		if ( CarcassClass.Static.AllowChunk(n, CarcassAnim) )
		{
			if ( CarcLocation == vect(0,0,0) ) CarcLocation = Location; 
			carc = Spawn(class 'SpinnerChunks',,, CarcLocation 
						+ CarcassClass.Default.ZOffset[n] * CarcHeight * vect(0,0,1));
			if (carc != None)
			{
    carc.bMasterChunk=false;
				carc.TrailSize = CarcassClass.Default.Trails[n];
				carc.Mesh = CarcassClass.Default.bodyparts[n];
				carc.Initfor(self);
				carc.RemoteRole = ROLE_None;
			}
		}
		n++;
	}

	if ( Level.bHighDetailMode && !bGreenBlood )
	{
		Blood = spawn(class'BloodPuff',,, CarcLocation);
		Blood.drawscale = 0.2 * CollisionRadius;
		Blood.RemoteRole = ROLE_None;
	}
}   

singular function ChunkUp(int Damage)
{
	local BloodSpurt b;

	if (bHidden)
		return;
	b = Spawn(class 'Bloodspurt',,,,rot(16384,0,0));
	if ( bGreenBlood )		
		b.GreenBlood();	
	if (bPlayerCarcass)
	{
		bHidden = true;
		SetPhysics(PHYS_None);
		SetCollision(false,false,false);
		bProjTarget = false;
		if ( Trail != None )
			Trail.Destroy();
	}
	else
		destroy();
}

singular function BaseChange()
{
	local float decorMass, decorMass2;

 if(bDeleteMe)
   return;

	decormass= FMax(1, Mass);
	bBobbing = false;
	if( Velocity.Z < -500 && (Role == Role_Authority) )
		TakeDamage( (1-Velocity.Z/30),Instigator,Location,vect(0,0,0) , 'crushed');

	if( (base == None)  && (Physics == PHYS_None) )
		SetPhysics(PHYS_Falling);
	else if( (Pawn(base) != None) && (Pawn(Base).CarriedDecoration != self) )
	{
  if(Role == Role_Authority && !Base.bDeleteme)
		Base.TakeDamage( (1-Velocity.Z/400)* decormass/Base.Mass,Instigator,Location,0.5 * Velocity , 'crushed');
		Velocity.Z = 100;
		if (FRand() < 0.5)
			Velocity.X += 70;
		else
			Velocity.Y += 70;
		SetPhysics(PHYS_Falling);
	}
	else if( Decoration(Base)!=None && Velocity.Z<-500 )
	{
		decorMass2 = FMax(Decoration(Base).Mass, 1);
  if(Role == Role_Authority && !Base.bDeleteme)
		Base.TakeDamage((1 - decorMass/decorMass2 * Velocity.Z/30), Instigator, Location, 0.2 * Velocity, 'stomped');
		Velocity.Z = 100;
		if (FRand() < 0.5)
			Velocity.X += 70;
		else
			Velocity.Y += 70;
		SetPhysics(PHYS_Falling);
	}
	else
		instigator = None;
}
  
function SetAsMaster(Actor Other)
{
	if(Other==none)
   return;
	Velocity = Other.Velocity;
	CarcassClass = class<CreatureCarcass>(Other.Class);
	CarcassAnim = Other.AnimSequence;
	CarcLocation = Other.Location;
	CarcHeight = Other.CollisionHeight;
}	

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, name damageType)
{
 if(bDeleteMe)
   return;
	SetPhysics(PHYS_Falling);
	bBobbing = false;
	Velocity += momentum/Mass;
	CumulativeDamage += Damage;
	If ( Damage > FMin(15, Mass) || (CumulativeDamage > Mass) )
		ChunkUp(Damage);
}

simulated singular function Landed(vector HitNormal)
{
	local rotator finalRot;
	local BloodSpurt b;

	if ( trail != None )
	{
		if ( Level.bHighDetailMode )
			bUnlit = false;
		trail.Destroy();
		trail = None;
	}
	finalRot = Rotation;
	finalRot.Roll = 0;
	finalRot.Pitch = 0;
	setRotation(finalRot);
	if ( Level.NetMode != NM_DedicatedServer )
	{
		b = Spawn(class 'Bloodspurt',,,,rot(16384,0,0));
		if ( bGreenBlood )
			b.GreenBlood();		
		b.RemoteRole = ROLE_None;
	}
	SetPhysics(PHYS_None);
	SetCollision(true, false, false);
}

defaultproperties
{
      bGreenBlood=True
}
