//=============================================================================
// TOMShell.
//=============================================================================
class TOMShell extends WarShell;

var	rockettrail rtrail;

simulated function Timer()
{
	local ut_SpriteSmokePuff b;

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
      speed=1000.000000
      MaxSpeed=1000.000000
      Damage=200.000000
      MomentumTransfer=10000
      MyDamageType="TomahawkDeath"
      DrawScale=0.500000
      SoundRadius=50
      SoundVolume=128
}
