//=============================================================================
// ZapperSeg.
//=============================================================================
class ZapperSeg extends projectile;

var() texture SpriteAnim[5];
var int SpriteFrame;
var ZapperSeg PlasmaBeam;
var PlasmaCap WallEffect;
var int Position;
var vector FireOffset;
var float BeamSize;
var bool bRight, bCenter;
var float AccumulatedDamage, LastHitTime, lastEB;
var Actor DamagedActor;

replication
{
	// Things the server should send to the client.
	unreliable if( Role==ROLE_Authority )
		bRight, bCenter;
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
	if ( (HitActor != None)	&& (HitActor != Instigator)
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
		if ( PlasmaBeam == None )
		{
			PlasmaBeam = Spawn(class'ZapperSeg',,, Location + BeamSize * X); 
			PlasmaBeam.Position = Position + 1;
		}
		else
			PlasmaBeam.UpdateBeam(self, X, DeltaTime);
	}
}

simulated function UpdateBeam(ZapperSeg ParentBolt, vector Dir, float DeltaTime)
{
//	local actor HitActor;
	local vector HitNormal; 	//HitLocation,

	SpriteFrame = ParentBolt.SpriteFrame;
	Skin = SpriteAnim[SpriteFrame];
	SetLocation(ParentBolt.Location + BeamSize * Dir);

HitNormal=Dir;
HitNormal.X+=(0.3*(0.5-frand()));
HitNormal.Y+=(0.3*(0.5-frand()));
HitNormal.Z+=(0.3*(0.5-frand()));
HitNormal=Normal(HitNormal);

	SetRotation(Rotator(HitNormal));
	CheckBeam(HitNormal, DeltaTime);
}

defaultproperties
{
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
      BeamSize=162.000000
      bRight=True
      bCenter=False
      AccumulatedDamage=0.000000
      LastHitTime=0.000000
      lastEB=0.000000
      DamagedActor=None
      MaxSpeed=0.000000
      Damage=100.000000
      MomentumTransfer=8500
      MyDamageType="zapped"
      ExplosionDecal=Class'Botpack.BoltScorch'
      bNetTemporary=False
      Physics=PHYS_None
      RemoteRole=ROLE_None
      LifeSpan=1.000000
      AmbientSound=Sound'Gauntlet-10-BetaV4.zapper.zapping'
      Style=STY_Translucent
      Texture=Texture'Gauntlet-10-BetaV4.Skins.bluepbolt0'
      Skin=Texture'Gauntlet-10-BetaV4.Skins.bluepbolt0'
      Mesh=LodMesh'Botpack.PBolt'
      DrawScale=2.000000
      bUnlit=True
      SoundRadius=12
      SoundVolume=255
      bCollideActors=False
      bCollideWorld=False
}
