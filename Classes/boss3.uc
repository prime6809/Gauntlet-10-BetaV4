class boss3 expands queen
config(GauntletScoreing);

// Here are some variable gauntlet will be using to handle scoring
var(U4eGauntlet) globalconfig int Value;

// Were going to let the game handle scoring!
function Died(pawn Killer, name damageType, vector HitLocation)
{
	u4egauntlet(level.game).MonsterKilled(Value,Killer,self);
	super.Died(Killer, damageType, HitLocation);
}

state dying
{
        function beginstate()
        {
                u4egauntlet(level.game).bosskilled();
                super.beginstate();
        }
}


function bool SetEnemy( Pawn NewEnemy )
{
	local bool result;
	local eAttitude newAttitude, oldAttitude;
	local float newStrength;
	
	if((PlayerPawn(NewEnemy)!=None) || (ScriptedPawn(NewEnemy)!=None))  // Let ScriptedPawn handle normal SetEnemy
		return Super.SetEnemy(NewEnemy);

	// ScriptedPawn won't handle anything not derived from PlayerPawn or ScriptedPawn
	if((Bot(NewEnemy)==None && Bots(NewEnemy)==None))
		return false;

	result = false;
	newAttitude = AttitudeTo(NewEnemy);

	if ( Enemy != None )
	{
		if (Enemy == NewEnemy)
			return true;
		else if ( NewEnemy.bIsPlayer && (AlarmTag != '') )
		{
			OldEnemy = Enemy;
			Enemy = NewEnemy;
			result = true;
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
					result = true;
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
					newStrength = relativeStrength(NewEnemy);
					if ( (newStrength < 0.2) && (relativeStrength(Enemy) < FMin(0, newStrength))  
						&& (IsInState('Hunting')) && (Level.TimeSeconds - HuntStartTime < 5) )
						result = false;
					else
					{
						result = true;
						OldEnemy = Enemy;
						Enemy = NewEnemy;
					}
				} 
				else
				{
					result = true;
					OldEnemy = Enemy;
					Enemy = NewEnemy;
				}
			}
		}
	}
	else if ( newAttitude < ATTITUDE_Ignore )
	{
		result = true;
		Enemy = NewEnemy;
	}
	else if ( newAttitude == ATTITUDE_Friendly ) //your enemy is my enemy
	{
		//log("noticed a friend");
		if ( NewEnemy.bIsPlayer && (AlarmTag != '') )
		{
			Enemy = NewEnemy;
			result = true;
		} 
		if (bIgnoreFriends)
			return false;

		if ( (NewEnemy.Enemy != None) && (NewEnemy.Enemy.Health > 0) ) 
		{
			result = true;
			//log("his enemy is my enemy");
			Enemy = NewEnemy.Enemy;
			if (Enemy.bIsPlayer)
				AttitudeToPlayer = ScriptedPawn(NewEnemy).AttitudeToPlayer;
			else if ( (ScriptedPawn(NewEnemy) != None) && (ScriptedPawn(NewEnemy).Hated == Enemy) )
				Hated = Enemy;
		}
	}

	if ( result )
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
				
	return result;		
}

function eAttitude AttitudeToCreature(Pawn Other)
{
	return ATTITUDE_Hate;
/*	if ( Other.IsA('Pupae') )
		return ATTITUDE_Friendly;
	else if ( Other.IsA('Skaarj') )
	{
		if ( Other.IsA('SkaarjBerserker') )
			return ATTITUDE_Ignore;
		else
			return ATTITUDE_Friendly;
	}
	else if ( Other.IsA('WarLord') || Other.IsA('Queen') )
		return ATTITUDE_Friendly;
	else if ( Other.IsA('ScriptedPawn') )
		return ATTITUDE_Hate;
*/
}

state TacticalMove
{
ignores SeePlayer, HearNoise;

	function PickDestination(bool bNoCharge)
	{
			Super.PickDestination(bNoCharge);
	}
}		

state Hunting
{
ignores EnemyNotVisible; 

	function PickDestination()
	{
	}
}
function tick(float deltatime)
{
        if(health<default.health)
                health+=deltatime;
        super.tick(deltatime);
}
function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
{
super.takedamage(damage,eventinstigator,hitlocation,momentum,damagetype);
health+=1; //to make us immune to flashbombrifle
}

defaultproperties
{
      Value=100
      ClawDamage=60
      RefireRate=0.300000
      MeleeRange=120.000000
      GroundSpeed=700.000000
      AccelRate=1800.000000
      JumpZ=1000.000000
      SightRadius=3500.000000
      Health=3200
      MenuName="Queen"
      NameArticle="the "
      DrawScale=0.500000
      CollisionRadius=45.046463
      CollisionHeight=51.446465
      Mass=500.000000
}
