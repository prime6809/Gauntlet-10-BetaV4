//=============================================================================
// Teradex Maiden for RTNP2U - Asgard
//   http://ammo.at/napali  http://www.angelfire.com/empire/napali/
//=============================================================================

class Maiden extends Spinner;


//#exec texture IMPORT NAME=JSpinnerb1 FILE=models\Spiderb1.PCX GROUP=Skins FLAGS=2 
//#exec texture IMPORT NAME=JSpinnerb2 FILE=models\Spiderb2.PCX GROUP=Skins PALETTE=JSpinnerb1 

var() bool bEgglayer;
var() int  HowManyEggs;
var int ani; 

function PostBeginPlay()
{
 Super.PostBeginPlay();
 if ( skill < 3)
  skill = 3;
 ani=0;
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
 local eggs eg;

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
 	eg = spawn(class'eggs');
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
    eg=spawn( class'EggProj',,'', projStart, FireRotation );
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
      bEgglayer=True
      HowManyEggs=7
      ani=0
      BiteDamage=75
      pitchmod=0.500000
      TimeBetweenAttacks=0.500000
      Aggressiveness=10.000000
      RangedProjectile=Class'Gauntlet-10-BetaV4.SpinnerProjectile2'
      ProjectileSpeed=1400.000000
      MeleeRange=90.000000
      GroundSpeed=550.000000
      AccelRate=900.000000
      JumpZ=600.000000
      SightRadius=4000.000000
      PeripheralVision=-2.000000
      HearingThreshold=0.100000
      Health=700
      ReducedDamageType="'"
      ReducedDamagePct=0.500000
      Intelligence=BRAINS_HUMAN
      CombatStyle=1.000000
      MenuName="Teradex Maiden"
      Skin=Texture'Gauntlet-10-BetaV4.Skins.JSpinnerb1'
      DrawScale=2.000000
      MultiSkins(1)=Texture'Gauntlet-10-BetaV4.Skins.JSpinnerb2'
      MultiSkins(2)=Texture'Gauntlet-10-BetaV4.Skins.JSpinnerb1'
      CollisionHeight=44.000000
      Mass=510.000000
      Buoyancy=570.000000
      RotationRate=(Pitch=4096,Yaw=100000,Roll=3072)
}
