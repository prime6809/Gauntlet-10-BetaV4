//=============================================================================
// Hank.
//=============================================================================
class Hank extends Brute;

function PlayRangedAttack()
{
	PlayAnim('Precharg');
}

state RangedAttack
{
ignores SeePlayer, HearNoise, Bump;
//////////
	function TweenToFighter(float TweenTime)
	{
		if ( AnimSequence == 'T8' )
			return;
		if ( (GetAnimGroup(AnimSequence) == 'Hit') || (Skill > 3 * FRand()) || (VSize(Location - Target.Location) < 320)  )
			TweenAnim('Fighter', tweentime);
		else
			PlayAnim('T8', 1.0, 0.15);
	}
//////////
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		if (NextState == 'TakeHit')
		{
			NextState = 'RangedAttack';
			NextLabel = 'Begin';
		}
	}

	function StopWaiting()
	{
		Timer();
	}

	function EnemyNotVisible()
	{
		////log("enemy not visible");
		//let attack animation completes
	}

	function KeepAttacking()
	{
		if ( !bFiringPaused && ((FRand() > ReFireRate) || (Enemy == None) || (Enemy.Health <= 0) || !CanFireAtEnemy()) ) 
			GotoState('Attacking');
	}

	function Timer()
	{
		if ( bFiringPaused )
		{
			TweenToRunning(0.12);
			GotoState(NextState, NextLabel);
		}
	}

	function AnimEnd()
	{
		GotoState('RangedAttack', 'DoneFiring');
	}
	
	function BeginState()
	{
		bTurret=true;

		Target = Enemy;
		Disable('AnimEnd');
		bReadyToAttack = false;
		if ( bFiringPaused )
		{
			SetTimer(SpecialPause, false);
			SpecialPause = 0;
		}
	}
	
	function EndState()
	{
		bFiringPaused = false;

		bTurret=false;
	}

Challenge:
	Disable('AnimEnd');
	Acceleration = vect(0,0,0); //stop
	DesiredRotation = Rotator(Enemy.Location - Location);
	PlayChallenge();
	FinishAnim();
	if ( bCrouching && !Region.Zone.bWaterZone )
		Sleep(0.8 + FRand());
	bCrouching = false;
	TweenToFighter(0.1);
	Goto('FaceTarget');

Begin:
	if ( Enemy == None )
		GotoState('Attacking');

	Acceleration = vect(0,0,0); //stop
	DesiredRotation = Rotator(Enemy.Location - Location);
	TweenToFighter(0.15);
	
FaceTarget:
	Disable('AnimEnd');
	if (NeedToTurn(Enemy.Location))
	{
		PlayTurning();
		TurnToward(Enemy);
		TweenToFighter(0.1);
	}
	FinishAnim();

	if (VSize(Location - Enemy.Location) < 0.9 * MeleeRange + CollisionRadius + Enemy.CollisionRadius)
		GotoState('MeleeAttack', 'ReadyToAttack'); 

ReadyToAttack:
	if (!bHasRangedAttack)
		GotoState('Attacking');
	DesiredRotation = Rotator(Enemy.Location - Location);
	PlayRangedAttack();
//	Enable('AnimEnd');
	FinishAnim();
Firing:
	PlayAnim('StillFire');
	FinishAnim();
	if (Enemy == None )
		GotoState('Attacking');
	TurnToward(Enemy);
	if(frand()<0.93) 
		Goto('Firing');
DoneFiring:
	PlayAnim('GutShot');
	FinishAnim();
//	Disable('AnimEnd');
	KeepAttacking();  
	Goto('FaceTarget');
}

defaultproperties
{
      bMovingRangedAttack=False
      RangedProjectile=Class'Gauntlet-10-BetaV4.HankBullet'
      Health=700
      CombatStyle=0.200000
      //Skin=FireTexture'UnrealShare.CFLAM.cflame'
	  Skin=Texture'JHank1'
      Mesh=LodMesh'Gauntlet-10-BetaV4.hank'
      DrawScale=1.700000
}
