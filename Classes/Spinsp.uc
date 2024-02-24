//=============================================================================
// Spinsp  -- Asgard
//   http://ammo.at/napali  http://www.angelfire.com/empire/napali/
//=============================================================================
class Spinsp extends ScriptedPawn
	abstract;

var bool bCarc; 

function PreBeginPlay()
{
 bCarc=true;
 super.PreBeginPlay();
}

function SetFall()
{
	if (Enemy != None)
	{
		NextState = 'Attacking'; //default
		NextLabel = 'Begin';
		TweenToFalling();
		NextAnim = AnimSequence;
		GotoState('FallingState');
	}
}

singular function SpawnGibbedCarcass()
{
	local carcass carc;
 if (bDeleteMe)
  return;
 if (bCarc)
 {
  bCarc=false;
	 carc = Spawn(CarcassType);
	 if ( carc != None )
	 {
	 	carc.Initfor(self);
	 	carc.ChunkUp(-1 * Health);
	 }
	}
}

singular function Carcass SpawnCarcass()
{
	local carcass c;

 if (bCarc && !bDeleteMe)
  { 
   bCarc=false;
  	c = Spawn(CarcassType);
  	if ( c != None )
 	 	c.Initfor(self);
  	return c;
  }
}     

function gibbedBy(actor Other)
{
	local pawn instigatedBy;

	if ( Role < ROLE_Authority )
		return;
	instigatedBy = pawn(Other);
	if (instigatedBy == None)
		instigatedBy = Other.instigator;
	health = -1000; //make sure gibs
	Died(instigatedBy, 'Gibbed', Location);
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, name damageType)
{
 if(bDeleteme)
    return;
 if ( Role == ROLE_Authority )
		super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);  
}

