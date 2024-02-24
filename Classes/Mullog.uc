//=============================================================================
// Mullog.
//=============================================================================
class Mullog expands ScriptedPawn;

//#exec ANIM IMPORT ANIM=gollanim ANIMFILE=models\gollanim.PSA COMPRESS=0 IMPORTSEQS=1

//#exec MESH MODELIMPORT MESH=gollum MODELFILE=models\gollum.PSK LODSTYLE=12
//#exec MESH ORIGIN MESH=gollum X=0 Y=10 Z=10 YAW=64 ROLL=-128 PITCH=128

//#exec MESH WEAPONATTACH MESH=gollum BONE="Bip01 R Hand"
//#exec MESH WEAPONPOSITION MESH=gollum YAW=0 PITCH=0 ROLL=128 X=3.0 Y=-3.0 Z=0.0

//#exec MESHMAP SCALE MESHMAP=gollum X=0.7425 Y=0.7425 Z=0.7425
//#exec MESH DEFAULTANIM MESH=gollum ANIM=gollanim

//#exec ANIM DIGEST ANIM=gollAnim VERBOSE

//#exec ANIM NOTIFY ANIM=gollAnim SEQ=RunLG TIME=0.25 FUNCTION=PlayFootStep
//#exec ANIM NOTIFY ANIM=gollAnim SEQ=RunLG TIME=0.75 FUNCTION=PlayFootStep
//#exec ANIM NOTIFY ANIM=gollAnim SEQ=RunLGFR TIME=0.25 FUNCTION=PlayFootStep
//#exec ANIM NOTIFY ANIM=gollAnim SEQ=RunLGFR TIME=0.75 FUNCTION=PlayFootStep
//#exec ANIM NOTIFY ANIM=gollAnim SEQ=RunSM TIME=0.25 FUNCTION=PlayFootStep
//#exec ANIM NOTIFY ANIM=gollAnim SEQ=RunSM TIME=0.75 FUNCTION=PlayFootStep
//#exec ANIM NOTIFY ANIM=gollAnim SEQ=RunSMFR TIME=0.25 FUNCTION=PlayFootStep
//#exec ANIM NOTIFY ANIM=gollAnim SEQ=RunSMFR TIME=0.75 FUNCTION=PlayFootStep
//#exec ANIM NOTIFY ANIM=gollAnim SEQ=StrafeL TIME=0.25 FUNCTION=PlayFootStep
//#exec ANIM NOTIFY ANIM=gollAnim SEQ=StrafeL TIME=0.75 FUNCTION=PlayFootStep
//#exec ANIM NOTIFY ANIM=gollAnim SEQ=StrafeR TIME=0.25 FUNCTION=PlayFootStep
//#exec ANIM NOTIFY ANIM=gollAnim SEQ=StrafeR TIME=0.75 FUNCTION=PlayFootStep
//#exec ANIM NOTIFY ANIM=gollAnim SEQ=BackRun TIME=0.25 FUNCTION=PlayFootStep
//#exec ANIM NOTIFY ANIM=gollAnim SEQ=BackRun TIME=0.75 FUNCTION=PlayFootStep
//#exec ANIM NOTIFY ANIM=gollAnim SEQ=Dead1 TIME=0.7 FUNCTION=LandThump
//#exec ANIM NOTIFY ANIM=gollAnim SEQ=Dead2 TIME=0.9 FUNCTION=LandThump
//#exec ANIM NOTIFY ANIM=gollAnim SEQ=Dead3 TIME=0.45 FUNCTION=LandThump
//#exec ANIM NOTIFY ANIM=gollAnim SEQ=Dead4 TIME=0.6 FUNCTION=LandThump
//#exec ANIM NOTIFY ANIM=gollAnim SEQ=Dead6 TIME=0.6 FUNCTION=LandThump
//#exec ANIM NOTIFY ANIM=gollAnim SEQ=Dead7 TIME=0.6 FUNCTION=LandThump
//#exec ANIM NOTIFY ANIM=gollAnim SEQ=Dead9B TIME=0.8 FUNCTION=LandThump
//#exec ANIM NOTIFY ANIM=gollAnim SEQ=Dead5 TIME=0.6 FUNCTION=LandThump

