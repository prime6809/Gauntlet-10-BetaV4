//=============================================================================
// FreezerProjectile.
//=============================================================================
class FreezerProjectile expands Projectile;

var int NumWallHits;
var bool bCanHitInstigator, bHitWater;
var int CurPitch,PitchStart,YawStart,CurYaw;
var rotator CurRotation;
var float rollme;

simulated function BeginPlay(){
	Super.BeginPlay();
	bCanHitInstigator=false;
}
/////////////////////////////////////////////////////
auto state Flying
{
	simulated function ProcessTouch( Actor Other, Vector HitLocation )
	{
		local int hitdamage;
		local vector hitDir;
		local FreezedPawn fp;
		
		if(pawn(Other)!= None)
	if ( pawn(other).bIsPlayer )
	{
		hitDamage = Level.Game.ReduceDamage(damage, 'freezed', pawn(other), instigator);
		if (pawn(other).ReducedDamageType == 'All') //God mode
			hitDamage = 0;
		else if (other.Inventory != None) //then check if carrying armor
			hitDamage = other.Inventory.ReduceDamage(hitDamage, 'freezed', HitLocation);
		else
			hitDamage = damage;
		damage=hitdamage;	
	}
		
		if ((bCanHitInstigator)/*||(!Pawn(Other).bIsPlayer)*/||(other!=instigator))
		if (FreezerProjectile(Other) == none)
		{
			hitDir = Normal(Velocity);
			if ( FRand() < 0.2 )
				hitDir *= 5;
			// Fix so only players or monsters or bots can get frozen.
			if ( (PlayerPawn(other) != none || ScriptedPawn(other) != none || Bot(other) != none) && 
			( Pawn(Other).health <= (damage+5) ) )
				{
					fp=spawn(class'FreezedPawn',,,,Owner.rotation);
					fp.mesh=Other.mesh;
					fp.animsequence=Other.animsequence;
					if(Pawn(Other).bIsPlayer)
						freezeplayer(Pawn(Other));
					else
						if(Pawn(Other)!=None)
							KilledSomePawn(Pawn(Other),Instigator,'freezed',hitDir);	
						else
							Other.Destroy();
						SpawnEffects();
						Destroy();			
				}
			else
				{
				Other.TakeDamage(damage, instigator,HitLocation,
				(MomentumTransfer * hitDir), 'freezed');
				SpawnEffects();
				GotoState('HitPawn');
			}	
		}
	}

	simulated function ZoneChange( Zoneinfo NewZone )
	{
		local Splash w;
		
		if (!NewZone.bWaterZone || bHitWater) Return;

		bHitWater = True;
		w = Spawn(class'Splash',,,,rot(16384,0,0));
		w.DrawScale = 0.5;
		w.RemoteRole = ROLE_None;
		Velocity=0.6*Velocity;
	}

	simulated function tick(float dt)
	{
		local rotator newRot;	
		rollme += 65000*dt;
		newRot = Rotation;	
		newRot.roll = rollme;
		SetRotation(newRot);	
	}
	simulated function SetRoll(vector NewVelocity) 
	{
		local rotator newRot;	
	
		newRot = rotator(NewVelocity);	
		newRot.roll = rollme;
		SetRotation(newRot);	
	}

	simulated function HitWall (vector HitNormal, actor Wall)
	{
		
		bCanHitInstigator = true;
		if ( (RemoteRole == ROLE_DumbProxy) || (Level.Netmode != NM_DedicatedServer) )
			PlaySound(ImpactSound, SLOT_Misc, 2.0);
		if ( (Mover(Wall) != None) && Mover(Wall).bDamageTriggered )
		{
			if ( Role == ROLE_Authority )
				Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), '');
			Destroy();
			return;
		}
			NumWallHits++;
			SetTimer(0, False);
			MakeNoise(0.3);
			if ( NumWallHits > 3 )
				{SpawnEffects();Destroy();}
		Velocity -= 2 * ( Velocity dot HitNormal) * HitNormal;  
		SetRoll(Velocity);
	}

	simulated function BeginState()
	{
		local vector X;

		X = vector(Rotation);	
		Velocity = Speed * X;     // Impart ONLY forward vel
		PlaySound(SpawnSound, SLOT_None,4.2);
		if ( Level.NetMode == NM_Standalone )
			SoundPitch = 200 + 50 * FRand();			

		if (Instigator.HeadRegion.Zone.bWaterZone)
			bHitWater = True;	
		//Spawn(class'ChildEffect',self);	
	}