function eAttitude AttitudeTo(Pawn Other)
{
	if (Other.bIsPlayer && Other!=none )
	{
		if ( bIsPlayer && Level.Game.IsA('TeamGame') && (Other.PlayerReplicationInfo != none) && (Team == Other.PlayerReplicationInfo.Team) )
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
	if (Hated == Other && Other!=none)
	{
		if (RelativeStrength(Other) >= Aggressiveness)
			return AttitudeWithFear();
		else 
			return ATTITUDE_Hate;
	}
 else if (Other.IsA('ScriptedPawn') && Other!=none )
	{
	if ( (TeamTag != '') && (TeamTag == ScriptedPawn(Other).TeamTag) )
		return ATTITUDE_Friendly;
	else	
		return AttitudeToCreature(Other); 
 }
	else
  return ATTITUDE_Ignore;
}

function Killed(pawn Killer, pawn Other, name damageType)
{
	local Pawn aPawn;
	local ScriptedPawn ScriptedOther;
	local bool bFoundTeam;

	if ( Health <= 0 )
		return;
	if (Other.bIsPlayer)
		bCanBePissed = true;
		
	ScriptedOther = ScriptedPawn(Other);
	if ( (TeamTag != '') && (ScriptedOther != None) 
		&& (ScriptedOther.TeamTag == TeamTag) )
	{
		if ( ScriptedOther.bTeamLeader )
			TeamTag = '';
		else if ( ScriptedOther.TeamID < TeamID )
			TeamID--;
		else if ( bTeamLeader )
		{
			aPawn = Level.PawnList;
			while ( aPawn != None )
			{
				if ( (ScriptedPawn(aPawn) != None) && (ScriptedPawn(aPawn) != self) &&
					(ScriptedPawn(aPawn).TeamTag == TeamTag) )
				{
					bFoundTeam = true;
					break;
				}
				aPawn = aPawn.nextPawn;
			}
			if ( !bFoundTeam )
			{
				bTeamLeader = false;
				TeamTag = '';
			}
		}
	}			
	
	if ( OldEnemy == Other )
		OldEnemy = None;

	if ( Enemy == Other )
	{
		Enemy = None;
		if ( (Killer == self) && (OldEnemy == None) )
		{
   for (aPawn=level.pawnlist;aPawn!=none;aPawn=aPawn.nextpawn)
			{
   	if (( aPawn.bCollideActors  && ( !aPawn.IsA('FlockPawn') ))
        && (VSize(Location - aPawn.Location) < 1000) && CanSee(aPawn) )  
				{
					if ( SetEnemy(aPawn) )
					{
						GotoState('Attacking');
						return;
					}
				}
			}
			Target = Other;
			GotoState('VictoryDance'); 
		}
		else 
			GotoState('Attacking');
	}
}

function bool CanFireAtEnemy()
{
	local vector HitLocation, HitNormal,X,Y,Z, projStart;
	local actor zzHitActor;

	if ( Weapon == None )
		return false;
	if ( Enemy == none || enemy.health < 0 || enemy.bdeleteme )
   return false;
	GetAxes(Rotation,X,Y,Z);
	projStart = Location + Weapon.CalcDrawOffset() + Weapon.FireOffset.X * X + 1.2 * Weapon.FireOffset.Y * Y + Weapon.FireOffset.Z * Z;
	if ( Weapon.bInstantHit )
		zzHitActor = Trace(HitLocation, HitNormal, Enemy.Location + Enemy.CollisionHeight * vect(0,0,0.7), projStart, true);
	else
		zzHitActor = Trace(HitLocation, HitNormal,
				projStart + 220 * Normal(Enemy.Location + Enemy.CollisionHeight * vect(0,0,0.7) - Location),
				projStart, true);

	if ( zzHitActor == Enemy )
		return true;
	if ( (zzHitActor != None) && (VSize(HitLocation - Location) < 200) )
		return false;
	if ( (Pawn(zzHitActor) != None) && (AttitudeTo(Pawn(zzHitActor)) > ATTITUDE_Ignore) )
		return false;

	return true;
}

function bool ChooseTeamAttackFor(ScriptedPawn TeamMember)
{
	if ( (Enemy == None) && TeamMember != none && (TeamMember.Enemy != None) && LineOfSightTo(TeamMember) )
	{
		if (SetEnemy(TeamMember.Enemy))
			MakeNoise(1.0);
	}
	if ( TeamMember != none && TeamMember.health > 0 && !bTeamSpeaking )
		SpeakOrderTo(TeamMember);
	if ( TeamMember == Self )
	{
		ChooseLeaderAttack();
		return true;		
	}
	
	if ( TeamMember != none && TeamMember.Enemy != none && TeamMember.bReadyToAttack )
	{
		TeamMember.Target = TeamMember.Enemy;
		Enemy=TeamMember.Enemy;
		if ( TeamMember.health > 0 && VSize(Enemy.Location - Location) <= (TeamMember.MeleeRange + TeamMember.Enemy.CollisionRadius + TeamMember.CollisionRadius))
		{
			TeamMember.GotoState('MeleeAttack');
			return true;
		}
		else if (TeamMember.bMovingRangedAttack || (TeamMember.TeamID == 1) )
			TeamMember.SetTimer(TimeBetweenAttacks, False);
		else if ( TeamMember.bHasRangedAttack && (TeamMember.bIsPlayer || TeamMember.Enemy.bIsPlayer) && TeamMember.CanFireAtEnemy() )
		{
			if ( TeamMember.health > 0 && (!TeamMember.bIsPlayer || (3 * FRand() > Skill)) )
			{
				TeamMember.GotoState('RangedAttack');
				return true;
			}
		}
	}
 if  ( Enemy == none && TeamMember.Enemy != none )
       SetEnemy(TeamMember.Enemy);
	if ( TeamMember != none && TeamMember.health > 0 && (!TeamMember.bHasRangedAttack || (TeamMember.TeamID == 1))  )
		TeamMember.GotoState('Charging');
	else if ( TeamMember != none  && TeamMember.health > 0 && TeamMember.TeamID == 2 )
	{
		TeamMember.bStrafeDir = true;
		TeamMember.GotoState('TacticalMove', 'NoCharge'); 
	}
	else if ( TeamMember != none && TeamMember.health > 0 && TeamMember.TeamID == 3 )
	{
		TeamMember.bStrafeDir = false;
		TeamMember.GotoState('TacticalMove', 'NoCharge'); 
	}
	else
		{
   if ( TeamMember != none && TeamMember.health > 0 )
  		TeamMember.GotoState('TacticalMove');
		}
	return true;
}

function bool CanStakeOut()
{
	local vector HitLocation, HitNormal;
	local actor HitActor;

	if ( (Physics == PHYS_Flying) && !bCanStrafe )
		return false;
 if (Enemy == none )
		return false;
	if ( VSize(Enemy.Location - LastSeenPos) > 800 )
		return false;		
	
	HitActor = Trace(HitLocation, HitNormal, LastSeenPos, Location + EyeHeight * vect(0,0,1), false);
	if ( HitActor == None )
	{
		HitActor = Trace(HitLocation, HitNormal, LastSeenPos , Enemy.Location + Enemy.BaseEyeHeight * vect(0,0,1), false);
		return (HitActor == None);
	}
	return false;
}

function Died(pawn Killer, name damageType, vector HitLocation)
{
	local pawn OtherPawn;
	local actor A;

	if ( bDeleteMe )
		return; //already destroyed
	Health = Min(0, Health);
	for ( OtherPawn=Level.PawnList; OtherPawn!=None; OtherPawn=OtherPawn.nextPawn )
		OtherPawn.Killed(Killer, self, damageType);
	if ( CarriedDecoration != None )
		DropDecoration();
 if ( killer != none && killer.PlayerReplicationInfo != None )
  level.game.Killed(Killer, self, damageType);
	//log(class$" dying");
	if( Event != '' )
		foreach AllActors( class 'Actor', A, Event )
			A.Trigger( Self, Killer );
	Level.Game.DiscardInventory(self);
	Velocity.Z *= 1.3;
	if ( Gibbed(damageType) )
	{
		SpawnGibbedCarcass();
		if ( bIsPlayer )
			HidePlayer();
		else
			Destroy();
	}
	PlayDying(DamageType, HitLocation);
	if ( Level.Game.bGameEnded )
		return;
	if ( RemoteRole == ROLE_AutonomousProxy )
		ClientDying(DamageType, HitLocation);
	GotoState('Dying');
}

function bool MeleeDamageTarget(int hitdamage, vector pushdir)
{
	local vector HitLocation, HitNormal;
	local actor HitActor;

    if (enemy!=none && enemy.health >0 && !Enemy.bDeleteme  )
      target = enemy;

    if ( Pawn(target) != none && Pawn(target).health >0  && !target.bDeleteme )
    {
    if ( (VSize(Target.Location - Location) <= MeleeRange * 1.4 + Target.CollisionRadius + CollisionRadius)
	     	&& ((Physics == PHYS_Flying) || (Physics == PHYS_Swimming) || (Abs(Location.Z - Target.Location.Z)
		     <= FMax(CollisionHeight, Target.CollisionHeight) + 0.5 * FMin(CollisionHeight, Target.CollisionHeight))) )
      	{
       	HitActor = Trace(HitLocation, HitNormal, Target.Location, Location, false);
		      if ( HitActor != None )
	        		return false;
		       Target.TakeDamage(hitdamage, Self,HitLocation, pushdir, 'hacked');
		       return true;
	      }
    }
	  return false;
}

function bool SetEnemy( Pawn NewEnemy )
{
	local bool resultz;
	local eAttitude newAttitude, oldAttitude;
	local bool noOldEnemyz;
	local float newStrengthz;

	if ( !bCanWalk && !bCanFly && !NewEnemy.FootRegion.Zone.bWaterZone )
		return false;
	if ( (NewEnemy == Self) || (NewEnemy == None) || (NewEnemy.Health <= 0) 
     || NewEnemy.bDeleteme || NewEnemy.IsA('FlockPawn'))
		return false;

	noOldEnemyz = (Enemy == None);
	resultz = false;
	newAttitude = AttitudeTo(NewEnemy);
//	log ("Attitude to potential enemy is "$newAttitude);
	if ( !noOldEnemyz )
	{
		if (Enemy == NewEnemy)
			return true;
		else if ( NewEnemy.bIsPlayer && (AlarmTag != '') )
		{
			OldEnemy = Enemy;
			Enemy = NewEnemy;
			resultz = true;
		} 
		else if ( newAttitude == ATTITUDE_Friendly )
		{
			if ( bIgnoreFriends )
				return false;
			if ( (NewEnemy.Enemy != None) && (NewEnemy.Enemy.Health > 0) ) 
			{
				if ( NewEnemy.Enemy.bIsPlayer && (NewEnemy.AttitudeToPlayer < AttitudeToPlayer) )
					AttitudeToPlayer = NewEnemy.AttitudeToPlayer;
				if ( AttitudeTo(NewEnemy.Enemy) < AttitudeTo(Enemy) )
				{
					OldEnemy = Enemy;
					Enemy = NewEnemy.Enemy;
					resultz = true;
				}
			}
		}
		else 
		{
			oldAttitude = AttitudeTo(Enemy);
			if ( (newAttitude < oldAttitude) || 
				( (newAttitude == oldAttitude) 
					&& ((VSize(NewEnemy.Location - Location) < VSize(Enemy.Location - Location)) 
						|| !LineOfSightTo(Enemy)) ) ) 
			{
				if ( bIsPlayer && Enemy.IsA('PlayerPawn') && !NewEnemy.IsA('PlayerPawn') )
				{
					newStrengthz = relativeStrength(NewEnemy);
					if ( (newStrengthz < 0.2) && (relativeStrength(Enemy) < FMin(0, newStrengthz))  
						&& (IsInState('Hunting')) && (Level.TimeSeconds - HuntStartTime < 5) )
						resultz = false;
					else
					{
						resultz = true;
						OldEnemy = Enemy;
						Enemy = NewEnemy;
					}
				} 
				else
				{
					resultz = true;
					OldEnemy = Enemy;
					Enemy = NewEnemy;
				}
			}
		}
	}
	else if ( newAttitude < ATTITUDE_Ignore )
	{
		resultz = true;
		Enemy = NewEnemy;
	}
	else if ( newAttitude == ATTITUDE_Friendly ) //your enemy is my enemy
	{
//		log("noticed a friend");
		if ( NewEnemy.bIsPlayer && (AlarmTag != '') )
		{
			Enemy = NewEnemy;
			resultz = true;
		} 
		if (bIgnoreFriends)
			return false;

		if ( (NewEnemy.Enemy != None) && (NewEnemy.Enemy.Health > 0) ) 
		{
			resultz = true;
// 		log("his enemy is my enemy");
			Enemy = NewEnemy.Enemy;
  if ( NewEnemy.Enemy.bIsPlayer && (NewEnemy.AttitudeToPlayer < AttitudeToPlayer) )
					AttitudeToPlayer = NewEnemy.AttitudeToPlayer;
  else if ( NewEnemy.IsA('ScriptedPawn') && (ScriptedPawn(NewEnemy) != None) && (ScriptedPawn(NewEnemy).Hated == Enemy) )
			 	Hated = Enemy;
		}
	}

	if ( resultz )
	{
		//log(class$" has new enemy - "$enemy.class);
 	LastSeenPos = Enemy.Location;
		LastSeeingPos = Location;
		EnemyAcquired();
		if ( !bFirstHatePlayer && Enemy.bIsPlayer && (FirstHatePlayerEvent != '') )
			TriggerFirstHate();
	}
	else if ( NewEnemy.bIsPlayer && (NewAttitude < ATTITUDE_Threaten) )
		OldEnemy = NewEnemy;
				
	return resultz;
}

function PlayCombatMove()
{
 if ( Enemy == None )
		return;
	if ( bMovingRangedAttack && bReadyToAttack && bCanFire && !NeedToTurn(Enemy.Location) )
	{
		Target = Enemy;
		PlayMovingAttack();
		if ( FRand() > 0.5 * (0.5 + skill * 0.25 + ReFireRate) )
		{
			bReadyToAttack = false;
			SetTimer(TimeBetweenAttacks  * (1.0 + FRand()),false); 
		}
	}		
	else 
	{
		if ( !bReadyToAttack && (TimerRate == 0.0) )
			SetTimer(0.7, false);
		PlayRunning();
	}
}

state VictoryDance
{
ignores EnemyNotVisible;

function PickDestination()
	{
		if (Target != none && target.IsA('Pawn') && Pawn(target).health >0)
		{
   target=none; 
			WhatToDoNext('Waiting', 'TurnFromWall'); 
			return;
		}	
		super.PickDestination();
 }

Begin:
	if ( (Target == None) || 
		(VSize(Location - Target.Location) < 
		(1.3 * CollisionRadius + Target.CollisionRadius + CollisionHeight - Target.CollisionHeight)) )
			Goto('Taunt');
	Destination = Target.Location;
	TweenToWalking(0.3);
	FinishAnim();
	PlayWalking();
	Enable('Bump');
		
MoveToEnemy: 
	WaitForLanding();
	PickDestination();
	if (SpecialPause > 0.0)
	{
		Acceleration = vect(0,0,0);
		TweenToPatrolStop(0.3);
		Sleep(SpecialPause);
		SpecialPause = 0.0;
		TweenToWalking(0.1);
		FinishAnim();
		PlayWalking();
	}
	MoveToward(MoveTarget, WalkingSpeed);
	Enable('Bump');
	if ((Target == None) || ( target.IsA('pawn') && Pawn(target).health >0 ) || (VSize(Location - Target.Location) < 
		(1.3 * CollisionRadius + Target.CollisionRadius + Abs(CollisionHeight - Target.CollisionHeight))))
		Goto('Taunt');
	Goto('MoveToEnemy');

Taunt:
	Acceleration = vect(0,0,0);
	TweenToFighter(0.2);
	FinishAnim();	
 if (Target!=none)
	 {
  PlayTurning();
	 TurnToward(Target);
	 DesiredRotation = rot(0,0,0);
	 DesiredRotation.Yaw = Rotation.Yaw;
	 setRotation(DesiredRotation);
  TweenToFighter(0.2);
 	FinishAnim();
	 } 
	PlayVictoryDance();
	FinishAnim(); 
	WhatToDoNext('Waiting','TurnFromWall');
}
			
state Roaming
{
	ignores EnemyNotVisible;

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		 if ( Enemy != None )
	 		LastSeenPos = Enemy.Location;
			if ( NextState == 'TakeHit' )
				{
				NextState = 'Attacking'; //default
				NextLabel = 'Begin';
				GotoState('TakeHit');
			}
			else
				GotoState('Attacking');
	}

	function FearThisSpot(Actor aSpot)
	{
		Destination = Location + 120 * Normal(Location - aSpot.Location);
		GotoState('Wandering', 'Moving');
	}

	function Timer()
	{
		Enable('Bump');
	}

	function Bump(Actor Other)
	{
		if ( FRand() < 0.03)
			GotoState('Wandering');
		else
			Super.Bump(Other);
	}

	function SetFall()
	{
		NextState = 'Roaming';
		NextLabel = 'ContinueRoam';
		NextAnim = AnimSequence;
		GotoState('FallingState');
	}

	function EnemyAcquired()
	{
		GotoState('Acquisition');
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;

		if ( Wall.IsA('Mover') && Mover(Wall).HandleDoor(self) )
		{
			bSpecialGoal = true;
			if ( SpecialPause > 0 )
				Acceleration = vect(0,0,0);
			GotoState('Roaming', 'Moving');
			return;
		}
		Focus = Destination;

  if ( PickWallAdjust() )
			{
   if ( Physics == PHYS_Falling )
			SetFall();
   else
   GotoState('Roaming', 'AdjustFromWall');
		 }
  else
			MoveTimer = -1.0;
	}

 function MayFall()
	{
		bCanJump = ( (MoveTarget != None) 
					&& (MoveTarget.Physics != PHYS_Falling ));
	}
	   
	function PickDestination()
	{
   local Actor Path;
   local NavigationPoint Nav;
   local int zzi;
   local float dist;
   local vector Dir;

  numHuntPaths++;
  if ( numHuntPaths > 80 )
						{
  	   gotoState('Wandering');
						return;
						} 
  if (SpecialGoal != None)
     {
      Path = FindPathToward(SpecialGoal);
      if (Path != None)
        {
	        MoveTarget = Path;
         return;
        }
     } 
   if ( Orderobject == None )
 		{
    zzi=0;
    	for ( Nav=Level.NavigationPointList; Nav!=None; Nav=Nav.NextNavigationPoint )
      if ( Nav.IsA('pathnode') || Nav.IsA('Ambushpoint') || Nav.IsA('Patrolpoint'))
           {
	 	        		Dir = Nav.Location - Location;
	           	dist = VSize(Dir);
         	if ( (dist < 1000) && (dist > CollisionRadius+50) )
               {
                zzi++;
                 if ( ((Orderobject == none) || (Rand(zzi) == 0)) && actorReachable(Nav) )
		               Orderobject = Nav;    																	
	              }
            }
	  } 
   if ( Orderobject == None )
							{
       GotoState('Wandering');
							return;
       }
			else
		    {
         if ( actorReachable(Orderobject) )
           {
            numHuntPaths = 0;
            MoveTarget = Orderobject;
            Orderobject = None;
           	if ( VSize(MoveTarget.Location - Location) > 2 * CollisionRadius )
              return;  
            }
           Path = FindPathToward(Orderobject);
           if ( Path != None )
            {
	             MoveTarget = Path;
              return;
	            }
	          else
	           Orderobject = None;
           }
        if ( FRand() < 0.25 )
		         GotoState('Wandering');
		      else
          			GotoState('Roaming', 'pausing');
  }        
									
 function EndState()
	 {
    numHuntPaths = 0;
  }


Begin:
	//log(class$" Roaming");
 numHuntPaths = 0;

Roam:
	TweenToWalking(0.15);
	NextAnim = '';
	WaitForLanding();
	PickDestination();
	FinishAnim();
	PlayWalking();

Moving:
	if (SpecialPause > 0.0)
	{
  Acceleration = vect(0,0,0);
		TweenToPatrolStop(0.3);
		Sleep(SpecialPause);
		SpecialPause = 0.0;
		TweenToWalking(0.1);
		FinishAnim();
		PlayWalking();
	}
	MoveToward(MoveTarget, WalkingSpeed);
	if ( bSpecialGoal )
	{
		bSpecialGoal = false;
		Goto('Roam');
	}
	Acceleration = vect(0,0,0);
	TweenToPatrolStop(0.3);
	FinishAnim();
	NextAnim = '';
Pausing:
 Acceleration = vect(0,0,0);
	PlayPatrolStop();
	FinishAnim();
	if ( !bQuiet && (FRand() < 0.3) )
		PlayRoamingSound();
	Goto('Roam');

ContinueRoam:
	FinishAnim();
	PlayWalking();
	Goto('Roam');

AdjustFromWall:
 StrafeTo(Destination, Focus);
	Destination = Focus;
 Goto('Moving');
}   

