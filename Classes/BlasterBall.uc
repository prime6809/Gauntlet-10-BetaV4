//=============================================================================
// BlasterBall.
//=============================================================================
class BlasterBall expands Projectile;

var actor seeking;

replication
{
	// Relationships.
	reliable if( Role==ROLE_Authority )
		Seeking;
}

function PreBeginPlay()
{
	//local DiedPawnResizeMutator DPRM;
	Super.PreBeginPlay();
	
	/*
	foreach allactors(class'DiedPawnResizeMutator',DPRM)
	{
		return;
	}
	Level.Game.BaseMutator.AddMutator(spawn(class'DiedPawnResizeMutator'));
	*/
}

simulated function Timer()
{
	local vector SeekingDir;
	local float MagnitudeVel;

	ScaleGlow=LifeSpan;

	If (Seeking != None  && Seeking != Instigator) 
	{
		SeekingDir = Normal(Seeking.Location - Location);
	//	if ( (SeekingDir Dot InitialDir) > 0 )
	//	{
			MagnitudeVel = VSize(Velocity);
			Velocity =  0.99*MagnitudeVel * Normal(SeekingDir * 0.5 * MagnitudeVel + Velocity);		
			SetRotation(rotator(Velocity));
	//	}
	}
}

auto state Flying
{
	simulated function BeginState()
	{	
		local float bestDist, bestAim;

		SetTimer(0.05,True);
		Velocity = vector(Rotation) * speed;

		bestAim = 0.8;//0.93
		seeking = instigator.PickTarget(bestAim, bestDist, Normal(Velocity), Location);
	}

	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		local vector HitNormal;
		if ((Other != instigator) && (BlasterBall(Other) == none)) 
		{
			Other.TakeDamage(damage*0.5, instigator,HitLocation,
				(MomentumTransfer * Normal(Velocity)), 'jolted');
			HitNormal=Normal(HitLocation-Other.Location);
			PlaySound(ImpactSound,SLOT_None,1.0,,,2.0);
			if ( Role == ROLE_Authority )
			{
				HurtRadius(Damage, 50, 'jolted', MomentumTransfer, Location );
				Spawn(class'RingExplosion3',,, HitLocation+HitNormal*8,rotator(HitNormal));
			}
			GoToState('Fade');
		}
	}
	simulated function HitWall (vector HitNormal, actor Wall)
	{
		PlaySound(ImpactSound,SLOT_None,1.0,,,2.0);
		if ( Role == ROLE_Authority )
		{
			HurtRadius(Damage, 50, 'jolted', MomentumTransfer, Location );
			Spawn(class'RingExplosion3',,, Location,rotator(HitNormal));
		}
		GoToState('Fade');
	}
}

state Fade
{
ignores Explode,ProcessTouch,HitWall;
	simulated function tick(float DeltaTime)
	{
		LightBrightness-=(400*DeltaTime);
		DrawScale+=DeltaTime;
	}
Begin:
	SetPhysics(PHYS_None);
	lifespan=0.4;
	sleep(0.35);
	Destroy();
}

defaultproperties
{
      Seeking=None
      speed=2000.000000
      Damage=20.000000
      MomentumTransfer=2000
      ImpactSound=Sound'UnrealShare.General.SpecialExpl'
      bAlwaysRelevant=True
      bNetTemporary=False
      RemoteRole=ROLE_SimulatedProxy
      LifeSpan=6.000000
      DrawType=DT_Sprite
      Style=STY_Translucent
      Texture=Texture'Gauntlet-10-BetaV4.BFG.afireball_A00'
      DrawScale=0.100000
      AmbientGlow=255
      CollisionRadius=5.000000
      CollisionHeight=5.000000
      LightType=LT_Steady
      LightEffect=LE_NonIncidence
      LightBrightness=255
      LightHue=12
      LightSaturation=12
      LightRadius=16
}