Begin:
	Sleep(0.2);
	bCanHitInstigator = true;
}

simulated function SpawnEffects()
{
	local actor a;

	 PlaySound(Sound'Expl03',,6.0);
	 a = Spawn(class'EffectLight');
	 a.RemoteRole = ROLE_None;
	 a = Spawn(class'ParticleBurst2');
	 a.RemoteRole = ROLE_None;	 
}

function freezeplayer(Pawn Victim)
{
	local Vector EndFlashFog;
	EndFlashFog.X=100;	EndFlashFog.Y=100;	EndFlashFog.Z=100;
			Victim.level.game.Killed(Instigator, Victim, 'freezed');
			Victim.HidePlayer();
			Victim.Level.Game.DiscardInventory(Victim);
			Victim.Health = -1;
	//		Victim.Score -= 1;
			Victim.GotoState('Dying');
	if(PlayerPawn(Victim)!=None) PlayerPawn(Victim).ClientFlash( 4, 100 * EndFlashFog );
}

function KilledSomePawn(pawn Victim,pawn Killer, name damageType, vector HitLocation)
{
	local pawn OtherPawn;
	local actor A;

	if ( victim.bDeleteMe )
		return; //already destroyed
	OtherPawn = Level.PawnList;
	while ( OtherPawn != None )
	{
		OtherPawn.Killed(Killer, Victim, damageType);
		OtherPawn = OtherPawn.nextPawn;
	}
	if ( victim.CarriedDecoration != None )
		victim.DropDecoration();
	level.game.Killed(Killer, victim, damageType);
	//log(class$" dying");
	if( victim.Event != '' )
		foreach AllActors( class 'Actor', A, victim.Event )
			A.Trigger( victim, Killer );
	Level.Game.DiscardInventory(victim);
	victim.Destroy();
}

state HitPawn
{
	simulated function tick(float deltatime)
	{
		AmbientGlow=1;
		ScaleGlow -= deltatime*4;
		drawscale += 4.5*deltatime;
		if (drawscale>=1.5) destroy();
	}
Begin:
SetPhysics(PHYS_None);	
}

defaultproperties
{
      NumWallHits=0
      bCanHitInstigator=False
      bHitWater=False
      CurPitch=0
      PitchStart=0
      YawStart=0
      CurYaw=0
      CurRotation=(Pitch=0,Yaw=0,Roll=0)
      rollme=0.000000
      speed=2000.000000
      Damage=15.000000
      MomentumTransfer=500
      SpawnSound=Sound'UnrealShare.Dispersion.DispShot'
      MiscSound=Sound'UnrealShare.Stinger.Ricochet'
      RemoteRole=ROLE_SimulatedProxy
      Style=STY_Translucent
      Texture=Texture'Gauntlet-10-BetaV4.Skins.flareblue1'
      Skin=Texture'Gauntlet-10-BetaV4.Skins.flareblue1'
      Mesh=Mesh'Gauntlet-10-BetaV4.MzFlX'
      DrawScale=0.750000
      AmbientGlow=167
      bUnlit=True
      CollisionRadius=7.500000
      CollisionHeight=6.000000
      LightType=LT_Steady
      LightBrightness=255
      LightHue=170
      LightSaturation=160
      LightRadius=4
      bBounce=True
}