state Attacking
{
ignores SeePlayer, HearNoise, Bump, HitWall;

	function ChooseAttackMode()
	{
		local eAttitude AttitudeToEnemy;
//		local float Aggression;
		local pawn zzchangeEn;

		if ((Enemy == none) || (Enemy.Health <= 0) || (Enemy.bDeleteme) )
		{
			if (Orders == 'Attacking')
				Orders = '';
			WhatToDoNext('','');
			return;
		}

		if ( (AlarmTag != '') && Enemy.bIsPlayer )
		{
			if (AttitudeToPlayer > ATTITUDE_Ignore)
			{
				GotoState('AlarmPaused', 'WaitForPlayer');
				return;
			}
			else if ( (AttitudeToPlayer != ATTITUDE_Fear) || bInitialFear )
			{
				GotoState('TriggerAlarm');
				return;
			}
		}

		AttitudeToEnemy = AttitudeTo(Enemy);

		if (AttitudeToEnemy == ATTITUDE_Fear)
		{
			GotoState('Retreating');
			return;
		}

		else if (AttitudeToEnemy == ATTITUDE_Threaten)
		{
			GotoState('Threatening');
			return;
		}

		else if (AttitudeToEnemy == ATTITUDE_Friendly)
		{
			if (Enemy.bIsPlayer)
				GotoState('Greeting');
			else
				WhatToDoNext('','');
			return;
		}

  else if (!LineOfSightTo(Enemy))
	  {
			if ( (OldEnemy != none  )
				&& (AttitudeTo(OldEnemy) == ATTITUDE_Hate) && LineOfSightTo(OldEnemy) && !OldEnemy.bDeleteme)
			{
				zzchangeEn = enemy;
				enemy = oldenemy;
				oldenemy = zzchangeEn;
			}
			else
			{
     if ( (Orders == 'Guarding') && !LineOfSightTo(OrderObject) )
					GotoState('Guarding');
				else if ( !bHasRangedAttack || VSize(Enemy.Location - Location)
							> 600 + (FRand() * RelativeStrength(Enemy) - CombatStyle) * 600 )
					GotoState('Hunting');
				else if ( bIsBoss || (Intelligence > BRAINS_None) )
				{
					HuntStartTime = Level.TimeSeconds;
					NumHuntPaths = 0;
					GotoState('StakeOut');
				}
				else
					WhatToDoNext('Waiting', 'TurnFromWall');
				return;
			}
		}

		else if ( (TeamLeader != None) && TeamLeader.ChooseTeamAttackFor(self) )
			return;

		if (bReadyToAttack )
		{
			////log("Attack!");
			Target = Enemy;
			If (VSize(Enemy.Location - Location) <= (MeleeRange + Enemy.CollisionRadius + CollisionRadius))
			{
				GotoState('MeleeAttack');
				return;
			}
			else if (bMovingRangedAttack)
				SetTimer(TimeBetweenAttacks, False);
			else if (bHasRangedAttack && (bIsPlayer || enemy.bIsPlayer) && CanFireAtEnemy() )
			{
				if (!bIsPlayer || (2.5 * FRand() > Skill) )
				{
					GotoState('RangedAttack');
					return;
				}
			}
		}

		//decide whether to charge or make a tactical move
		if ( !bHasRangedAttack )
			GotoState('Charging');
		else
			GotoState('TacticalMove');
		//log("Next state is "$state);
	}

	//EnemyNotVisible implemented so engine will update LastSeenPos
	function EnemyNotVisible()
	{
		////log("enemy not visible");
	}

	function Timer()
	{
		bReadyToAttack = True;
	}

	function BeginState()
	{
		if ( TimerRate <= 0.0 )
			SetTimer(TimeBetweenAttacks  * (1.0 + FRand()),false);
		if (Physics == PHYS_None)
			SetMovementPhysics();
	}

Begin:
	//log(class$" choose Attack");
	ChooseAttackMode();
}

state Acquisition
{
ignores falling, landed; 

	function WarnTarget(Pawn shooter, float projSpeed, vector FireDir)
	{
		local eAttitude zzatt;

		zzatt = AttitudeTo(shooter);
		if ( ((zzatt == ATTITUDE_Ignore) || (zzatt == ATTITUDE_Threaten)) )
			damageAttitudeTo(shooter);
	}
 
 function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, name damageType)
	{
  if ( (Enemy != None) && (Enemy == InstigatedBy) )
		LastSeenPos = Enemy.Location;
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		if (NextState == 'TakeHit')
		{
			NextState = 'Attacking';
			NextLabel = 'Begin';
			GotoState('TakeHit');
		}
		else
			GotoState('Attacking');
	}

	singular function HearNoise(float Loudness, Actor NoiseMaker)
	{
		local vector OldLastSeenPos;

		if ( SetEnemy(NoiseMaker.instigator) )
		{
			OldLastSeenPos = LastSeenPos;
			if ( Enemy ==  NoiseMaker.instigator  )
				LastSeenPos = 0.5 * (NoiseMaker.Location + VSize(NoiseMaker.Location - Location) * vector(Rotation));
			else if ( (Pawn(NoiseMaker) != None) && (Enemy == Pawn(NoiseMaker).Enemy) )
				LastSeenPos = 0.5 * (Pawn(NoiseMaker).Enemy.Location + VSize(Pawn(NoiseMaker).Enemy.Location - Location) * vector(Rotation));
			if ( VSize(OldLastSeenPos - Enemy.Location) < VSize(LastSeenPos - Enemy.Location) )
				LastSeenPos = OldLastSeenPos;
		} 
	}

	function SeePlayer(Actor SeenPlayer)
	{
		if ( SetEnemy(Pawn(SeenPlayer)) )
		{
		 PlayAcquisitionSound();
   MakeNoise(1.0);
			NextAnim = '';
			LastSeenPos = Enemy.Location;
			GotoState('Attacking');
		}
	}

	function BeginState()
	{
		if (health <= 0)
		//	log(self$" acquisition while dead");
		Disable('Tick'); //only used for bounding anim time
		SetAlertness(-0.5);
	}

PlayOut:
	Acceleration = vect(0,0,0);
	if ( (AnimFrame < 0.6) && IsAnimating() )
	{
		Sleep(0.05);
		Goto('PlayOut');
	}

Begin:
 SetMovementPhysics();

AcquTurn:
	Acceleration = vect(0,0,0);
	if (NeedToTurn(LastSeenPos))
	{
		PlayTurning();
		TurnTo(LastSeenPos);
	}
	DesiredRotation = Rotator(LastSeenPos - Location);
	TweenToFighter(0.2);
	FinishAnim();
 if ( Enemy == None )
		WhatToDoNext('','');
	////log("Stimulus = "$Stimulus);
	if ( AttitudeTo(Enemy) == ATTITUDE_Fear )  //will run away from noise
	{
		LastSeenPos = Enemy.Location;
		MakeNoise(1.0);
		NextAnim = '';
		GotoState('Attacking');
	}
	else //investigate noise
	{
		////log("investigate noise");
		if ( pointReachable((Location + LastSeenPos) * 0.5) )
		{
			TweenToWalking(0.3);
			FinishAnim();
			PlayWalking();
			MoveTo((Location + LastSeenPos) * 0.5, WalkingSpeed);
			Acceleration = vect(0,0,0);
		}
		WhatToDoNext('','');
	}
}

