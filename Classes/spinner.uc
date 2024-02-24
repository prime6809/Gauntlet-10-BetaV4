//=============================================================================
// Spinner. Modded from RTNP for RTNP2U - Asgard
//   http://ammo.at/napali  http://www.angelfire.com/empire/napali/
//=============================================================================

class Spinner extends Spinsp;

//#exec MESH IMPORT MESH=Spinner ANIVFILE=models\Spinner_a.3d DATAFILE=models\Spinner_d.3d X=0 Y=0 Z=0
//#exec MESH ORIGIN MESH=Spinner X=0 Y=0 Z=112 YAW=-64

//#exec mesh SEQUENCE MESH=Spinner SEQ=All      STARTFRAME=0 NUMFRAMES=183
//#exec MESH SEQUENCE MESH=Spinner SEQ=death    STARTFRAME=0 NUMFRAMES=20
//#exec MESH SEQUENCE MESH=Spinner SEQ=bite     STARTFRAME=20 NUMFRAMES=17 Group=Attack
//#exec MESH SEQUENCE MESH=Spinner SEQ=backstep STARTFRAME=37 NUMFRAMES=9
//#exec mesh SEQUENCE MESH=Spinner SEQ=idle     STARTFRAME=46 NUMFRAMES=19
//#exec mesh SEQUENCE MESH=Spinner SEQ=jump     STARTFRAME=65 NUMFRAMES=16
//#exec mesh SEQUENCE MESH=Spinner SEQ=jumpsm   STARTFRAME=65 NUMFRAMES=6  
//#exec MESH SEQUENCE MESH=Spinner SEQ=look     STARTFRAME=81 NUMFRAMES=26
//#exec MESH SEQUENCE MESH=Spinner SEQ=run      STARTFRAME=107 NUMFRAMES=10
//#exec mesh SEQUENCE MESH=Spinner SEQ=threat   STARTFRAME=117 NUMFRAMES=17
//#exec MESH SEQUENCE MESH=Spinner SEQ=walk     STARTFRAME=134 NUMFRAMES=16
//#exec mesh SEQUENCE MESH=Spinner SEQ=wound    STARTFRAME=150 NUMFRAMES=11
//#exec MESH SEQUENCE MESH=Spinner SEQ=zap      STARTFRAME=160 NUMFRAMES=23 Group=Attack

//#exec TEXTURE IMPORT NAME=JSpinner1 FILE=models\Spider1.PCX GROUP=Skins FLAGS=2 // spidxLEG3
//#exec TEXTURE IMPORT NAME=JSpinner2 FILE=models\Spider2.PCX GROUP=Skins PALETTE=JSpinner1 // spidx2map6

//#exec MESH NOTIFY MESH=Spinner SEQ=bite          TIME=0.50 FUNCTION=BiteDamageTarget
//#exec mesh NOTIFY MESH=Spinner SEQ=run           TIME=0.00 FUNCTION=RunStep
//#exec mesh NOTIFY MESH=Spinner SEQ=run           TIME=0.50 FUNCTION=RunStep
//#exec MESH NOTIFY MESH=Spinner SEQ=walk          TIME=0.43 FUNCTION=WalkStep
//#exec MESH NOTIFY MESH=Spinner SEQ=walk          TIME=0.93 FUNCTION=WalkStep
//#exec mesh NOTIFY MESH=Spinner SEQ=zap           TIME=0.50 FUNCTION=SpawnShot

//#exec MESHMAP new   MESHMAP=Spinner MESH=Spinner
//#exec MESHMAP SCALE MESHMAP=Spinner X=0.1 Y=0.1 Z=0.2

//#exec MESHMAP SETTEXTURE MESHMAP=Spinner NUM=0 TEXTURE=JSpinner1
//#exec MESHMAP SETTEXTURE MESHMAP=Spinner NUM=1 TEXTURE=JSpinner2


