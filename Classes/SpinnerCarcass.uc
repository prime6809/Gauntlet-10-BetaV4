//=============================================================================
// SpinnerCarcass. Exported from RTNP for RTNP2U - Asgard
//   http://ammo.at/napali  http://www.angelfire.com/empire/napali/
//=============================================================================
class SpinnerCarcass extends CreatureCarcass;

//#exec mesh IMPORT MESH=SpinnerHead ANIVFILE=MODELS\SpinnerHead_a.3D DATAFILE=MODELS\SpinnerHead_d.3D X=0 Y=0 Z=0
#forceexec mesh ORIGIN MESH=SpinnerHead X=0 Y=0 Z=-20 YAW=-64
//#exec MESH SEQUENCE MESH=SpinnerHead SEQ=All    STARTFRAME=0   NUMFRAMES=2
//#exec mesh SEQUENCE MESH=SpinnerHead SEQ=Still  STARTFRAME=0   NUMFRAMES=2
//#exec texture IMPORT NAME=JGSpinner1  FILE=MODELS\JGSpinner1.PCX FAMILY=Skins FLAGS=2
//#exec texture IMPORT NAME=JGSpinner2  FILE=MODELS\JGSpinner2.PCX GROUP=Skins PALETTE=JGSpinner1 // head4T6y
//#exec MESHMAP NEW   MESHMAP=SpinnerHead MESH=SpinnerHead
//#exec MESHMAP SCALE MESHMAP=SpinnerHead X=0.04 Y=0.04 Z=0.08
//#exec MESHMAP SETTEXTURE MESHMAP=SpinnerHead NUM=0 TEXTURE=JGSpinner1
//#exec MESHMAP SETTEXTURE MESHMAP=SpinnerHead NUM=1 TEXTURE=JGSpinner2

//#exec mesh IMPORT MESH=SpinnerBody ANIVFILE=MODELS\SpinnerBody_a.3D DATAFILE=MODELS\SpinnerBody_d.3D X=0 Y=0 Z=0
#forceexec MESH ORIGIN MESH=SpinnerBody X=0 Y=0 Z=0 YAW=-64
//#exec mesh SEQUENCE MESH=SpinnerBody SEQ=All    STARTFRAME=0   NUMFRAMES=2
//#exec mesh SEQUENCE MESH=SpinnerBody SEQ=Still  STARTFRAME=0   NUMFRAMES=2
//#exec MESHMAP NEW   MESHMAP=SpinnerBody MESH=SpinnerBody
//#exec MESHMAP SCALE MESHMAP=SpinnerBody X=0.04 Y=0.04 Z=0.08
//#exec MESHMAP SETTEXTURE MESHMAP=SpinnerBody NUM=0 TEXTURE=JGSpinner1

//#exec mesh IMPORT MESH=SpinnerClaw ANIVFILE=MODELS\SpinnerClaw_a.3d DATAFILE=MODELS\SpinnerClaw_d.3d X=0 Y=0 Z=0
#forceexec MESH ORIGIN MESH=SpinnerClaw X=0 Y=0 Z=0 YAW=-64
//#exec MESH SEQUENCE MESH=SpinnerClaw SEQ=All         STARTFRAME=0 NUMFRAMES=2
//#exec MESH SEQUENCE MESH=SpinnerClaw SEQ=SpinnerClaw STARTFRAME=0 NUMFRAMES=2
//#exec MESHMAP NEW   MESHMAP=SpinnerClaw MESH=SpinnerClaw
//#exec MESHMAP SCALE MESHMAP=SpinnerClaw X=0.04 Y=0.04 Z=0.08
//#exec MESHMAP SETTEXTURE MESHMAP=SpinnerClaw NUM=0 TEXTURE=JGSpinner1

//#exec MESH IMPORT MESH=SpinnerLeg1 ANIVFILE=MODELS\SpinnerLeg1_a.3D DATAFILE=MODELS\SpinnerLeg1_d.3D X=0 Y=0 Z=0
#forceexec MESH ORIGIN MESH=SpinnerLeg1 X=0 Y=0 Z=0 YAW=-64
//#exec mesh SEQUENCE MESH=SpinnerLeg1 SEQ=All    STARTFRAME=0   NUMFRAMES=2
//#exec MESH SEQUENCE MESH=SpinnerLeg1 SEQ=Still  STARTFRAME=0   NUMFRAMES=2
//#exec MESHMAP NEW   MESHMAP=SpinnerLeg1 MESH=SpinnerLeg1
//#exec MESHMAP SCALE MESHMAP=SpinnerLeg1 X=0.04 Y=0.04 Z=0.08
//#exec MESHMAP SETTEXTURE MESHMAP=SpinnerLeg1 NUM=0 TEXTURE=JGSpinner1