state Wandering
{
	ignores EnemyNotVisible;

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		if ( Enemy != None )
			LastSeenPos = Enemy.Location;

		if ( NextState == 'TakeHit' )
			{
			NextState = 'Attacking'; 
			NextLabel = 'Begin';
			GotoState('TakeHit'); 
			}
		else
			GotoState('Attacking');
	}

	function Timer()
	{
		Enable('Bump');
	}

	function SetFall()
	{
		NextState = 'Wandering'; 
		NextLabel = 'ContinueWander';
		NextAnim = AnimSequence;
		GotoState('FallingState'); 
	}

	function EnemyAcquired()
	{
		GotoState('Acquisition');
	}

 function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		if ( Wall.IsA('Mover') && Mover(Wall).HandleDoor(self) )
		{
			if ( SpecialPause > 0 )
				Acceleration = vect(0,0,0);
			GotoState('Wandering', 'Pausing');
			return;
		}
		Focus = Destination;
		if ( PickWallAdjust() && (FRand() < 0.7) )
		{
			if ( Physics == PHYS_Falling )
				SetFall();
			else
				GotoState('Wandering', 'AdjustFromWall');
		}
		else
			MoveTimer = -1.0;
	}

	
	function bool TestDirection(vector dir, out vector pick)
	{	
		local vector HitLocation, HitNormal, dist;
		local float minDist;
		local actor HitActor;

		minDist = FMin(150.0, 4*CollisionRadius);
		pick = dir * (minDist + (450 + 12 * CollisionRadius) * FRand());

		HitActor = Trace(HitLocation, HitNormal, Location + pick + 1.5 * CollisionRadius * dir , Location, false);
		if (HitActor != None)
		{
			pick = HitLocation + (HitNormal - dir) * 2 * CollisionRadius;
			HitActor = Trace(HitLocation, HitNormal, pick , Location, false);
			if (HitActor != None)
				return false;
		}
		else
			pick = Location + pick;
		 
		dist = pick - Location;
		if (Physics == PHYS_Walking)
			dist.Z = 0;
		
		return (VSize(dist) > minDist); 
	}
			
	function PickDestination()
	{
		local vector pick, pickdir;
		local bool success;
		local float XY;
		//Favor XY alignment
		XY = FRand();
		if (XY < 0.3)
		{
			pickdir.X = 1;
			pickdir.Y = 0;
		}
		else if (XY < 0.6)
		{
			pickdir.X = 0;
			pickdir.Y = 1;
		}
		else
		{
			pickdir.X = 2 * FRand() - 1;
			pickdir.Y = 2 * FRand() - 1;
		}
		if (Physics != PHYS_Walking)
		{
			pickdir.Z = 2 * FRand() - 1;
			pickdir = Normal(pickdir);
		}
		else
		{
			pickdir.Z = 0;
			if (XY >= 0.6)
				pickdir = Normal(pickdir);
		}	

		success = TestDirection(pickdir, pick);
		if (!success)
			success = TestDirection(-1 * pickdir, pick);
		
		if (success)	
			Destination = pick;
		else
			GotoState('Wandering', 'Turn');
	}

	function AnimEnd()
	{
		PlayPatrolStop();
	}

	function FearThisSpot(Actor aSpot)
	{
		Destination = Location + 120 * Normal(Location - aSpot.Location); 
	}

	function BeginState()
	{
		Enemy = None;
		SetAlertness(0.2);
		bReadyToAttack = false;
		Disable('AnimEnd');
		NextAnim = '';
		bCanJump = false;
	}
	
	function EndState()
	{
		if (JumpZ > 0)
			bCanJump = true;
	}

Begin:
	//log(class$" Wandering");

Wander: 
	TweenToWalking(0.15);
	WaitForLanding();
	PickDestination();
	FinishAnim();
	PlayWalking();
	
Moving:
	Enable('HitWall');
	MoveTo(Destination, WalkingSpeed);

Pausing:
	Acceleration = vect(0,0,0);
	if ( NearWall(2 * CollisionRadius + 50) )
	{
		PlayTurning();
		TurnTo(Focus);
	}
	if (FRand() < 0.3)
		PlayRoamingSound();
	Enable('AnimEnd');
	NextAnim = '';
	TweenToPatrolStop(0.2);
	Sleep(1.0);
	Disable('AnimEnd');
	FinishAnim();
	Goto('Wander');

ContinueWander:
	FinishAnim();
	PlayWalking();
	if ( !bQuiet && (FRand() < 0.3) )
		PlayRoamingSound();
	if (FRand() < 0.2)
		Goto('Turn');
	Goto('Wander');

Turn:
	Acceleration = vect(0,0,0);
	PlayTurning();
	TurnTo(Location + 20 * VRand());
	Goto('Pausing');

AdjustFromWall:  
	StrafeTo(Destination, Focus); 
	Destination = Focus; 
	Goto('Moving');
}   

state StakeOut
{
ignores EnemyNotVisible; 

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		bFrustrated = true;
  if ( (Enemy != None) && (Enemy == InstigatedBy) )
		LastSeenPos = Enemy.Location;
		if (NextState == 'TakeHit')
		{
			if (AttitudeTo(Enemy) == ATTITUDE_Fear)
			{
				NextState = 'Retreating';
				NextLabel = 'Begin';
			}
			else
			{
				NextState = 'Attacking';
				NextLabel = 'Begin';
			}
			GotoState('TakeHit'); 
		}
		else
			GotoState('Attacking');
	}

	function rotator AdjustAim(float projSpeed, vector projStart, int aimerror, bool leadTarget, bool warnTarget)
	{
		local rotator FireRotation;
		local vector FireSpot;
		local actor HitActor;
		local vector HitLocation, HitNormal;
				
		FireSpot = LastSeenPos;
		aimerror = aimerror * (0.5 * (4 - skill - FRand()));	
			 
		HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
		if( HitActor != None ) 
		{
			////log("adjust aim up");
 			FireSpot.Z += 0.9 * Enemy.CollisionHeight;
 			HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
			 bClearShot = (HitActor == None);
    if ( !bClearShot )
				FireSpot = LastSeenPos;
		}
		
		FireRotation = Rotator(FireSpot - ProjStart);
			 
		FireRotation.Yaw = FireRotation.Yaw + 0.5 * (Rand(2 * aimerror) - aimerror);
		viewRotation = FireRotation;			
		return FireRotation;
	}
		
	function BeginState()
	{
		local actor HitActor;
		local vector HitLocation, HitNormal;

		Acceleration = vect(0,0,0);
		bCanJump = false;
		HitActor = Trace(HitLocation, HitNormal, LastSeenPos + vect(0,0,0.9) * Enemy.CollisionHeight, Location + vect(0,0,0.8) * EyeHeight, false);
		bClearShot = (HitActor == None);
		bReadyToAttack = true;
		SetAlertness(0.5);
	}

Begin:
	Acceleration = vect(0,0,0);
	PlayChallenge();
	TurnTo(LastSeenPos);
 if ( Enemy == None )
		GotoState('Attacking');
	if ( bHasRangedAttack && bClearShot && (FRand() < 0.5) && (VSize(Enemy.Location - LastSeenPos) < 150) && CanStakeOut() )
		PlayRangedAttack();
	FinishAnim();
	PlayChallenge();
	if ( bCrouching && !Region.Zone.bWaterZone )
		Sleep(1);
	bCrouching = false;
	Sleep(1 + FRand());
	if (Enemy!=none)
	{
	if ( !bHasRangedAttack || !bClearShot || (VSize(Enemy.Location - Location) 
				> 350 + (FRand() * RelativeStrength(Enemy) - CombatStyle) * 350) )
		GotoState('Hunting', 'AfterFall');
	else if ( CanStakeOut() )
		Goto('Begin');
	else
		GotoState('Hunting', 'AfterFall');
		}
  else
		GotoState('Attacking');
}