//#exec AUDIO IMPORT FILE="Sounds\spAmb1.WAV"  name="spamb1"   GROUP="Spinner"
//#exec AUDIO IMPORT FILE="Sounds\spAmb2.wav"  NAME="spamb2"   GROUP="Spinner"
//#exec AUDIO IMPORT FILE="Sounds\spBite.wav"  NAME="spbite"   GROUP="Spinner"
//#exec AUDIO IMPORT FILE="Sounds\spdie1.wav"  NAME="spdie1"   GROUP="Spinner"
//#exec AUDIO IMPORT FILE="Sounds\spdie2.wav"  Name="spdie2"   GROUP="Spinner"
//#exec AUDIO IMPORT FILE="Sounds\spspinstep1.wav"   name="spstep1"  GROUP="Spinner"
//#exec AUDIO IMPORT FILE="Sounds\spspinstep2.wav"   NAME="spstep2"  GROUP="Spinner"
//#exec AUDIO IMPORT FILE="Sounds\spHurt1.wav"   NAME="sphurt1"   GROUP="Spinner"
//#exec AUDIO IMPORT FILE="Sounds\spHurt2.wav"   NAME="sphurt2"   GROUP="Spinner"
//#exec AUDIO IMPORT FILE="Sounds\spHurt3.wav"   NAME="sphurt3"   GROUP="Spinner"
//#exec AUDIO IMPORT FILE="Sounds\spThreat1.wav" NAME="spthreat1" GROUP="Spinner"
//#exec AUDIO IMPORT FILE="Sounds\spThreat2.wav" NAME="spthreat2" GROUP="Spinner"
//#exec AUDIO IMPORT FILE="Sounds\spThreat3.wav" NAME="spthreat3" GROUP="Spinner"

var() byte BiteDamage;	// Basic damage done by bite.
var() float pitchmod;

var(Sounds) sound Bite;
var(Sounds) sound Die2;
var(Sounds) sound Footstep;
var(Sounds) sound Footstep2;
var(Sounds) sound Hitsound3;
var(Sounds) sound Threaten3;
var(Sounds) sound Amb1;


function SetMovementPhysics()
{
 	if (Physics == PHYS_Falling)
 	   return;
  if ( Region.Zone.bWaterZone )
     	SetPhysics(PHYS_Swimming);
  else
     	SetPhysics(PHYS_Walking);
}

function PreSetMovement()
{
	bCanJump = true;
	bCanWalk = true;
	bCanSwim = true;
 bCanFly = false;
	if (Intelligence > BRAINS_Reptile)
		bCanOpenDoors = true;
	if (Intelligence == BRAINS_Human)
		bCanDoSpecial = true;
}

//
// Animation functions
//
function PlayRoamingSound()
{
	if ( (Threaten != None) && (FRand() < 0.3) )
		PlaySound(Threaten, SLOT_Talk,5.0, true,,pitchmod);
	else if (Roam != none && (FRand() < 0.6))
		PlaySound(Roam, SLOT_Talk,, true,,pitchmod);
}

function PlayThreateningSound()
{
 if (Threaten != none && FRand() < 0.5)
			PlaySound(Threaten, SLOT_Talk, 2.0, true,,pitchmod );
 else if (Threaten3 != none && FRand() < 0.9)
    	PlaySound(Threaten3, SLOT_Talk, 4.0, true,,pitchmod );
	else if (amb1 != none)
		PlaySound( amb1, SLOT_Talk, 2.0, false,,pitchmod );
}

function PlayAcquisitionSound()
{    
	if (Acquire != none && FRand() < 0.5)
     PlaySound(Acquire, SLOT_Talk, 2.0, true,,pitchmod );
	else if (Threaten3 != none)
		PlaySound(Threaten3, SLOT_Talk, 4.0, true,,pitchmod );
}

function TweenToFalling()
{
		PlayAnim('Jumpsm',0.7,0.1);
}

function PlayRunning()
{
	LoopAnim('Run', -1.0/GroundSpeed,, 0.8);
}
		
function PlayWalking()
{
	LoopAnim('Walk', -1.0/GroundSpeed,, 0.8);
}

function PlayWaiting()
{
	local float AnimSpeed;
	AnimSpeed = 0.3 + 0.6 * FRand(); //vary speed
	if( FRand() < 0.05 )
	{
		SetAlertness( 0.5 );
		PlayAnim( 'look', AnimSpeed, 0.2 );
	}
	else
	{
		SetAlertness( 0.0 ); 
  PlayAnim( 'idle', AnimSpeed, 0.2 );
	}
}

function PlayTurning()
{
	LoopAnim( 'walk', 1.0, 0.2 );
}

function PlayThreatening()
{
	local float decision, AnimSpeed;

	decision = FRand();
	AnimSpeed = 0.4 + 0.6 * FRand();

	if( decision < 0.7 )
	{
		PlayAnim( 'threat', AnimSpeed, 0.3 );
	}
	else if( decision < 0.9 )
	{
		PlayAnim( 'idle', AnimSpeed * 2, 0.3 );
	}
	else
	{
		PlayAnim( 'look', AnimSpeed, 0.3 );
	}
}

