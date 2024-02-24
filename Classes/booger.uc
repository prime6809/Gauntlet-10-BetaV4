//=============================================================================
// Booger.
//=============================================================================
class Booger extends Pupae;

function JumpOffPawn()
{
	Super.JumpOffPawn();
	PlayAnim('dropUp', 1.0, 0.2);
}

function eAttitude AttitudeToCreature(Pawn Other)
{
	return ATTITUDE_Hate;
}

function PlayWaiting()
	{
	local float decision;
	local float animspeed;
	animspeed = 0.4 + 0.6 * FRand(); 
	decision = FRand();
	if ( !bool(NextAnim) || (decision < 0.4) ) //pick first waiting animation
	{
		if ( !bQuiet )
			PlaySound(Chew, SLOT_Talk, 0.7,,800);
		NextAnim = 'idle';
		LoopAnim(NextAnim, animspeed);
	}
	else
	{
		if ( !bQuiet )
			PlaySound(Stab, SLOT_Talk, 0.7,,800);
		NextAnim = 'FullJump';
		PlayAnim(NextAnim, animspeed, 0.01);
		Velocity.Z += jumpZ * animspeed;
	}
	}

function PlayChallenge()
{
	if ( FRand() < 0.3 )
		PlayWaiting();
	else
		PlayAnim('attack');
}

function TweenToFighter(float tweentime)
{
	TweenAnim('Fighter', tweentime);
}

function TweenToRunning(float tweentime)
{
	if (AnimSequence != 'run' || !bAnimLoop)
		TweenAnim('run', tweentime);
}

function TweenToWalking(float tweentime)
{
	TweenAnim('walk', tweentime);
}

function TweenToWaiting(float tweentime)
{
	TweenAnim('idle', tweentime);
}

function TweenToPatrolStop(float tweentime)
{
	TweenAnim('idle', tweentime);
}

function TweenToFalling()
{
	TweenAnim('Jump', 0.35);
}

function PlayInAir()
{
	TweenAnim('land', 0.2);
}

function PlayLanded(float impactVel)
{
	PlayAnim('dropDown', 1.0, 0.1);
}
/////
function PlayRunning()
{
	PlaySound(roam, SLOT_Interact);
	LoopAnim('run', -2.0/GroundSpeed,,0.4);
}

function PlayWalking()
{
	PlaySound(roam, SLOT_Interact);
	LoopAnim('walk', -2.0/GroundSpeed,,0.4);
}

function PlayTurning()
{
	TweenAnim('jump', 0.3);
}

function PlayDying(name DamageType, vector HitLocation)
{
	PlaySound(Die, SLOT_Talk, 3.5 * TransientSoundVolume);
	PlayAnim('die', 1.0, 0.1);
}

function PlayTakeHit(float tweentime, vector HitLoc, int damage)
{
	TweenAnim('pain', tweentime);
}

function PlayVictoryDance()
{
	PlayAnim('FullJump', 1.0, 0.1);
	Velocity.Z += jumpZ;
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
		PlaySound(Lunge, SLOT_Interact);
		Enable('Bump');
		PlayAnim('dropUp');
		Velocity = 450 * Normal(Target.Location + Target.CollisionHeight * vect(0,0,0.75) - Location);
		if (dist > CollisionRadius + Target.CollisionRadius + 35)
			Velocity.Z += 0.7 * dist;
		SetPhysics(PHYS_Falling);
	}
  	else
  	{
  		PlaySound(Stab, SLOT_Interact);
  		PlayAnim('attack');
		MeleeRange = 50;
		MeleeDamageTarget(BiteDamage, vect(0,0,0));
		MeleeRange = Default.MeleeRange;
	}  		
}

state MeleeAttack
{
ignores SeePlayer, HearNoise;

	singular function Bump(actor Other)
	{
		Disable('Bump');
		if ( (Other == Target) && (AnimSequence == 'dropUp') )
		{
			PlayAnim('dropDown');
			if (MeleeDamageTarget(LungeDamage, vect(0,0,0)))
			{
				if (FRand() < 0.5)
					PlaySound(Tear, SLOT_Interact);
				else
					PlaySound(Bite, SLOT_Interact);
			}
		}
	}
}		

defaultproperties
{
      BiteDamage=15
      LungeDamage=30
      Bite=Sound'Gauntlet-10-BetaV4.dog.dg_bark2'
      Stab=Sound'Gauntlet-10-BetaV4.dog.bark2'
      lunge=Sound'Gauntlet-10-BetaV4.dog.dg_lunge'
      Chew=Sound'Gauntlet-10-BetaV4.dog.dg_grwl1'
      Tear=Sound'Gauntlet-10-BetaV4.dog.dg_bark1'
      Acquire=Sound'Gauntlet-10-BetaV4.dog.dg_grwl2'
      Fear=Sound'Gauntlet-10-BetaV4.dog.dg_yelp'
      Roam=Sound'Gauntlet-10-BetaV4.dog.dg_grwl1'
      Threaten=Sound'Gauntlet-10-BetaV4.dog.dg_grwl2'
      GroundSpeed=360.000000
      JumpZ=450.000000
      Health=150
      HitSound1=Sound'Gauntlet-10-BetaV4.dog.dg_yelp'
      HitSound2=Sound'Gauntlet-10-BetaV4.dog.dg_yelp'
      Die=Sound'Gauntlet-10-BetaV4.dog.dg_die'
      Style=STY_Translucent
      Texture=Texture'UnrealShare.Autom1'
      Mesh=LodMesh'Gauntlet-10-BetaV4.booger'
      DrawScale=0.400000
      bMeshEnviroMap=True
      CollisionRadius=18.000000
      CollisionHeight=3.500000
}