//#exec AUDIO IMPORT FILE="Sounds\death1.WAV" NAME="gollumDeath1"
//#exec AUDIO IMPORT FILE="Sounds\death2.WAV" NAME="gollumDeath2"
//#exec AUDIO IMPORT FILE="Sounds\death3.WAV" NAME="gollumDeath3"
//#exec AUDIO IMPORT FILE="Sounds\death4.WAV" NAME="gollumDeath4"
//#exec AUDIO IMPORT FILE="Sounds\death5.WAV" NAME="gollumDeath5"
//#exec AUDIO IMPORT FILE="Sounds\death6.WAV" NAME="gollumDeath6"
//#exec AUDIO IMPORT FILE="Sounds\footstep1.WAV" NAME="gstep1"
//#exec AUDIO IMPORT FILE="Sounds\footstep2.WAV" NAME="gstep2"
//#exec AUDIO IMPORT FILE="Sounds\footstep3.WAV" NAME="gstep3"
//#exec AUDIO IMPORT FILE="Sounds\pain1.WAV" NAME="gollumpain1"
//#exec AUDIO IMPORT FILE="Sounds\pain2.WAV" NAME="gollumpain2"
//#exec AUDIO IMPORT FILE="Sounds\pain3.WAV" NAME="gollumpain3"
//#exec AUDIO IMPORT FILE="Sounds\pain4.WAV" NAME="gollumpain4"

// here is the selection screen stuff - chage the breath sequence numbers to what you need

//#exec ANIM IMPORT ANIM=gollselect ANIMFILE=models\gollselect.PSA COMPRESS=0.5 IMPORTSEQS=0
//#exec ANIM SEQUENCE ANIM=gollselect SEQ=All STARTFRAME=0 NUMFRAMES=16 RATE=10
//#exec ANIM SEQUENCE ANIM=gollselect SEQ=Breath3 STARTFRAME=0 NUMFRAMES=16 RATE=15
//#exec ANIM DIGEST ANIM=gollselect VERBOSE

//#exec MESH MODELIMPORT MESH=gollselect MODELFILE=models\gollselect.PSK LODSTYLE=12
//#exec MESH ORIGIN MESH=gollselect X=0 Y=10 Z=0 YAW=64 ROLL=-128 PITCH=128
//#exec MESHMAP SCALE MESHMAP=gollselect X=0.6425 Y=0.6425 Z=0.6425  // adjust these scales to fit
//#exec MESH DEFAULTANIM MESH=gollselect ANIM=gollselect

var() byte ClawDamage;	// Basic damage done by Claw/punch.
var bool bFirstAttack;

var(Sounds) sound die2;
var(Sounds) sound slick;
var(Sounds) sound slash;
var(Sounds) sound slice;
var(Sounds) sound slither;
var(Sounds) sound swim;
var(Sounds) sound dive;
var(Sounds) sound surface;
var(Sounds) sound scratch;
var(Sounds) sound charge;



function PreSetMovement()
{
	MaxDesiredSpeed = 0.79 + 0.07 * skill;
	bCanJump = true;
	bCanWalk = true;
	bCanSwim = true;
	bCanFly = false;
	MinHitWall = -0.6;
	bCanOpenDoors = true;
	bCanDoSpecial = true;
}

function eAttitude AttitudeToCreature(Pawn Other)
{
	if ( Other.IsA('Mullog') )
		return ATTITUDE_Friendly;
	else if ( Other.IsA('Nali') )
		return ATTITUDE_Hate;
	else
		return ATTITUDE_Ignore;
}

function SetMovementPhysics()
{
	if (Region.Zone.bWaterZone && (Physics != PHYS_Swimming) )
		SetPhysics(PHYS_Swimming);
	else if (Physics != PHYS_Walking)
		SetPhysics(PHYS_Walking);
}

