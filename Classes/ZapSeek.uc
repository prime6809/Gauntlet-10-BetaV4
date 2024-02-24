//=============================================================================
// ZapSeek.
//=============================================================================
class ZapSeek extends projectile;

var actor seeking;
var() float bestTrack,spread;

var() texture SpriteAnim[5];
var int SpriteFrame;
var ZapSeek PlasmaBeam;
var PlasmaCap WallEffect;
var int Position;
var vector FireOffset;
var float BeamSize;
var bool bRight, bCenter;
var float AccumulatedDamage, LastHitTime, lastEB;
var Actor DamagedActor;

var bool bUpdated;

replication
{
	// Things the server should send to the client.
	unreliable if( Role==ROLE_Authority )
		bRight, bCenter;
	reliable if( Role==ROLE_Authority )
		seeking;
}

simulated function PostBeginPlay()
{
	SetTimer(0.2, true);
	bUpdated = true;
}
simulated function timer()
{
	if(!bUpdated) Destroy();
	bUpdated = false;
}
simulated function Destroyed()
{
	Super.Destroyed();
	if ( PlasmaBeam != None )
		PlasmaBeam.Destroy();
	if ( WallEffect != None )
		WallEffect.Destroy();
}

simulated function CheckBeam(vector X, float DeltaTime)
{
	local actor HitActor;
	local vector HitLocation, HitNormal;

	// check to see if hits something, else spawn or orient child

	HitActor = Trace(HitLocation, HitNormal, Location + BeamSize * X, Location, true);
	if ( (HitActor != None)	/*&& (HitActor != Instigator)*/
		&& (HitActor.bProjTarget || (HitActor == Level) || (HitActor.bBlockActors && HitActor.bBlockPlayers)) 
		&& ((Pawn(HitActor) == None) || Pawn(HitActor).AdjustHitLocation(HitLocation, Velocity)) )
	{
		if ( Level.Netmode != NM_Client )
		{
			if ( DamagedActor == None )
			{
				AccumulatedDamage = FMin(0.5 * (Level.TimeSeconds - LastHitTime), 0.1);
				HitActor.TakeDamage(damage * AccumulatedDamage, instigator,HitLocation,
					(MomentumTransfer * X * AccumulatedDamage), MyDamageType);
				AccumulatedDamage = 0;
			}				
			else if ( DamagedActor != HitActor )
			{
				DamagedActor.TakeDamage(damage * AccumulatedDamage, instigator,HitLocation,
					(MomentumTransfer * X * AccumulatedDamage), MyDamageType);
				AccumulatedDamage = 0;
			}				
			LastHitTime = Level.TimeSeconds;
			DamagedActor = HitActor;
			AccumulatedDamage += DeltaTime;
			if ( AccumulatedDamage > 0.22 )
			{
				if ( DamagedActor.IsA('Carcass') && (FRand() < 0.09) )
					AccumulatedDamage = 35/damage;
				DamagedActor.TakeDamage(damage * AccumulatedDamage, instigator,HitLocation,
					(MomentumTransfer * X * AccumulatedDamage), MyDamageType);
				AccumulatedDamage = 0;
			}
		}


		if (Level.NetMode != NM_DedicatedServer)
		{
			lastEB+=DeltaTime;
			if(lastEB > 0.10) {lastEB=0;spawn(class'EnergyBurst',,,HitLocation);}
			Spawn(ExplosionDecal,,,HitLocation,rotator(HitNormal));
		}

		if ( PlasmaBeam != None )
		{
			AccumulatedDamage += PlasmaBeam.AccumulatedDamage;
			PlasmaBeam.Destroy();
			PlasmaBeam = None;
		}

		return;
	}
	else if ( (Level.Netmode != NM_Client) && (DamagedActor != None) )
	{
		DamagedActor.TakeDamage(damage * AccumulatedDamage, instigator, DamagedActor.Location - X * 1.2 * DamagedActor.CollisionRadius,
			(MomentumTransfer * X * AccumulatedDamage), MyDamageType);
		AccumulatedDamage = 0;
		DamagedActor = None;
	}			


	if ( Position >= 9 )
	{	
	}
	else
	{
		if ( WallEffect != None )
		{
			WallEffect.Destroy();
			WallEffect = None;
		}
		if ( PlasmaBeam == None)
		{
			PlasmaBeam = Spawn(class'ZapSeek',,, Location + BeamSize * X); 
			PlasmaBeam.Position = Position + 1;
				PlasmaBeam.seeking = seeking;
				PlasmaBeam.damage=damage;
				PlasmaBeam.bestTrack=bestTrack;
				PlasmaBeam.beamsize=beamsize;
				PlasmaBeam.drawscale=drawscale;
		}
		else
			PlasmaBeam.UpdateBeam(self, X, DeltaTime);
	}
}

simulated function UpdateBeam(ZapSeek ParentBolt, vector Dir, float DeltaTime)
{
//	local actor HitActor;
	local vector V, NewDir;

	bUpdated = true;

	SpriteFrame = ParentBolt.SpriteFrame;
	Skin = SpriteAnim[SpriteFrame];
	SetLocation(ParentBolt.Location + BeamSize * Dir);

		seeking = ParentBolt.seeking;
		damage = ParentBolt.damage;
		bestTrack = ParentBolt.bestTrack;
		beamsize = ParentBolt.beamsize;
		drawscale = ParentBolt.drawscale;

	NewDir=Dir;
	NewDir.X+=(spread*(0.5-frand()));
	NewDir.Y+=(spread*(0.5-frand()));
	NewDir.Z+=(spread*(0.5-frand()));
	NewDir=Normal(NewDir);
	if(seeking!=none)
	{
		V=seeking.location-location;
		NewDir += (Normal(V)*bestTrack*frand());
		NewDir=Normal(NewDir);
	}
	SetRotation(Rotator(NewDir));
	CheckBeam(NewDir, DeltaTime);
}

defaultproperties
{
      Seeking=None
      bestTrack=1.000000
      Spread=0.300000
      SpriteAnim(0)=None
      SpriteAnim(1)=None
      SpriteAnim(2)=None
      SpriteAnim(3)=None
      SpriteAnim(4)=None
      SpriteFrame=0
      PlasmaBeam=None
      WallEffect=None
      Position=0
      FireOffset=(X=35.000000,Y=-7.500000,Z=-5.000000)
      BeamSize=81.000000
      bRight=True
      bCenter=False
      AccumulatedDamage=0.000000
      LastHitTime=0.000000
      lastEB=0.000000
      DamagedActor=None
      bUpdated=False
      MaxSpeed=0.000000
      Damage=100.000000
      MomentumTransfer=8500
      MyDamageType="zapped"
      ExplosionDecal=Class'Botpack.BoltScorch'
      bNetTemporary=False
      Physics=PHYS_None
      RemoteRole=ROLE_None
      LifeSpan=1.250000
      AmbientSound=Sound'Gauntlet-10-BetaV4.zapper.zapping'
      Style=STY_Translucent
      Texture=Texture'Gauntlet-10-BetaV4.Skins.bluepbolt0'
      Skin=Texture'Gauntlet-10-BetaV4.Skins.bluepbolt0'
      Mesh=LodMesh'Botpack.PBolt'
      bUnlit=True
      SoundRadius=12
      SoundVolume=255
      bCollideActors=False
      bCollideWorld=False
}