state TacticalMove
{
ignores SeePlayer, HearNoise;

 function SetFall()
	{
		Acceleration = vect(0,0,0);
		Destination = Location;
		NextState = 'Attacking'; 
		NextLabel = 'Begin';
		NextAnim = AnimSequence;
		GotoState('FallingState');
	}

 function Timer()
	{
		bReadyToAttack = True;
		Enable('Bump');
  if ( Enemy == None )
			return;
  Target = Enemy;
		if (VSize(Enemy.Location - Location) 
				<= (MeleeRange + Enemy.CollisionRadius + CollisionRadius))
			GotoState('MeleeAttack');		 
		else if ( bHasRangedAttack && ((!bMovingRangedAttack && (FRand() < 0.8)) || (FRand() > 0.5 + 0.17 * skill)) ) 
			GotoState('RangedAttack');
	}

 function PickDestination(bool bNoCharge)
	{
		local vector pickdir, enemydir, zzenemyPart, Y, zzminDest;
		local actor HitActor;
		local vector HitLocation, HitNormal, collSpec;
		local float Aggression, enemydist, minDist, strafeSize, zzoptDist;
		local bool success, zzbNoReach;
	
  if ( !bReadyToAttack && (TimerRate == 0.0) )
			SetTimer(0.7, false);

		bChangeDir = false;
		if (Region.Zone.bWaterZone && !bCanSwim && bCanFly)
		{
			Destination = Location + 75 * (VRand() + vect(0,0,1));
			Destination.Z += 100;
			return;
		}
  if ( Enemy == None )
		{
		GotoState('Attacking');
		return;
  }
		if ( Enemy.Region.Zone.bWaterZone )
			bNoCharge = bNoCharge || !bCanSwim;
		else 
			bNoCharge = bNoCharge || (!bCanFly && !bCanWalk);
		
		success = false;
		enemydist = VSize(Location - Enemy.Location);
		Aggression = 2 * (CombatStyle + FRand()) - 1.1;
		if ( intelligence == BRAINS_Human )
		{
			if ( Enemy.bIsPlayer && (AttitudeToPlayer == ATTITUDE_Fear) && (CombatStyle > 0) )
				Aggression = Aggression - 2 - 2 * CombatStyle;
			if ( Weapon != None )
				Aggression += 2 * Weapon.SuggestAttackStyle();
			if ( Enemy.Weapon != None )
				Aggression += 2 * Enemy.Weapon.SuggestDefenseStyle();
		}

		if ( enemydist > 1000 )
			Aggression += 1;
		if ( bIsPlayer && !bNoCharge )
			bNoCharge = ( Aggression < FRand() );

		if ( (Physics == PHYS_Walking) || (Physics == PHYS_Falling) )
		{
			if (Location.Z > Enemy.Location.Z + 140) //tactical height advantage
				Aggression = FMax(0.0, Aggression - 1.0 + CombatStyle);
			else if (Location.Z < Enemy.Location.Z - CollisionHeight) // below enemy
			{
				if ( !bNoCharge && (Intelligence > BRAINS_Reptile) 
					&& (Aggression > 0) && (FRand() < 0.6) )
				{
					GotoState('Charging');
					return;
				}
				else if ( (enemydist < 1.1 * (Enemy.Location.Z - Location.Z)) 
						&& !actorReachable(Enemy) ) 
				{
					zzbNoReach = (Intelligence > BRAINS_None);
					aggression = -1.5 * FRand();
				}
			}
		}
	
		if (!bNoCharge && (Aggression > 2 * FRand()))
		{
			if ( zzbNoReach && (Physics != PHYS_Falling) )
			{
				TweenToRunning(0.15);
				GotoState('Charging', 'NoReach');
			}
			else
				GotoState('Charging');
			return;
		}

		if (enemydist > FMax(VSize(OldLocation - Enemy.OldLocation), 240))
			Aggression += 0.4 * FRand();
			 
		enemydir = (Enemy.Location - Location)/enemydist;
		minDist = FMin(160.0, 3*CollisionRadius);
		if ( bIsPlayer )
			zzoptDist = 80 + FMin(enemydist, 250 * (FRand() + FRand()));  
		else 
			zzoptDist = 50 + FMin(enemydist, 500 * FRand());
		Y = (enemydir Cross vect(0,0,1));
		if ( Physics == PHYS_Walking )
		{
			Y.Z = 0;
			enemydir.Z = 0;
		}
		else 
			enemydir.Z = FMax(0,enemydir.Z);
			
		strafeSize = FMax(-0.7, FMin(0.85, (2 * Aggression * FRand() - 0.3)));
		zzenemyPart = enemydir * strafeSize;
		strafeSize = FMax(0.0, 1 - Abs(strafeSize));
		pickdir = strafeSize * Y;
		if ( bStrafeDir )
			pickdir *= -1;
		bStrafeDir = !bStrafeDir;
		collSpec.X = CollisionRadius;
		collSpec.Y = CollisionRadius;
		collSpec.Z = FMax(6, CollisionHeight - 18);
		
		zzminDest = Location + minDist * (pickdir + zzenemyPart);
		HitActor = Trace(HitLocation, HitNormal, zzminDest, Location, false, collSpec);
		if (HitActor == None)
		{
			success = (Physics != PHYS_Walking);
			if ( !success )
			{
				collSpec.X = FMin(14, 0.5 * CollisionRadius);
				collSpec.Y = collSpec.X;
				HitActor = Trace(HitLocation, HitNormal, zzminDest - (18 + MaxStepHeight) * vect(0,0,1), zzminDest, false, collSpec);
				success = (HitActor != None);
			}
			if (success)
				Destination = zzminDest + (pickdir + zzenemyPart) * zzoptDist;
		}
	
		if ( !success )
		{					
			collSpec.X = CollisionRadius;
			collSpec.Y = CollisionRadius;
			zzminDest = Location + minDist * (zzenemyPart - pickdir); 
			HitActor = Trace(HitLocation, HitNormal, zzminDest, Location, false, collSpec);
			if (HitActor == None)
			{
				success = (Physics != PHYS_Walking);
				if ( !success )
				{
					collSpec.X = FMin(14, 0.5 * CollisionRadius);
					collSpec.Y = collSpec.X;
					HitActor = Trace(HitLocation, HitNormal, zzminDest - (18 + MaxStepHeight) * vect(0,0,1), zzminDest, false, collSpec);
					success = (HitActor != None);
				}
				if (success)
					Destination = zzminDest + (zzenemyPart - pickdir) * zzoptDist;
			}
			else 
			{
				if ( (CombatStyle <= 0) || (Enemy.bIsPlayer && (AttitudeToPlayer == ATTITUDE_Fear)) )
					zzenemyPart = vect(0,0,0);
				else if ( (enemydir Dot zzenemyPart) < 0 )
					zzenemyPart = -1 * zzenemyPart;
				pickdir = Normal(zzenemyPart - pickdir + HitNormal);
				zzminDest = Location + minDist * pickdir;
				collSpec.X = CollisionRadius;
				collSpec.Y = CollisionRadius;
				HitActor = Trace(HitLocation, HitNormal, zzminDest, Location, false, collSpec);
				if (HitActor == None)
				{
					success = (Physics != PHYS_Walking);
					if ( !success )
					{
						collSpec.X = FMin(14, 0.5 * CollisionRadius);
						collSpec.Y = collSpec.X;
						HitActor = Trace(HitLocation, HitNormal, zzminDest - (18 + MaxStepHeight) * vect(0,0,1), zzminDest, false, collSpec);
						success = (HitActor != None);
					}
					if (success)
						Destination = zzminDest + pickdir * zzoptDist;
				}
			}	
		}
					
		if ( !success )
			GiveUpTactical(bNoCharge);
		else 
		{
			pickdir = (Destination - Location);
			enemydist = VSize(pickdir);
			if ( enemydist > minDist + 2 * CollisionRadius )
			{
				pickdir = pickdir/enemydist;
				HitActor = Trace(HitLocation, HitNormal, Destination + 2 * CollisionRadius * pickdir, Location, false);
				if ( (HitActor != None) && ((HitNormal Dot pickdir) < -0.6) )
					Destination = HitLocation - 2 * CollisionRadius * pickdir;
			}
		}
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		Focus = Destination;
		if ( Enemy == None )
		{
			GotoState('Attacking');
			return;
		}
		if ( bChangeDir || (FRand() < 0.5) 
			|| (((Enemy.Location - Location) Dot HitNormal) < 0) )
		{
			DesiredRotation = Rotator(Enemy.Location - location);
			GiveUpTactical(false);
		}
		else
		{
			bChangeDir = true;
			Destination = Location - HitNormal * FRand() * 500;
		}
	}

TacticalTick:
	Sleep(0.02);	
Begin:
	TweenToRunning(0.15);
	Enable('AnimEnd');
	if (Physics == PHYS_Falling)
	{
		DesiredRotation = Rotator(Enemy.Location - Location);
		Focus = Enemy.Location;
		Destination = Enemy.Location;
		WaitForLanding();
	}
	PickDestination(false);

DoMove:
	if ( !bCanStrafe )
	{ 
DoDirectMove:
		Enable('AnimEnd');
		if ( GetAnimGroup(AnimSequence) == 'MovingAttack' )
		{
			AnimSequence = '';
			TweenToRunning(0.12);
		}
		bCanFire = false;
		MoveTo(Destination);
	}
	else
	{
DoStrafeMove:
		Enable('AnimEnd');
		bCanFire = true;
		StrafeFacing(Destination, Enemy);	
	}
	if (FRand() < 0.5)
		PlayThreateningSound();

	if ( (Enemy != None) && !LineOfSightTo(Enemy) && ValidRecovery() )
		Goto('RecoverEnemy');
	else
	{
		bReadyToAttack = true;
		GotoState('Attacking');
	}
	
NoCharge:
	TweenToRunning(0.15);
	Enable('AnimEnd');
	if (Physics == PHYS_Falling)
	{
		DesiredRotation = Rotator(Enemy.Location - Location);
		Focus = Enemy.Location;
		Destination = Enemy.Location;
		WaitForLanding();
	}
	PickDestination(true);
	Goto('DoMove');
	
AdjustFromWall:
	Enable('AnimEnd');
	StrafeTo(Destination, Focus); 
	Destination = Focus; 
	Goto('DoMove');

TakeHit:
	TweenToRunning(0.12);
	Goto('DoMove');

RecoverEnemy:
	Enable('AnimEnd');
	bReadyToAttack = true;
	HidingSpot = Location;
	bCanFire = false;
	Destination = LastSeeingPos + 3 * CollisionRadius * Normal(LastSeeingPos - Location);
	if ( bCanStrafe || (VSize(LastSeeingPos - Location) < 3 * CollisionRadius) )
		StrafeFacing(Destination, Enemy);
	else
		MoveTo(Destination);
	if ( Weapon == None ) 
		Acceleration = vect(0,0,0);
	if ( NeedToTurn(Enemy.Location) )
	{
		PlayTurning();
		TurnToward(Enemy);
	}
	if ( bHasRangedAttack && CanFireAtEnemy() )
	{
		Disable('AnimEnd');
		DesiredRotation = Rotator(Enemy.Location - Location);
		if ( Weapon == None ) 
		{
			PlayRangedAttack();
			FinishAnim();
			TweenToRunning(0.1);
			bReadyToAttack = false;
			SetTimer(TimeBetweenAttacks, false);
		}
		else
		{
			FireWeapon();
			if ( Weapon.bSplashDamage )
			{
				bFire = 0;
				bAltFire = 0;
			}
		}

		if ( bCanStrafe && (FRand() + 0.1 > CombatStyle) )
		{
			Enable('EnemyNotVisible');
			Enable('AnimEnd');
			Destination = HidingSpot + 4 * CollisionRadius * Normal(HidingSpot - Location);
			Goto('DoMove');
		}
	}
	if ( !bMovingRangedAttack )
		bReadyToAttack = false;

	GotoState('Attacking');
}