function PlayChallenge()
{
	PlayThreatening();
}

function PlayMeleeAttack()
{
	PlayAnim( 'bite' );
}

function PlayRangedAttack()
{
	PlayAnim( 'zap' );
}

function PlayGutHit( float tweentime )
{
	PlayAnim( 'wound' );
}

function PlayHeadHit( float tweentime )
{
	PlayAnim( 'wound' );
}

function PlayLeftHit( float tweentime )
{
	PlayAnim( 'wound' );
}

function PlayRightHit( float tweentime )
{
	PlayAnim( 'wound' );
}

function PlayBigDeath( name DamageType )
{
	PlayAnim( 'death' );
	PlaySound( Die2, SLOT_Talk, 4.5 * TransientSoundVolume,,,pitchmod );
}

function PlayHeadDeath( name DamageType )
{
	PlayAnim( 'death' );
	PlaySound( Die, SLOT_Talk, 4.5 * TransientSoundVolume,,,pitchmod );
}

function PlayLeftDeath( name DamageType )
{
	PlayAnim( 'death' );
	PlaySound( Die, SLOT_Talk, 4.5 * TransientSoundVolume,,,pitchmod );
}

function PlayRightDeath( name DamageType )
{
	PlayAnim( 'death' );
	PlaySound( Die, SLOT_Talk, 4.5 * TransientSoundVolume,,,pitchmod );
}

function PlayGutDeath( name DamageType )
{
	PlayAnim( 'death' );
	PlaySound( Die, SLOT_Talk, 4.5 * TransientSoundVolume,,,pitchmod );
}

function TweenToRunning( float tweentime )
{
	TweenAnim( 'run', tweentime );
}

function TweenToWalking( float tweentime )
{
	TweenAnim( 'walk', tweentime );
}

function TweenToWaiting( float tweentime )
{
	TweenAnim( 'idle', tweentime );
}

function PlayTakeHitSound( int Damage, name damageType, int Mult )
{
//	local float decision;

	if( Level.TimeSeconds - LastPainSound < 0.25 )
		return;
	LastPainSound = Level.TimeSeconds;

    if( FRand() < 0.2 )
	{
		PlaySound( HitSound3, SLOT_Pain, 2.0 * Mult,,,pitchmod );
	}
	else if( FRand() < 0.5 )
	{
		PlaySound( HitSound1, SLOT_Pain, 2.0 * Mult,,,pitchmod );
	}
	else
	{
		PlaySound( HitSound2, SLOT_Pain, 2.0 * Mult,,,pitchmod );
	}
}


//
// Notify functions
//

function RunStep()
{
	if( FRand() < 0.6 )
		PlaySound( FootStep, SLOT_Interact, 2.0,, 900 );
	else
		PlaySound( FootStep2, SLOT_Interact, 2.0,, 900 );
}

function WalkStep()
{
	if( FRand() < 0.6 )
		PlaySound( FootStep, SLOT_Interact, 0.5,, 500 );
	else
		PlaySound( FootStep2, SLOT_Interact, 0.5,, 500 );
}

function BiteDamageTarget()
{
	if ( Target == None )
		return;
        if( MeleeDamageTarget( BiteDamage, BiteDamage * 1000 * Normal( Target.Location - Location ) ) )
		PlaySound( Bite, SLOT_Interact );
}

function SpawnShot()
{
	local rotator FireRotation;
	local vector X,Y,Z, projStart;

 if(bDeleteme)
    return;
	GetAxes( Rotation, X, Y, Z );
	MakeNoise( 1.0 );
	projStart = Location + 1.1 * CollisionRadius * X + 0.4 * CollisionHeight * Z;
	FireRotation = AdjustToss( ProjectileSpeed, projStart, 200, bLeadTarget, bWarnTarget );
	spawn( RangedProjectile, self,'', projStart, FireRotation );
}


//
// Miscellaneous functions
//

function eAttitude AttitudeToCreature(Pawn Other)
{
	if ( Other.IsA('spinner') )
	    return ATTITUDE_Friendly;
	else
		return ATTITUDE_Ignore;
}