//#exec MESH IMPORT MESH=SpinnerLeg2 ANIVFILE=MODELS\SpinnerLeg2_a.3D DATAFILE=MODELS\SpinnerLeg2_d.3D X=0 Y=0 Z=0
#forceexec MESH ORIGIN MESH=SpinnerLeg2 X=0 Y=0 Z=0 YAW=-64
//#exec MESH SEQUENCE MESH=SpinnerLeg2 SEQ=All    STARTFRAME=0   NUMFRAMES=2
//#exec MESH SEQUENCE MESH=SpinnerLeg2 SEQ=Still  STARTFRAME=0   NUMFRAMES=2
//#exec MESHMAP NEW   MESHMAP=SpinnerLeg2 MESH=SpinnerLeg2
//#exec MESHMAP SCALE MESHMAP=SpinnerLeg2 X=0.04 Y=0.04 Z=0.08
//#exec MESHMAP SETTEXTURE MESHMAP=SpinnerLeg2 NUM=0 TEXTURE=JGSpinner1

//#exec mesh IMPORT MESH=SpinnerLeg3 ANIVFILE=MODELS\SpinnerLeg3_a.3D DATAFILE=MODELS\SpinnerLeg3_d.3D X=0 Y=0 Z=0
#forceexec MESH ORIGIN MESH=SpinnerLeg3 X=0 Y=0 Z=0 YAW=-64
//#exec MESH SEQUENCE MESH=SpinnerLeg3 SEQ=All    STARTFRAME=0   NUMFRAMES=2
//#exec MESH SEQUENCE MESH=SpinnerLeg3 SEQ=Still  STARTFRAME=0   NUMFRAMES=2
//#exec MESHMAP NEW   MESHMAP=SpinnerLeg3 MESH=SpinnerLeg3
//#exec MESHMAP SCALE MESHMAP=SpinnerLeg3 X=0.04 Y=0.04 Z=0.08
//#exec MESHMAP SETTEXTURE MESHMAP=SpinnerLeg3 NUM=0 TEXTURE=JGSpinner1

//#exec MESH IMPORT MESH=SpinnerLeg4 ANIVFILE=MODELS\SpinnerLeg4_a.3D DATAFILE=MODELS\SpinnerLeg4_d.3D X=0 Y=0 Z=0
#forceexec MESH ORIGIN MESH=SpinnerLeg4 X=0 Y=0 Z=0 YAW=-64
//#exec MESH SEQUENCE MESH=SpinnerLeg4 SEQ=All    STARTFRAME=0   NUMFRAMES=2
//#exec MESH SEQUENCE MESH=SpinnerLeg4 SEQ=Still  STARTFRAME=0   NUMFRAMES=2
//#exec MESHMAP NEW   MESHMAP=SpinnerLeg4 MESH=SpinnerLeg4
//#exec MESHMAP SCALE MESHMAP=SpinnerLeg4 X=0.04 Y=0.04 Z=0.08
//#exec MESHMAP SETTEXTURE MESHMAP=SpinnerLeg4 NUM=0 TEXTURE=JGSpinner1

//#exec mesh IMPORT MESH=SpinnerTail ANIVFILE=MODELS\SpinnerTail_a.3D DATAFILE=MODELS\SpinnerTail_d.3D X=0 Y=0 Z=0
#forceexec MESH ORIGIN MESH=SpinnerTail X=0 Y=0 Z=0 YAW=-64
//#exec MESH SEQUENCE MESH=SpinnerTail SEQ=All    STARTFRAME=0   NUMFRAMES=2
//#exec mesh SEQUENCE MESH=SpinnerTail SEQ=Still  STARTFRAME=0   NUMFRAMES=2
//#exec MESHMAP NEW   MESHMAP=SpinnerTail MESH=SpinnerTail
//#exec MESHMAP SCALE MESHMAP=SpinnerTail X=0.04 Y=0.04 Z=0.08
//#exec MESHMAP SETTEXTURE MESHMAP=SpinnerTail NUM=0 TEXTURE=JGSpinner2

var int i;


function ForceMeshToExist ()
{
	Spawn(Class'Spinner');
}

function PostBeginPlay()
{
	i=0;
	Super.PostBeginPlay();
}