state Charging
{
ignores SeePlayer, HearNoise;

	function MayFall()
	{
		if ( MoveTarget != Enemy )
			return;

		if ( intelligence == BRAINS_None )
			return;

		bCanJump = ActorReachable(Enemy);
		if ( !bCanJump )
				GotoState('TacticalMove', 'NoCharge');
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		if ( Wall.IsA('Mover') && Mover(Wall).HandleDoor(self) )
		{
			bSpecialGoal = true;
			if ( SpecialPause > 0 )
				Acceleration = vect(0,0,0);
			GotoState('Charging', 'SpecialNavig');
			return;
		}
		Focus = Destination;

  if ( PickWallAdjust() )
			{
   if ( Physics == PHYS_Falling )
			SetFall();
   else
   GotoState('Charging', 'AdjustFromWall');
		 }
  else
			MoveTimer = -1.0;
	}   
	
	function SetFall()
	{
		NextState = 'Charging'; 
		NextLabel = 'ResumeCharge';
		NextAnim = AnimSequence;
		GotoState('FallingState'); 
	}

	function FearThisSpot(Actor aSpot)
	{
		Destination = Location + 120 * Normal(Location - aSpot.Location); 
		GotoState('TacticalMove', 'DoStrafeMove');
	}

	function bool StrafeFromDamage(vector momentum, float Damage, name DamageType, bool bFindDest)
	{
		local vector zzsideDir, extent, HitLocation, HitNormal;
		local actor HitActor;
		local float zzhealthpct;

		if ( (damageType == 'shot') || (damageType == 'jolted') )
			zzhealthpct = 0.17;
		else
			zzhealthpct = 0.25;

		zzhealthpct *= CombatStyle;
		if ( FRand() * Damage < zzhealthpct * Health ) 
			return false;

		if ( !bFindDest )
			return true;

		zzsideDir = Normal( Normal(Enemy.Location - Location) Cross vect(0,0,1) );
		if ( (momentum Dot zzsideDir) > 0 )
			zzsideDir *= -1;
		Extent.X = CollisionRadius;
		Extent.Y = CollisionRadius;
		Extent.Z = CollisionHeight;
		HitActor = Trace(HitLocation, HitNormal, Location + 100 * zzsideDir, Location, false, Extent);
		if (HitActor != None)
		{
			zzsideDir *= -1;
			HitActor = Trace(HitLocation, HitNormal, Location + 100 * zzsideDir, Location, false, Extent);
		}
		if (HitActor != None)
			return false;
		
		if ( Physics == PHYS_Walking )
		{
			HitActor = Trace(HitLocation, HitNormal, Location + 100 * zzsideDir - MaxStepHeight * vect(0,0,1), Location + 100 * zzsideDir, false, Extent);
			if ( HitActor == None )
				return false;
		}
		Destination = Location + 250 * zzsideDir;
		GotoState('TacticalMove', 'DoStrafeMove');
		return true;
	}
			
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, name damageType)
	{
		local float pick;
		local vector zzsideDir; 	
		local bool zzbWasOnGround;

		zzbWasOnGround = (Physics == PHYS_Walking);
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		if (NextState == 'TakeHit')
		{
			if (AttitudeTo(Enemy) == ATTITUDE_Fear)
			{
				NextState = 'Retreating';
				NextLabel = 'Begin';
			}
			else if ( (Intelligence > BRAINS_Mammal) && bHasRangedAttack && bCanStrafe 
				&& StrafeFromDamage(momentum, Damage, damageType, false) )
			{
				NextState = 'TacticalMove';
				NextLabel = 'NoCharge';
			}
			else
			{
				NextState = 'Charging';
				NextLabel = 'TakeHit';
			}
			GotoState('TakeHit'); 
		}
		else if ( (Intelligence > BRAINS_Mammal) && bHasRangedAttack && bCanStrafe 
			&& StrafeFromDamage(momentum, Damage, damageType, true) )
			return;
		else if ( zzbWasOnGround && (MoveTarget == Enemy) && 
					(Physics == PHYS_Falling) && (Intelligence == BRAINS_Human) ) //weave
		{
			pick = 1.0;
			if ( bStrafeDir )
				pick = -1.0;
			zzsideDir = Normal( Normal(Enemy.Location - Location) Cross vect(0,0,1) );
			zzsideDir.Z = 0;
			Velocity += pick * GroundSpeed * 0.7 * zzsideDir;   
			if ( FRand() < 0.2 )
				bStrafeDir = !bStrafeDir;
		}
	}
							
	function AnimEnd() 
	{
		PlayCombatMove();
	}
	
	function Timer()
	{
		bReadyToAttack = True; 			
  if ( Enemy == None )
		{
			GotoState('Attacking');
			return;
		}
  Target = Enemy;
		if (VSize(Enemy.Location - Location) 
				<= (MeleeRange + Enemy.CollisionRadius + CollisionRadius))
			GotoState('MeleeAttack');
		else if ( bHasRangedAttack && (FRand() > 0.7 + 0.1 * skill) ) 
			GotoState('RangedAttack');
		else if ( bHasRangedAttack && !bMovingRangedAttack)
		{ 
			if ( FRand() < CombatStyle * 0.8 ) //then keep charging
				SetTimer(1.0,false); 
			else
				GotoState('Attacking');
		}
	}
	
	function EnemyNotVisible()
	{
		GotoState('Hunting'); 
	}

	function BeginState()
	{
		bCanFire = false;
		SpecialGoal = None;
		SpecialPause = 0.0;
	}

	function EndState()
	{
		if ( JumpZ > 0 )
			bCanJump = true;
	}

AdjustFromWall:
	StrafeTo(Destination, Focus); 
	Goto('CloseIn');

ResumeCharge:
	PlayRunning();
	Goto('Charge');

Begin:
	TweenToRunning(0.15);

Charge:
	bFromWall = false;
	
CloseIn:
	if ( (Enemy == None) || (Enemy.Health <=0) )
		GotoState('Attacking');

	if ( Enemy.Region.Zone.bWaterZone )
	{
		if (!bCanSwim)
			GotoState('TacticalMove', 'NoCharge');
	}
	else if (!bCanFly && !bCanWalk)
		GotoState('TacticalMove', 'NoCharge');

	if (Physics == PHYS_Falling)
	{
		DesiredRotation = Rotator(Enemy.Location - Location);
		Focus = Enemy.Location;
		Destination = Enemy.Location;
		WaitForLanding();
	}
	if( (Intelligence <= BRAINS_Reptile) || actorReachable(Enemy) )
	{
		bCanFire = true;
		if ( FRand() < 0.3 )
			PlayThreateningSound();
		MoveToward(Enemy);
		if (bFromWall)
		{
			bFromWall = false;
			if (PickWallAdjust())
			{
				if ( Physics == PHYS_Falling )
					SetFall();
				else
					StrafeFacing(Destination, Enemy);
			}
			else
				GotoState('TacticalMove', 'NoCharge');
		}
	}
	else
	{
NoReach:
		bCanFire = false;
		bFromWall = false;
		//log("route to enemy "$Enemy);
		if (!FindBestPathToward(Enemy))
		{
			Sleep(0.0);
			GotoState('TacticalMove', 'NoCharge');
		}
SpecialNavig:
		if ( SpecialPause > 0.0 )
		{
   Target = Enemy;
			bFiringPaused = true;
			NextState = 'Charging';
			NextLabel = 'Moving';
			GotoState('RangedAttack');
		}
Moving:
  if ( !IsAnimating() )
		AnimEnd();
  if ( Enemy == None )
		GotoState('Attacking');
		if (VSize(MoveTarget.Location - Location) < 2.5 * CollisionRadius)
		{
			bCanFire = true;
			StrafeFacing(MoveTarget.Location, Enemy);
		}
		else
		{
			if ( !bCanStrafe || !LineOfSightTo(Enemy) ||
				(Skill - 2 * FRand() + (Normal(Enemy.Location - Location - vect(0,0,1) * (Enemy.Location.Z - Location.Z)) 
					Dot Normal(MoveTarget.Location - Location - vect(0,0,1) * (MoveTarget.Location.Z - Location.Z))) < 0) )
			{
				if ( GetAnimGroup(AnimSequence) == 'MovingAttack' )
				{
					AnimSequence = '';
					TweenToRunning(0.12);
				}
				MoveToward(MoveTarget);
			}
			else
			{
				bCanFire = true;
				StrafeFacing(MoveTarget.Location, Enemy);	
			}
			if ( !bFromWall && (FRand() < 0.5) )
				PlayThreateningSound();
		}
	}
	//log("finished move");
	if (Enemy!=none && VSize(Location - Enemy.Location) < CollisionRadius + Enemy.CollisionRadius + MeleeRange)
		Goto('GotThere');
	if ( bIsPlayer || (!bFromWall && bHasRangedAttack && (FRand() > CombatStyle + 0.1)) )
		GotoState('Attacking');
	MoveTimer = 0.0;
	bFromWall = false;
	Goto('CloseIn');

GotThere:
	////log("Got to enemy");
 if ( (Enemy == None) || (Enemy.Health <=0) )
		GotoState('Attacking');
	Target = Enemy;
	GotoState('MeleeAttack');

TakeHit:
	TweenToRunning(0.12);
	if (MoveTarget == Enemy)
	{
		bCanFire = true;
		MoveToward(MoveTarget);
	}
	
	Goto('Charge');
}

state RangedAttack
{
ignores SeePlayer, HearNoise, Bump;

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
		if ( !bFiringPaused && ((FRand() > ReFireRate) || (Enemy == None) 
     || (Enemy.Health <= 0) || (Enemy.bDeleteMe) || !CanFireAtEnemy()) ) 
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
		Disable('AnimEnd');
		bReadyToAttack = false;
		if ( bFiringPaused )
		{
			SetTimer(SpecialPause, false);
			SpecialPause = 0;
		}
  else
  Target = Enemy;
	}
	
	function EndState()
	{
		bFiringPaused = false;
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
	if ( Target == None )
	{
  if ( Enemy != None )
		Target = Enemy;
		if ( Target == None )
			GotoState('Attacking');
	}
	Acceleration = vect(0,0,0); //stop
	DesiredRotation = Rotator(Target.Location - Location);
	TweenToFighter(0.15);
	
FaceTarget:
	Disable('AnimEnd');
	if (NeedToTurn(Target.Location))
	{
		PlayTurning();
		TurnToward(Target);
		TweenToFighter(0.1);
	}
	FinishAnim();

	if (VSize(Location - Target.Location) < 0.9 * MeleeRange + CollisionRadius + Target.CollisionRadius)
		GotoState('MeleeAttack', 'ReadyToAttack'); 

ReadyToAttack:
	if (!bHasRangedAttack || Target == None)
		GotoState('Attacking');
	DesiredRotation = Rotator(Target.Location - Location);
	PlayRangedAttack();
	Enable('AnimEnd');
Firing:
	if (Target == None )
		GotoState('Attacking');
	TurnToward(Target);
	Goto('Firing');
DoneFiring:
	Disable('AnimEnd');
	KeepAttacking();  
	Goto('FaceTarget');
}