function bool CanFireAtEnemy()
{
	local vector HitLocation, HitNormal, EnemyDir, EnemyUp;
	local actor HitActor;
	local float EnemyDist;

	EnemyDir = Enemy.Location - Location;
	EnemyDist = VSize( EnemyDir );
	EnemyUp = Enemy.CollisionHeight * vect(0,0,0.9);

	//log( Self $ " CanFireAtEnemy() EnemyDir " $ rotator(EnemyDir) $ " EnemyDist " $ EnemyDist $ " EnemyUp " $ EnemyUp.Z );

	if( EnemyDist > 640 )
	{
		//log( Self $ " CanFireAtEnemy() EnemyDist > 640, return false" );
		return false;
	}
	if( EnemyDist > 300 )
	{
		EnemyDir = 300 * EnemyDir / EnemyDist;
		EnemyUp = 300 * EnemyUp / EnemyDist;
	}

	HitActor = Trace( HitLocation, HitNormal, Location + EnemyDir + EnemyUp, Location, true );

	if( HitActor == None || HitActor == Enemy || Pawn(HitActor) != None && AttitudeTo( Pawn(HitActor) ) <= ATTITUDE_Ignore )
		return true;

	HitActor = Trace( HitLocation, HitNormal, Location + EnemyDir, Location, true );

	return HitActor == None || HitActor == Enemy || Pawn(HitActor) != None && AttitudeTo( Pawn(HitActor) ) <= ATTITUDE_Ignore;
}


//
// Aiming functions
//

function rotator AdjustToss( float ProjSpeed, vector ProjStart, int AimError, bool LeadTarget, bool WarnTarget )
{
	local rotator FireRotation;
	local vector FireSpot;
	local actor HitActor;
	local vector HitLocation, HitNormal;
	local float TargetDist, TossSpeed, TossTime;

	if( projSpeed == 0 )
		return AdjustAim( projSpeed, projStart, aimerror, leadTarget, warnTarget );
	if( Target == None )
		Target = Enemy;
	if( Target == None )
		return Rotation;
	if( !Target.IsA('Pawn') )
		return rotator( Target.Location - Location );

	FireSpot = Target.Location;
	TargetDist = VSize( Target.Location - ProjStart );


	if ( leadTarget )
	{
		FireSpot += FMin( 1, 0.7 + 0.6 * FRand() ) * ( Target.Velocity * TargetDist / ProjSpeed );
		HitActor = Trace( HitLocation, HitNormal, FireSpot, ProjStart, false );
		if( HitActor != None )
		{
			FireSpot = 0.5 * ( FireSpot + Target.Location );
		}
	}

	//try middle
	FireSpot.Z = Target.Location.Z;
	HitActor = Trace( HitLocation, HitNormal, FireSpot, ProjStart, false );

	if ( HitActor != None && Target == Enemy )
	{
		FireSpot = LastSeenPos;
		if( Location.Z >= LastSeenPos.Z )
		{
			FireSpot.Z -= 0.5 * Enemy.CollisionHeight;
		}
	}

	// adjust for toss distance (assume 200 z velocity add & 60 init height)
	if( FRand() < 0.90 )
	{
		TossSpeed = ProjSpeed + 0.4 * VSize( Velocity );
		if( Region.Zone.ZoneGravity.Z != Region.Zone.Default.ZoneGravity.Z || TargetDist > TossSpeed )
		{
			TossTime = TargetDist / TossSpeed;
			FireSpot.Z -= ( ( 0.25 * Region.Zone.ZoneGravity.Z * TossTime + 200 ) * TossTime + 0.4 * CollisionHeight );
		}
	}

	FireRotation = Rotator( FireSpot - ProjStart );

	FireRotation.Yaw = FireRotation.Yaw + ( Rand(2 * AimError) - AimError );
	if( WarnTarget && Pawn(Target) != None )
		Pawn(Target).WarnTarget( self, ProjSpeed, Vector(FireRotation) );

	FireRotation.Yaw = FireRotation.Yaw & 65535;
	if( Abs( FireRotation.Yaw - ( Rotation.Yaw & 65535 ) ) > 8192 &&
		Abs( FireRotation.Yaw - ( Rotation.Yaw & 65535 ) ) < 57343 )
	{
		if( FireRotation.Yaw > Rotation.Yaw + 32768 ||
			FireRotation.Yaw < Rotation.Yaw && FireRotation.Yaw > Rotation.Yaw - 32768 )
		{
			FireRotation.Yaw = Rotation.Yaw - 8192;
		}
		else
		{
			FireRotation.Yaw = Rotation.Yaw + 8192;
		}
	}
	ViewRotation = FireRotation;
	return FireRotation;
}


//
// States
//