function JumpOutOfWater(vector jumpDir)
{
	Falling();
	Velocity = jumpDir * WaterSpeed;
	Acceleration = jumpDir * AccelRate;
	velocity.Z = 460; //set here so physics uses this for remainder of tick
	PlayOutOfWater();
	bUpAndOut = true;
}

function SetFall()
	{
		if (Enemy != None)
		{
			NextState = 'Attacking'; //default
			NextLabel = 'Begin';
			NextAnim = 'Breath2';
			GotoState('FallingState');
		}
	}

function PlayAcquisitionSound()
{
	PlaySound(Acquire, SLOT_Talk);	
}

function PlayWaiting()
{
	local float decision;

	if (Region.Zone.bWaterZone)
	{
		LoopAnim('SwimLg', 0.2  + 0.3 * FRand());
		return;
	}

	decision = FRand();

	if (decision < 0.8)
		LoopAnim('Breath1', 0.2 + 0.6 * FRand());
	else if (decision < 0.9)
	{
		PlaySound(Slick, SLOT_Interact);
		LoopAnim('Taunt1', 0.4 + 0.6 * FRand());
	}
	else
	{
		PlaySound(Scratch, SLOT_Interact);
		LoopAnim('Breath2', 0.4 + 0.6 * FRand());
	}
}

function PlayPatrolStop()
{
	PlayWaiting();
}

function PlayWaitingAmbush()
{
	PlayWaiting();
}

function PlayChallenge()
{
	TweenToFighter(0.1);
}

function TweenToFighter(float tweentime)
{
	if (Region.Zone.bWaterZone)
		TweenAnim('Breath3', tweentime);
	else
		TweenAnim('Breath2', tweentime);
}

function TweenToRunning(float tweentime)
{
	if (Region.Zone.bWaterZone)
	{
		if ( (AnimSequence == 'StillLgFr') && IsAnimating() )
			return;
		if ( (AnimSequence != 'SwimLg') || !bAnimLoop )
			TweenAnim('SwimLg', tweentime);
	}
	else
	{
		if ( (AnimSequence == 'RunLgFr') && IsAnimating() )
			return;
		if ( (AnimSequence != 'RunLgFr') || !bAnimLoop )
			TweenAnim('RunLGFR', tweentime);
	}
}

function TweenToWalking(float tweentime)
{
	if (Region.Zone.bWaterZone)
	{
		if ( (AnimSequence != 'SwimLg') || !bAnimLoop )
			TweenAnim('SwimLg', tweentime);
	}
	else
	{
		if ( (AnimSequence != 'RunLgFr') || !bAnimLoop )
			TweenAnim('WalkLg', tweentime);
	}
}

function TweenToWaiting(float tweentime)
{
	if (Region.Zone.bWaterZone)
		TweenAnim('SwimLg', tweentime);
	else
		TweenAnim('Breath1', tweentime);
}

function TweenToPatrolStop(float tweentime)
{
	TweenToWaiting(tweentime);
}

function PlayRunning()
{
	if (Region.Zone.bWaterZone)
	{
		PlaySound(Swim, SLOT_Interact);
		LoopAnim('SwimLg', -1.0/WaterSpeed,, 0.4);
	}
	else
	{
		PlaySound(Slither, SLOT_Interact);
		LoopAnim('RunLG', -1.1/GroundSpeed,, 0.4);
	}
}

function PlayWalking()
{
	if (Region.Zone.bWaterZone)
	{
		PlaySound(Swim, SLOT_Interact);
		LoopAnim('SwimLg', -1.0/WaterSpeed,, 0.4);
	}
	else
	{
		PlaySound(Slither, SLOT_Interact);
		LoopAnim('WalkLg', -1.3/GroundSpeed,, 0.4);
	}
}

function PlayThreatening()
{
	local float decision;
	decision = FRand();

	if (decision < 0.8)
	{
		PlayWaiting();
		return;
	}
	NextAnim = 'WalkLg';




	if (Region.Zone.bWaterZone)
		TweenAnim('Breath3', 0.25);
	else
		TweenAnim('Breath2', 0.25);
}