state MeleeAttack
{
ignores SeePlayer, HearNoise, Bump;
/* DamageTarget
check if attack hit target, and if so damage it
*/
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		if (NextState == 'TakeHit')
		{
			NextState = 'MeleeAttack';
			NextLabel = 'Begin';
		}
	}

	function KeepAttacking()
	{
		if ( (Enemy == None) || (Enemy.Health <= 0) || enemy.bDeleteme
     || (VSize(Enemy.Location - Location) > (MeleeRange + Enemy.CollisionRadius + CollisionRadius)) )
			GotoState('Attacking');
	}

	function EnemyNotVisible()
	{
		//log("enemy not visible");
		GotoState('Attacking');
	}

	function AnimEnd()
	{
		GotoState('MeleeAttack', 'DoneAttacking');
	}

	function BeginState()
	{
		if  (Enemy != none && Enemy.Health > 0 && !Enemy.bDeleteme)
        Target = Enemy;
		    Disable('AnimEnd');
		    bReadyToAttack = false;
	}

Begin:
	if ( Enemy != None )
	DesiredRotation = Rotator(Enemy.Location - Location);
	if ( skill < 3 )
		TweenToFighter(0.15);
	else
		TweenToFighter(0.11);

FaceTarget:
	if ( Enemy == None )
			GotoState('Attacking');
	Acceleration = vect(0,0,0); //stop
	if (NeedToTurn(Enemy.Location))
	{
		PlayTurning();
		TurnToward(Enemy);
		TweenToFighter(0.1);
	}
	FinishAnim();
	OldAnimRate = 0;	// force no tween

	if ( (Physics == PHYS_Swimming) || (Physics == PHYS_Flying) )
	{
		 if ( VSize(Location - Enemy.Location) > MeleeRange + CollisionRadius + Enemy.CollisionRadius )
			GotoState('RangedAttack', 'ReadyToAttack');
	}
	else if ( (Abs(Location.Z - Enemy.Location.Z)
			> FMax(CollisionHeight, Enemy.CollisionHeight) + 0.5 * FMin(CollisionHeight, Enemy.CollisionHeight)) ||
		(VSize(Location - Enemy.Location) > MeleeRange + CollisionRadius + Enemy.CollisionRadius) )
		GotoState('RangedAttack', 'ReadyToAttack');

ReadyToAttack:
	DesiredRotation = Rotator(Enemy.Location - Location);
	PlayMeleeAttack();
	Enable('AnimEnd');
Attacking:
 if ( Enemy == None  || Enemy.Health <= 0 || Enemy.bDeleteme)
		GotoState('Attacking');
	TurnToward(Enemy);
	Goto('Attacking');
DoneAttacking:
	Disable('AnimEnd');
	KeepAttacking();
	if ( FRand() < 0.3 - 0.1 * skill )
	{
		Acceleration = vect(0,0,0); //stop
		DesiredRotation = Rotator(Enemy.Location - Location);
		PlayChallenge();
		FinishAnim();
		TweenToFighter(0.1);
	}
	Goto('FaceTarget');
}

State Patroling
{
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
  if ( (Enemy != None) && (Enemy == InstigatedBy) )
		LastSeenPos = Enemy.Location;
		if (NextState == 'TakeHit')
		{
			NextState = 'Attacking'; 
			NextLabel = 'Begin';
			GotoState('TakeHit'); 
		}
		else if ( Enemy != None )
			GotoState('Attacking');
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		if ( Wall.IsA('Mover') && Mover(Wall).HandleDoor(self) )
		{
			if ( SpecialPause > 0 )
				Acceleration = vect(0,0,0);
			GotoState('Patroling', 'SpecialNavig');
			return;
		}
		Focus = Destination;
		if (PickWallAdjust())
   {
   if ( Physics == PHYS_Falling )
				SetFall();
			else
			GotoState('Patroling', 'AdjustFromWall');
			}
		else
			MoveTimer = -1.0;
	}

 function Trigger( actor Other, pawn EventInstigator )
	{
		if ( EventInstigator!=none && bDelayedPatrol )
		{
			if ( bHateWhenTriggered )
			{
				if ( EventInstigator.bIsPlayer)
					AttitudeToPlayer = ATTITUDE_Hate;
				else
					Hated = EventInstigator;
			}
			GotoState('Patroling', 'Patrol');
		}
		else
			Global.Trigger(Other, EventInstigator);
	} 
}

state Threatening
{
ignores falling, landed;

	function Trigger( actor Other, pawn EventInstigator )
	{
		if (EventInstigator != none && EventInstigator.bIsPlayer)
		{
			Enemy = EventInstigator;
			AttitudeToPlayer = ATTITUDE_Hate;
			GotoState('Attacking');
		}
	} 
Begin:
	Acceleration = vect(0,0,0);
	bReadyToAttack = true;
	if (Enemy != none && Enemy.bIsPlayer)
		Disable('SeePlayer'); //but not hear noise
	TweenToPatrolStop(0.2);
	FinishAnim();
	NextAnim = '';
	
FaceEnemy:
 if (Enemy == none)
 GotoState('Attacking');
	Acceleration = vect(0,0,0);
	if (NeedToTurn(enemy.Location))
	{	
		PlayTurning();
		TurnToward(Enemy);
		TweenToPatrolStop(0.2);
		FinishAnim();
		NextAnim = '';
	}
}

state Guarding
{
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, name damageType)
	{
  if ( (Enemy != None) && (Enemy == InstigatedBy) )
		LastSeenPos = Enemy.Location;
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		if (NextState == 'TakeHit')
		{
			NextState = 'Attacking'; 
			NextLabel = 'Begin';
			GotoState('TakeHit'); 
		}
		else if ( Enemy != None )
			GotoState('Attacking');
	}
	
	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		if ( Wall.IsA('Mover') && Mover(Wall).HandleDoor(self) )
		{
			if ( SpecialPause > 0 )
				Acceleration = vect(0,0,0);
			GotoState('Guarding', 'SpecialNavig');
			return;
		}
		Focus = Destination;
		if (PickWallAdjust())
   {
   if ( Physics == PHYS_Falling )
				SetFall();
			else
			GotoState('Guarding', 'AdjustFromWall');
			}
		else
			MoveTimer = -1.0;
	}
}

state Retreating
{
ignores EnemyNotVisible; 

	function SeePlayer(Actor SeenPlayer)
	{
		if ( (SeenPlayer == Enemy) || LineOfSightTo(Enemy) )
		{
			LastSeenTime = Level.TimeSeconds;
			return;
		}
		if ( SetEnemy(Pawn(SeenPlayer)) )
		{
			MakeNoise(1.0);
			GotoState('Attacking');
		}
	}

	singular function HearNoise(float Loudness, Actor NoiseMaker)
	{
		if ( (NoiseMaker.instigator == Enemy) || LineOfSightTo(Enemy) )
			return;

		if ( SetEnemy(NoiseMaker.instigator) )
		{
			MakeNoise(1.0);
			GotoState('Attacking');
		}
	} 

 function HitWall(vector HitNormal, actor Wall)
	{
		bSpecialPausing = false;
		if (Physics == PHYS_Falling)
			return;
		if ( Wall.IsA('Mover') && Mover(Wall).HandleDoor(self) )
		{
			if ( SpecialPause > 0 )
				Acceleration = vect(0,0,0);
			GotoState('Retreating', 'SpecialNavig');
			return;
		}
		Focus = Destination;
		if (PickWallAdjust())
   {
   if ( Physics == PHYS_Falling )
				SetFall();
			else
			GotoState('Retreating', 'AdjustFromWall');
   }
		else
		{
			Home = None;
			MoveTimer = -1.0;
		}
	}

	function PickDestination()
	{
  local NavigationPoint Nav;
  local int zzi;
  local float dist;
  local vector Dir;

		if (Enemy == None) 
		{
			GotoState('Attacking');
			return;
		}         

		if( Level.NavigationPointList == None )
		{
  if ( Enemy != None )
   AttitudeTo(Enemy) == ATTITUDE_Hate;
			Aggressiveness += 0.3;
			GotoState( 'Attacking' );
   return;
		}  

  if (HomeBase(Home) == None)
     		{
  		   zzi=0;
       for ( Nav=Level.NavigationPointList; Nav!=None; Nav=Nav.NextNavigationPoint )
		     if ( Nav.IsA('NavigationPoint') && !Nav.IsA('LiftCenter')&& !Nav.IsA('LiftExit') && !Nav.IsA('Teleporter'))
            {
	     	      Dir = Nav.Location - Location;
		           dist = VSize(Dir);
             	if ( (dist < 2000) && (dist > 20) )
                   {
                    zzi++;
                    if ( (home == none) || (Rand(zzi) == 0) )
						               home = Nav;
			                }
            }
     			if (Home == none )
     			{
     				if (bReadyToAttack)
      				{
      					setTimer(3.0, false); 
           if (Enemy !=none )
        					Target = Enemy;
      					GotoState('RangedAttack');
				      }
   			  	else
   			  	{
   			  		Aggressiveness += 0.3;
  				   	GotoState('TacticalMove', 'NoCharge');
   				}
   			}  
   }
}

Begin:
	//log(class$" retreating");
 if (Enemy == None)
 GotoState('Attacking');
	if ( bReadyToAttack && (FRand() < 0.6) )
	{
		SetTimer(TimeBetweenAttacks, false);
		bReadyToAttack = false;
	}
	TweenToRunning(0.1);
	WaitForLanding();
	PickDestination();

Landed:
	TweenToRunning(0.1);
	
RunAway:
	PickNextSpot();
SpecialNavig:
	if (SpecialPause > 0.0)
	{
		if ( Enemy!=none && LineOfSightTo(Enemy))
		{
			bFiringPaused = true;
			NextState = 'Retreating';
			NextLabel = 'Moving';
			GotoState('RangedAttack');
		}
		bSpecialPausing = true;
		Acceleration = vect(0,0,0);
		TweenToPatrolStop(0.25);
		Sleep(SpecialPause);
		SpecialPause = 0.0;
		bSpecialPausing = false;
		TweenToRunning(0.1);
	}
Moving:
 if (Enemy == None)
 GotoState('Attacking');
	if ( MoveTarget == None )
	{
		Sleep(0.0);
		Goto('RunAway');
	}
	if ( !bCanStrafe || !LineOfSightTo(Enemy) ||
		(Skill - 2 * FRand() + (Normal(Enemy.Location - Location - vect(0,0,1) * (Enemy.Location.Z - Location.Z)) 
			Dot Normal(MoveTarget.Location - Location - vect(0,0,1) * (MoveTarget.Location.Z - Location.Z))) < 0) )
	{
		bCanFire = false;
		MoveToward(MoveTarget);
	}
	else
	{
		bCanFire = true;
		StrafeFacing(MoveTarget.Location, Enemy);
	}
	Goto('RunAway');

TakeHit:
	TweenToRunning(0.12);
	Goto('Moving');

AdjustFromWall:
	StrafeTo(Destination, Focus); 
	Destination = Focus; 
	MoveTo(Destination);
	Goto('Moving');

TurnAtHome:
	Acceleration = vect(0,0,0);
 if (HomeBase(Home) != None)
	TurnTo(Homebase(Home).lookdir);
	GotoState('Ambushing', 'FindAmbushSpot');
}