auto state StartUp
{
 ignores  SeePlayer, EnemyNotVisible, HearNoise, KilledBy, Trigger, Bump, HitWall, Falling, WarnTarget, Died, LongFall, PainTimer;

	function SetFall()
	{
	}
	function SetMovementPhysics()
	{
		SetPhysics( PHYS_None ); // don't fall at start
	}
//Begin:
//	log( Self $ " StartUp Rotation " $ Rotation $ " DesiredRotation " $ DesiredRotation );
}

state Waiting
{
TurnFromWall:
	if( NearWall(70) )
	{
  PlayTurning();
		TurnTo( Focus );
	}
Begin:
	TweenToWaiting( 0.4 );
	bReadyToAttack = false;
	if( Physics != PHYS_Falling )
	{
		SetPhysics( PHYS_None );
	}
KeepWaiting:
	NextAnim = '';
}

function eAttitude AttitudeTo(Pawn Other)
{
	if (Other.bIsPlayer && Other!=none )
	{
		if ( bIsPlayer && Level.Game.IsA('TeamGame') && (Other.PlayerReplicationInfo != none) 
   && (Team == Other.PlayerReplicationInfo.Team) )
			return ATTITUDE_Friendly;
		else if ( (Intelligence > BRAINS_None) && 
			((AttitudeToPlayer == ATTITUDE_Hate) || (AttitudeToPlayer == ATTITUDE_Threaten) 
				|| (AttitudeToPlayer == ATTITUDE_Fear)) ) //check if afraid 
		{
			if (RelativeStrength(Other) > Aggressiveness)
				   AttitudeToPlayer = AttitudeWithFear();
   else if (AttitudeToPlayer == ATTITUDE_Fear)
       AttitudeToPlayer = ATTITUDE_Hate;

		}
		return AttitudeToPlayer;
	}
 else if (Other.IsA('ScriptedPawn') && Other!=none )
	{
	if (Hated == Other )
	{
		if (RelativeStrength(Other) >= Aggressiveness)
			return AttitudeWithFear();
		else 
			return ATTITUDE_Hate;
	}
	else if ( (TeamTag != '') && (ScriptedPawn(Other) != None) && (TeamTag == ScriptedPawn(Other).TeamTag) )
		return ATTITUDE_Friendly;
	else	
		return AttitudeToCreature(Other); 
 }
}

defaultproperties
{
      BiteDamage=20
      pitchmod=1.000000
      Bite=Sound'Gauntlet-10-BetaV4.spinner.spbite'
      Die2=Sound'Gauntlet-10-BetaV4.spinner.spdie2'
      footstep=Sound'Gauntlet-10-BetaV4.spinner.spstep1'
      Footstep2=Sound'Gauntlet-10-BetaV4.spinner.spstep2'
      HitSound3=Sound'Gauntlet-10-BetaV4.spinner.sphurt3'
      Threaten3=Sound'Gauntlet-10-BetaV4.spinner.spthreat3'
      Amb1=Sound'Gauntlet-10-BetaV4.spinner.spamb1'
      CarcassType=Class'Gauntlet-10-BetaV4.SpinnerCarcass'
      TimeBetweenAttacks=3.500000
      bHasRangedAttack=True
      bGreenBlood=True
      RangedProjectile=Class'Gauntlet-10-BetaV4.SpinnerProjectile'
      Acquire=Sound'Gauntlet-10-BetaV4.spinner.spthreat1'
      Fear=Sound'Gauntlet-10-BetaV4.spinner.spamb2'
      Roam=Sound'Gauntlet-10-BetaV4.spinner.spthreat3'
      Threaten=Sound'Gauntlet-10-BetaV4.spinner.spthreat2'
      bCanStrafe=True
      MeleeRange=60.000000
      GroundSpeed=250.000000
      AccelRate=500.000000
      JumpZ=128.000000
      HitSound1=Sound'Gauntlet-10-BetaV4.spinner.sphurt1'
      HitSound2=Sound'Gauntlet-10-BetaV4.spinner.sphurt2'
      Die=Sound'Gauntlet-10-BetaV4.spinner.spdie1'
      CombatStyle=0.750000
      AnimSequence="Bite"
      DrawType=DT_Mesh
      Mesh=LodMesh'Gauntlet-10-BetaV4.spinner'
      CollisionRadius=32.000000
      Buoyancy=110.000000
      RotationRate=(Pitch=3072,Yaw=30000,Roll=2048)
}