function PlayTurning()
{
	if (Region.Zone.bWaterZone)
		TweenAnim('SwimLg', 0.35);
	else
		TweenAnim('WalkLg', 0.35);
}

function Carcass SpawnCarcass()
{
	local carcass carc;

	carc = Spawn(CarcassType);
	if ( carc != None )
		carc.Initfor(self);

	// Your texture does not need to fucking break just because you died geez.. >,>
	// that's just stupid..[facepalm]
	log("Mullog: Yay I died! time to break my texture!!! :P");
	carc.MultiSkins[0] = MultiSkins[0];
	carc.MultiSkins[1] = MultiSkins[1];
	carc.MultiSkins[2] = MultiSkins[2];
	carc.MultiSkins[3] = MultiSkins[3];
	carc.MultiSkins[4] = MultiSkins[4];
	carc.MultiSkins[5] = MultiSkins[5];
	log("Mullog: oh, wait, nvm... :(");

	return carc;
}

function PlayDying(name DamageType, vector HitLocation)
{
	if (Region.Zone.bWaterZone)
	{
		PlaySound(Die2, SLOT_Talk, 4 * TransientSoundVolume);
		PlayAnim('Dead2', 0.7, 0.1);
	}
	else
	{
		PlaySound(Die, SLOT_Talk, 4 * TransientSoundVolume);
		PlayAnim('Dead1', 0.7, 0.1);
	}
}

function PlayTakeHit(float tweentime, vector HitLoc, int Damage)
{
	if (Region.Zone.bWaterZone)
		TweenAnim('Flip', tweentime);
	else
		TweenAnim('Guthit', tweentime);
}

function PlayOutOfWater()
{
	PlayAnim('AimUpLg',,0.1);
}

function PlayDive()
{
	PlayAnim('Dead5',,0.1);
}

function TweenToFalling()
{
	TweenAnim('StillSmFr', 0.4);
}

function PlayInAir()
{
	TweenAnim('StillSmFr', 0.4);
}

function PlayLanded(float impactVel)
{
	TweenAnim('RunLgFr', 0.25);
}


function PlayVictoryDance()
{
	PlayAnim('Victory1', 0.3, 0.1);
	PlaySound(Charge, SLOT_Interact);
}

function ClawDamageTarget()
{
	MeleeDamageTarget(ClawDamage, (ClawDamage * 1000.0 * Normal(Target.Location - Location)));
}

function PlayMeleeAttack()
{
	local float dist, decision;

	decision = FRand();
	dist = VSize(Target.Location - Location);
	if (dist > CollisionRadius + Target.CollisionRadius + 45)
		decision = 0.0;

	if (Physics == PHYS_Falling)
		decision = 1.0;
	if (Target == None)
		decision = 1.0;

	if (decision < 0.15)
	{
		PlaySound(Slash, SLOT_Interact);
		Enable('Bump');
		PlayAnim('RunLg');
		Velocity = 300 * Normal(Target.Location + Target.CollisionHeight * vect(0,0,0.75) - Location);
		if (dist > CollisionRadius + Target.CollisionRadius + 35)
			Velocity.Z += 0.7 * dist;
		SetPhysics(PHYS_Falling);
	}
  	else
  	{
  		PlaySound(slash, SLOT_Interact);
  		PlayAnim('Thrust');
		MeleeRange = 50;
		MeleeDamageTarget(ClawDamage, vect(0,0,0));
		MeleeRange = Default.MeleeRange;
	}  		
}



function bool CanFireAtEnemy()
{
	local vector HitLocation, HitNormal, EnemyDir, projStart;
	local actor HitActor;
	local float EnemyDist;

	EnemyDir = Enemy.Location - Location + Enemy.CollisionHeight * vect(0,0,0.8);
	EnemyDist = VSize(EnemyDir);
	if (EnemyDist > 900)
		return false;

	EnemyDir = EnemyDir/EnemyDist;
	projStart = Location + 0.8 * CollisionRadius * EnemyDir + 0.8 * CollisionHeight * vect(0,0,1);
	HitActor = Trace(HitLocation, HitNormal,
				projStart + (MeleeRange + Enemy.CollisionRadius) * EnemyDir,
				projStart, false, vect(6,6,4) );

	return (HitActor == None);
}