state Hunting
{
ignores EnemyNotVisible;

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		if ( Wall.IsA('Mover') && Mover(Wall).HandleDoor(self) )
		{
			if ( SpecialPause > 0 )
				Acceleration = vect(0,0,0);
			GotoState('Hunting', 'SpecialNavig');
			return;
		}
		Focus = Destination;
  if (PickWallAdjust())
   {
   if ( Physics == PHYS_Falling )
				SetFall();
			else
			GotoState('Hunting', 'AdjustFromWall');
			}
		else
			MoveTimer = -1.0;
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		bFrustrated = true;
		if (NextState == 'TakeHit')
		{
			if (AttitudeTo(Enemy) == ATTITUDE_Fear)
			{
				NextState = 'Retreating';
				NextLabel = 'Begin';
			}
			else
			{
				NextState = 'Hunting';
				NextLabel = 'AfterFall';
			}
			GotoState('TakeHit'); 
		}
	} 

 singular function HearNoise(float Loudness, Actor NoiseMaker)
	{
		if ( SetEnemy(NoiseMaker.instigator) )
			LastSeenPos = Enemy.Location; 
	}

AdjustFromWall:
	StrafeTo(Destination, Focus); 
	Destination = Focus; 
	if ( MoveTarget != None )
		Goto('SpecialNavig');
	else
		Goto('Follow');

Begin:
	numHuntPaths = 0;
	HuntStartTime = Level.TimeSeconds;

AfterFall:
	if (Enemy==none)
  GotoState('Attacking');
	TweenToRunning(0.15);
	bFromWall = false;

Follow:
	WaitForLanding();
	if ( CanSee(Enemy) )
		SetEnemy(Enemy);
	PickDestination();
SpecialNavig:
	if ( SpecialPause > 0.0 )
	{
		Disable('AnimEnd');
		Acceleration = vect(0,0,0);
		PlayChallenge();
		Sleep(SpecialPause);
		SpecialPause = 0.0;
		Enable('AnimEnd');
	}
	if (MoveTarget == None)
		MoveTo(Destination);
	else
		MoveToward(MoveTarget); 
	if ( Intelligence < BRAINS_Human )
	{
		if ( FRand() > 0.3 )
			PlayRoamingSound();
		else if ( FRand() > 0.3 )
			PlayThreateningSound();
	}
	if ( (Orders == 'Guarding') && !LineOfSightTo(OrderObject) )
		GotoState('Guarding'); 
	Goto('Follow');
}

state AlarmPaused
{
	ignores HearNoise;

 function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, name damageType)
	{
		local bool bWasFriendly;
		
		bWasFriendly = ( (Enemy != None) && Enemy.bIsPlayer && (AttitudeToPlayer == ATTITUDE_Friendly) );
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		if (NextState == 'TakeHit')
		{
			if ( bWasFriendly && (instigatedBy == Enemy) )
				AlarmTag = '';
			if ( AlarmTag == '' )
			{
				NextState = 'Attacking';
				NextLabel = 'Begin';
			}
			else
			{
				NextState = 'TriggerAlarm';
				NextLabel = 'Recover';
			}
			GotoState('TakeHit'); 
		}
	}

WaitForEnemy:
	Acceleration = vect(0,0,0);
	FinishAnim();
	TweenToPatrolStop(0.3);
	FinishAnim();
Waiting:
	PlayPatrolStop();
	FinishAnim();
	Goto('Waiting');
					
Begin:
if ( Enemy == none )
				{
    AlarmTag = '';
    GotoState('Attacking');
    }
	Acceleration = vect(0,0,0);
	Enable('Timer');
	SetTimer( AlarmPoint(OrderObject).pausetime, false );
	if ( bHasRangedAttack && AlarmPoint(OrderObject).bAttackWhilePaused )
	{
		Enable('EnemyNotVisible');
		if ( AlarmPoint(OrderObject).ShootTarget != '' )
			FindShootTarget();
		else
		{
			if ((Enemy != None) && Enemy.bIsPlayer && ( AttitudeToPlayer > ATTITUDE_Hate) )
			{
			AttitudeToPlayer = ATTITUDE_Hate;
			Target = Enemy;
			}
		}
		if ( AlarmPoint(OrderObject).AlarmAnim != '')
		{
			TweenAnim(AlarmPoint(OrderObject).AlarmAnim, 0.2);
			if (NeedToTurn(Target.Location))
				TurnToward(Target);
			FinishAnim();
			if ( AlarmPoint(OrderObject).AlarmSound != None)
				PlaySound( AlarmPoint(OrderObject).AlarmSound);
			PlayAnim(AlarmPoint(OrderObject).AlarmAnim);
			if ( AlarmPoint(OrderObject).ducktime > 0 )
			{
				if ( Target != Enemy )
					Sleep(AlarmPoint(OrderObject).ducktime);
				else
				{
					if ( TimerRate <= 0 )
						SetTimer( AlarmPoint(OrderObject).ducktime + 1, false);
					MoveTimer = TimerCounter;
					While ( TimerCounter < MoveTimer + AlarmPoint(OrderObject).ducktime )
					{
						TurnToward(Enemy);
						sleep(0.0);
					}
				}
			}
		}
Attack:
  if ( Target == None )
	 {
		Target = Enemy;
		if ( Target == None )
			{
   AlarmTag = '';
			GotoState('Attacking');
			}
	 }          
		if (NeedToTurn(Target.Location))
		{
			PlayTurning();
			TurnToward(Target);
		}
		TweenToFighter(0.15);
		FinishAnim();
		DesiredRotation = Rotator(Target.Location - Location);
		PlayRangedAttack();
		FinishAnim();
		Goto('Attack');
	}

	if ( AlarmPoint(OrderObject).bStopIfNoEnemy)
		Enable('EnemyNotVisible');
				
	if ( NeedToTurn(Location + AlarmPoint(OrderObject).lookdir) )
	{
		PlayTurning();
		TurnTo(Location + AlarmPoint(OrderObject).lookdir);
	}
	if ( AlarmPoint(OrderObject).AlarmAnim != '')
	{
		TweenAnim(AlarmPoint(OrderObject).AlarmAnim, 0.2);
		FinishAnim();
		PlayAnim(AlarmPoint(OrderObject).AlarmAnim);
	}
	else
	{
		TweenToPatrolStop(0.3);
		FinishAnim();
		PlayPatrolStop();
	}
	sleep( AlarmPoint(OrderObject).pausetime );
	Timer();
		
WaitForPlayer:
	Disable('AnimEnd');
	NextAnim = '';
	Acceleration = vect(0,0,0);
Wait:
 if ( Enemy == none )
				{
    AlarmTag = '';
    GotoState('Attacking');
    }
    
	if (NeedToTurn(Enemy.Location))
	{
		PlayTurning();
		TurnToward(Enemy);
	}
	TweenToWaiting(0.2);
	FinishAnim();
	PlayWaiting();
	FinishAnim();
	if ((Enemy!=none ) && (VSize(Location - Enemy.Location) > CollisionRadius + Enemy.CollisionRadius + 220) 
		|| ((Enemy!=none ) && !Enemy.LineOfSightTo(Self)) )
		Goto('Wait');
	TweenToRunning(0.15);
	GotoState('TriggerAlarm');
			
WaitAround:
	Disable('AnimEnd');
	Acceleration = vect(0,0,0);
	if ( (AlarmPoint(OrderObject) != None) && NeedToTurn(Location + AlarmPoint(OrderObject).lookdir) )
	{
		PlayTurning();
		TurnTo(Location + AlarmPoint(OrderObject).lookdir);
	}
	if ( (AlarmPoint(OrderObject) != None) && AlarmPoint(OrderObject).AlarmAnim != '')
	{
		TweenAnim(AlarmPoint(OrderObject).AlarmAnim, 0.2);
		FinishAnim();
		PlayAnim(AlarmPoint(OrderObject).AlarmAnim);
		FinishAnim();
	}
	else
	{
		TweenToPatrolStop(0.2);
		FinishAnim();
		if (NeedToTurn(Enemy.Location))
		{
			PlayTurning();
			TurnToward(Enemy);
			TweenToPatrolStop(0.2);
		}
		PlayWaitAround();
		FinishAnim();
		PlayWaitAround();
		FinishAnim();
		PlayWaitAround();
		FinishAnim();
		TweenToPatrolStop(0.1);
		FinishAnim();
	}
	if (AlarmTag == '')
		WhatToDoNext('','');
	else
		GotoState('TriggerAlarm');
}

state TriggerAlarm
{
	ignores HearNoise, SeePlayer;

	function Bump(actor Other)
	{
		if ( (Pawn(Other) != None) && Pawn(Other).bIsPlayer
			&& (AttitudeToPlayer == ATTITUDE_Friendly) )
			return;

		Super.Bump(Other);
	}

	function BeginState()
	{
		bCanFire = false;
		SpecialGoal = None;
		SpecialPause = 0.0;
		bSpecialPausing = false;
		if ( (Enemy!=none) && !Enemy.bIsPlayer 
			|| ((AttitudeToPlayer == ATTITUDE_Fear) 
				&& !bInitialFear && (Default.AttitudeToPlayer == ATTITUDE_Friendly)) )
		{
			GotoState('Attacking');
			return;
		}
	
		FindAlarm();
		
		if ( (TeamLeader != None) && !TeamLeader.bTeamSpeaking )
			TeamLeader.SpeakOrderTo(self);
	}
}

auto state StartUp
{
 ignores  SeePlayer, EnemyNotVisible, HearNoise, KilledBy, Trigger, Bump, HitWall, Falling, WarnTarget, Died, LongFall, PainTimer;

  function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, name damageType)
  {}
}

defaultproperties
{
      bCarc=False
}
