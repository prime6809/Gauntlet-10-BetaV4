//=============================================================================
// TOMSeekShell.
//=============================================================================
class TOMSeekShell extends WarShell;

var	rockettrail rtrail;
var Actor Seeking;
var vector InitialDir;

replication
{
	// Relationships.
	reliable if( Role==ROLE_Authority )
		Seeking, InitialDir;
}

function PreBeginPlay()
{
	Super.PreBeginPlay();
}

simulated function Timer()
{
	local ut_SpriteSmokePuff b;
	local vector SeekingDir;
	local float MagnitudeVel;

	if ( InitialDir == vect(0,0,0) )
		InitialDir = Normal(Velocity);
		 
	if ( (Seeking != None) && (Seeking != Instigator) ) 
	{
		SeekingDir = Normal(Seeking.Location - Location);
		if ( (SeekingDir Dot InitialDir) > 0 )
		{
			MagnitudeVel = VSize(Velocity);
			SeekingDir = Normal(SeekingDir * 0.5 * MagnitudeVel + Velocity);
			Velocity =  MagnitudeVel * SeekingDir;	
			Acceleration = 25 * SeekingDir;	
			SetRotation(rotator(Velocity));
		}
	}

	if ( rTrail == None )
		rTrail = Spawn(class'RocketTrail',self);

	CannonTimer += SmokeRate;
	if ( CannonTimer > 0.6 )
	{
		WarnCannons();
		CannonTimer -= 0.6;
	}

	if ( Region.Zone.bWaterZone || (Level.NetMode == NM_DedicatedServer) )
	{
		SetTimer(SmokeRate, false);
		Return;
	}

	if ( Level.bHighDetailMode )
	{
		if ( Level.bDropDetail )
			Spawn(class'LightSmokeTrail');
		else
			Spawn(class'UTSmokeTrail');
		SmokeRate = 152/Speed; 
	}
	else 
	{
		SmokeRate = 0.15;
		b = Spawn(class'ut_SpriteSmokePuff');
		b.RemoteRole = ROLE_None;
	}
	SetTimer(SmokeRate, false);
}

simulated function Destroyed()
{
	if ( rTrail != None )
		rTrail.Destroy();
	Super.Destroyed();
}
auto state Flying
{
	function BeginState()
	{	
		local float bestDist, bestAim;

		local vector InitialDir;

		initialDir = vector(Rotation);
		if ( Role == ROLE_Authority )	
			Velocity = speed*initialDir;
		Acceleration = initialDir*50;

		bestAim = 0.8;//0.93
		seeking = instigator.PickTarget(bestAim, bestDist, Normal(Velocity), Location);
	}

	function Explode(vector HitLocation, vector HitNormal)
	{
		if ( Role < ROLE_Authority )
			return;

		HurtRadius(Damage,300.0, MyDamageType, MomentumTransfer, HitLocation );	 		 		
 		spawn(class'TOMShockWave',,,HitLocation+ HitNormal*16);	
		RemoteRole = ROLE_SimulatedProxy;	 		 		
 		Destroy();
	}
}

defaultproperties
{
      rtrail=None
      Seeking=None
      InitialDir=(X=0.000000,Y=0.000000,Z=0.000000)
      speed=1000.000000
      MaxSpeed=1000.000000
      Damage=200.000000
      MomentumTransfer=10000
      MyDamageType="TomahawkDeath"
      DrawScale=0.500000
      SoundRadius=50
      SoundVolume=128
}
