//=============================================================================
// gateMaiden.
//=============================================================================
class gateMaiden expands maiden
config(GauntletScoreing);

// Here are some variable gauntlet will be using to handle scoring
var(U4eGauntlet) globalconfig int Value;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( skill < 3)
		skill = 3;
	ani = 0;
}

function PreSetMovement()
{
	bCanJump = true;
	bCanWalk = true;
	bCanSwim = true;
	bCanStrafe = true;
	bCanFly = false;
	if (Intelligence > BRAINS_Reptile)
		bCanOpenDoors = true;
	if (Intelligence == BRAINS_Human)
		bCanDoSpecial = true;
}    

function Died(pawn Killer, name damageType, vector HitLocation)
{
	local pawn OtherPawn;
	local actor A;
	local EGGS eg;

	u4egauntlet(level.game).MonsterKilled(Value,Killer,self);

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

	if (bEgglayer)
		{
			eg = spawn(class'gateEggs');
			if (eg!=none)
				{
					eg.bUseHatchTimer=true;
					eg.SetPhysics(PHYS_Falling);
				}
		}

	PlayDying(DamageType, HitLocation);

	if ( Level.Game.bGameEnded )
		return;
	if ( RemoteRole == ROLE_AutonomousProxy )
		ClientDying(DamageType, HitLocation);

	GotoState('Dying');
}

function SpawnShot()
{
	local rotator FireRotation;
	local vector X,Y,Z, projStart;
	
 local EggProj eg;
  
	GetAxes( Rotation, X, Y, Z );
	MakeNoise( 1.0 );
	projStart = Location + 1.1 * CollisionRadius * X + 0.4 * CollisionHeight * Z;
	FireRotation = AdjustToss( ProjectileSpeed, projStart, 200, bLeadTarget, bWarnTarget );

	if(bEgglayer)
	{
  if ( ani < HowManyEggs && FRand() > 0.5)
  	{
    eg=spawn( class'GateEggProj',,'', projStart, FireRotation );
  		ani++;				
  	}
  else
   spawn( RangedProjectile, self,'', projStart, FireRotation );
	}
	else
 spawn( RangedProjectile, self,'', projStart, FireRotation );
}

defaultproperties
{
      Value=22
      NameArticle="a "
}