function Initfor (Actor Other)
{   
	local int i; 
 
	Super.Initfor(Other);

	for ( i=0; i<4; i++ )
		Multiskins[i] = Other.MultiSkins[i];
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, 
							Vector Momentum, name DamageType)
{	
		if(bDeleteme)
    return;
		else
				Super.TakeDamage(Damage, instigatedBy, HitLocation, Momentum, DamageType);    	
}
		
singular function ChunkUp(int Damage)
{
 if(bDeleteMe)
   return;
	if ( bPermanent )
			return;
	if ( Region.Zone.bPainZone && (Region.Zone.DamagePerSec > 0) )
		{
			if ( Bugs != None )
				Bugs.Destroy();
		}
	else
			CreateReplacement();
		SetPhysics(PHYS_None);
		bHidden = true;
		SetCollision(false,false,false);
		bProjTarget = false;
		GotoState('Gibbing'); 
}
 
function CreateReplacement()
	{
		local SpinnerChunks carc;
		local int i;
		local vector vect;

		if (bHidden)
			return;
  if(bDeleteMe)
   return;
 	i++;
  if(i>1)
  	destroy();  
  if( Location + ZOffset[0] * CollisionHeight * vect(0,0,1)!= vect(0,0,0))
      vect=Location + ZOffset[0] * CollisionHeight * vect(0,0,1);
  else
       vect=location;
 	if ( bodyparts[0] != None )
		carc = Spawn(class 'SpinnerChunks',,, vect); 
		if (carc != None)
		{
   carc.CarcLocation=vect;
			carc.TrailSize = Trails[0];
			carc.Mesh = bodyparts[0];
   carc.skin = skin;
 	 for ( i=0; i<4; i++ )
   carc.Multiskins[i] = MultiSkins[i];
			carc.bMasterChunk = true;
			carc.Initfor(self);
			carc.Bugs = Bugs;
			if ( Bugs != None )
				Bugs.SetBase(carc);
			Bugs = None;
		}
		else if ( Bugs != None )
			Bugs.Destroy();
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

simulated singular function Landed(vector HitNormal)
{
	local rotator finalRot;
//	local float OldHeight;
	local BloodSpurt b;

	if ( (Velocity.Z < -1000) && !bPermanent && !bHidden && !bDeleteme)
	{
		ChunkUp(200);
		return;
	}

	finalRot = Rotation;
	finalRot.Roll = 0;
	finalRot.Pitch = 0;
	setRotation(finalRot);
	SetPhysics(PHYS_None);
	SetCollision(bCollideActors, false, false);
	if ( HitNormal.Z < 0.99 )
		ReducedHeightFactor = 0.1;
	if ( HitNormal.Z < 0.93 )
		ReducedHeightFactor = 0.0;
	if ( !IsAnimating() )
		LieStill();

	if ( Level.NetMode == NM_DedicatedServer )
		return;
 b = Spawn(class'BloodSpurt',,,,rot(16384,0,0));
 if (b!=none &&  bGreenBlood )
  {
   b.GreenBlood();
   b.RemoteRole = ROLE_None;
		}
}

state Dead 
{
	singular event BaseChange()
	{
		if ( (Mover(Base) != None) && (ExistTime == 0) )
		{
			ExistTime = FClamp(30.0 - 2 * DeathZone.NumCarcasses, 5, 12);
			SetTimer(3.0, true);
		}

		Global.BaseChange();
	} 
}

defaultproperties
{
      i=0
      bodyparts(0)=LodMesh'Gauntlet-10-BetaV4.SpinnerBody'
      bodyparts(1)=LodMesh'Gauntlet-10-BetaV4.SpinnerTail'
      bodyparts(2)=LodMesh'Gauntlet-10-BetaV4.SpinnerLeg1'
      bodyparts(3)=LodMesh'Gauntlet-10-BetaV4.SpinnerLeg2'
      bodyparts(4)=LodMesh'Gauntlet-10-BetaV4.SpinnerLeg3'
      bodyparts(5)=LodMesh'Gauntlet-10-BetaV4.SpinnerLeg4'
      bodyparts(6)=LodMesh'Gauntlet-10-BetaV4.SpinnerClaw'
      bodyparts(7)=LodMesh'Gauntlet-10-BetaV4.SpinnerHead'
      ZOffset(1)=0.750000
      ZOffset(2)=0.250000
      ZOffset(3)=0.250000
      ZOffset(4)=0.250000
      ZOffset(5)=0.250000
      ZOffset(7)=0.500000
      bGreenBlood=True
      AnimSequence="Death"
      Mesh=LodMesh'Gauntlet-10-BetaV4.spinner'
      CollisionRadius=32.000000
      CollisionHeight=22.000000
      Mass=100.000000
      Buoyancy=110.000000
}