function ShootTarget()
{
	FireProjectile( vect(1, 0, 0.8), 900);
}

function PlayRangedAttack()
{
	local float tweenin;
    local vector projStart;
	
	if (Region.Zone.bWaterZone)
	{
		PlayAnim('TreadSm');
		Spawn(RangedProjectile);
		return;
	}
	else
		tweenin = 0.35;
    projStart = Location + CollisionHeight * vect(0,0,-1.2);
    spawn(RangedProjectile ,self,'',projStart,AdjustAim(ProjectileSpeed, projStart, 900, bLeadTarget, bWarnTarget));
	PlayAnim('StillFrRp', 1.0, tweenin);
}


function PlayMovingAttack()
{
	PlayRangedAttack();
}

state MeleeAttack
{
ignores SeePlayer, HearNoise, Bump;

	function PlayMeleeAttack()
	{
		if ( Region.Zone.bWaterZone && !bFirstAttack && (FRand() > 0.4 + 0.17 * skill) )
		{
			PlayAnim('SwimLg');
			Acceleration = AccelRate * Normal(Location - Enemy.Location + 0.9 * VRand());
		}
		else
			Global.PlayMeleeAttack();
		bFirstAttack = false;
	}

	function BeginState()
	{
		Super.BeginState();
		bCanStrafe = True;
		bFirstAttack = True;
	}

	function EndState()
	{
		Super.EndState();
		bCanStrafe = false;
	}
}

defaultproperties
{
      ClawDamage=40
      bFirstAttack=False
      Die2=Sound'UnrealShare.Nali.death1n'
      SLICK=Sound'Gauntlet-10-BetaV4.gollumDeath3'
      SLASH=None
      slice=None
      SLITHER=None
      Swim=None
      DIVE=None
      Surface=None
      SCRATCH=None
      Charge=None
      Aggressiveness=5.000000
      RefireRate=1.000000
      bHasRangedAttack=True
      bMovingRangedAttack=True
      RangedProjectile=Class'Gauntlet-10-BetaV4.MullogProj1'
      ProjectileSpeed=400.000000
      Acquire=Sound'UnrealShare.Nali.breath1n'
      Fear=Sound'Gauntlet-10-BetaV4.gollumpain1'
      Roam=Sound'UnrealShare.Nali.thumpn'
      Threaten=Sound'Gauntlet-10-BetaV4.gollumpain4'
      bCanStrafe=True
      MeleeRange=2000.000000
      GroundSpeed=250.000000
      WaterSpeed=120.000000
      AirControl=0.350000
      SightRadius=3000.000000
      Health=200
      Skill=1.000000
      HitSound1=Sound'Gauntlet-10-BetaV4.gollumpain2'
      HitSound2=Sound'Gauntlet-10-BetaV4.gollumpain3'
      Die=Sound'UnrealShare.Nali.death1n'
      MenuName="Mullog"
      NameArticle="a "
      AnimSequence="Breath1"
      Tag="Mullog"
      DrawType=DT_Mesh
      Mesh=SkeletalMesh'Gauntlet-10-BetaV4.gollum'
      MultiSkins(0)=Texture'Gauntlet-10-BetaV4.Skin.MullogFace'
      MultiSkins(1)=Texture'Gauntlet-10-BetaV4.Skin.MullogBody'
      MultiSkins(2)=Texture'Gauntlet-10-BetaV4.Skin.MullogLims'
      MultiSkins(3)=Texture'Gauntlet-10-BetaV4.Skin.MullogFace'
      MultiSkins(4)=Texture'Gauntlet-10-BetaV4.Skin.MullogBody'
      MultiSkins(5)=Texture'Gauntlet-10-BetaV4.Skin.MullogLims'
      CollisionRadius=20.000000
      CollisionHeight=44.000000
}
