//=============================================================================
// BigFreezeBlob.
//=============================================================================
class BigFreezeBlob expands BigBiogel;

simulated function Timer()
{
	local FreezedBlob fb;
	if ( Level.NetMode!=NM_DedicatedServer ) 
	{
		fb=spawn(class'FreezedBlob');
		fb.drawscale=drawscale;
	}
	Destroy();
}
	
simulated function SetWall(vector HitNormal, Actor Wall)
{
//	local vector TraceNorm, TraceLoc, Extent;
//	local actor HitActor;
	local rotator RandRot;

	SurfaceNormal = HitNormal;
	RandRot = rotator(HitNormal);
	RandRot.Pitch -= (32768*0.5);
	SetRotation(RandRot);	
	if ( Mover(Wall) != None )
		SetBase(Wall);
}
function DropDrip()
{
}

auto state Flying
{
	simulated function ProcessTouch (Actor Other, vector HitLocation)
		{
			local int hitdamage,ddamage;
			local vector hitDir;
			local FreezedPawn fp;
			local FreezedBlob fb;
		if ( Pawn(Other)!=None )
		if ( Pawn(Other)!=Instigator || bOnGround) 
		if (BigFreezeBlob(Other) == none)
		{
			ddamage=drawscale*damage;
			hitdamage=ddamage;
			
	if ( (pawn(Other)!=None)&&(pawn(other).bIsPlayer) )
	{
		hitDamage = Level.Game.ReduceDamage(ddamage, 'freezed', pawn(other), instigator);
		if (pawn(other).ReducedDamageType == 'All') //God mode
			hitDamage = 0;
		else if (other.Inventory != None) //then check if carrying armor
			hitDamage = other.Inventory.ReduceDamage(hitDamage, 'freezed', HitLocation);
		else
			hitDamage = ddamage;
	}

			hitDir = Normal(Velocity);
			if ( FRand() < 0.2 )
				hitDir *= 5;
			if((Pawn(Other)!=None)&&(Pawn(Other).health<=(hitdamage+5))){
				fp=spawn(class'FreezedPawn',,,,Owner.rotation);
				fp.mesh=Other.mesh;
				fp.animsequence=Other.animsequence;
				fb=spawn(class'FreezedBlob',fp);
			fb.SetPhysics(PHYS_None);
//				fb.drawscale=drawscale;
				if(Pawn(Other).bIsPlayer)
					freezeplayer(Pawn(Other));
				else if(Pawn(Other)!=None) KilledSomePawn(Pawn(Other),Instigator,'freezed',hitDir);	
				else Other.Destroy();
			}else 
				Other.TakeDamage(hitdamage, instigator,HitLocation,
				(MomentumTransfer * hitDir), 'freezed');
			SpawnEffects();
			Destroy();			
		}

			//GotoState('Exploding');
		}

	simulated function HitWall( vector HitNormal, actor Wall )
	{
		SetPhysics(PHYS_None);		
		MakeNoise(0.6);	
		bOnGround = True;
		PlaySound(ImpactSound);	
		SetWall(HitNormal, Wall);
		GoToState('OnSurface');
	}

	simulated function BeginState()
	{	
		local Vector viewDir;
		
		viewDir = vector(Rotation);	
		Velocity = (Speed + (viewDir dot Instigator.Velocity)) * viewDir;
		Velocity.z += 120;
		RandSpin(100000);
		LoopAnim('Glob3',0.1);
		bOnGround=False;
		PlaySound(SpawnSound);
		if( Region.zone.bWaterZone )
			Velocity=Velocity*0.7;
	}
}

state OnSurface
{
	simulated function ProcessTouch (Actor Other, vector HitLocation)
	{
		local int hitdamage,ddamage;
		local vector hitDir;
		local FreezedPawn fp;
		local FreezedBlob fb;
		
		if ( Pawn(Other)!=None )
		if (BigFreezeBlob(Other) == none)
		{
			ddamage=drawscale*damage;
			hitdamage=ddamage;
			
	if ( (pawn(Other)!=None)&&(pawn(other).bIsPlayer) )
	{
		hitDamage = Level.Game.ReduceDamage(ddamage, 'freezed', pawn(other), instigator);
		if (pawn(other).ReducedDamageType == 'All') //God mode
			hitDamage = 0;
		else if (other.Inventory != None) //then check if carrying armor
			hitDamage = other.Inventory.ReduceDamage(hitDamage, 'freezed', HitLocation);
		else
			hitDamage = ddamage;
	}
			
			hitDir = Normal(Velocity);
			if ( FRand() < 0.2 )
				hitDir *= 5;
			if((Pawn(Other)!=None)&&(Pawn(Other).health<=(hitdamage+5))){
				fp=spawn(class'FreezedPawn',,,,Owner.rotation);
				fp.mesh=Other.mesh;
				fp.animsequence=Other.animsequence;
				fb=spawn(class'FreezedBlob',fp);
			//	fb.drawscale=drawscale;
				if(Pawn(Other).bIsPlayer)
					freezeplayer(Pawn(Other));
				else if(Pawn(Other)!=None) KilledSomePawn(Pawn(Other),Instigator,'freezed',hitDir);	
				else Other.Destroy();
			}else 
				Other.TakeDamage(hitdamage, instigator,HitLocation,
				(MomentumTransfer * hitDir), 'freezed');
			SpawnEffects();
			Destroy();			
		}

	//	GotoState('Exploding');
	}

	simulated function BeginState()
	{
		wallTime = DrawScale*5+20;
		
		if ( Mover(Base) != None )
		{
			BaseOffset = VSize(Location - Base.Location);
			SetTimer(0.2, true);
		}
		else 
			SetTimer(wallTime, false);
	}
}
simulated function SpawnEffects()
{
	local actor a;

	 PlaySound(Sound'Expl03',,12.0);
	 a = Spawn(class'EffectLight');
	 a.RemoteRole = ROLE_None;
	 a = Spawn(class'FreezeImpact');
	 a.DrawScale=6*DrawScale;
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
		PlayerPawn(Victim).ClientFlash( 4, 100 * EndFlashFog );
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


	

defaultproperties
{
      Damage=300.000000
      MomentumTransfer=1000
      RemoteRole=ROLE_SimulatedProxy
      LifeSpan=60.000000
      AnimSequence="Splat"
      Mesh=LodMesh'UnrealI.MiniBlob'
      DrawScale=0.100000
      LightBrightness=126
      LightHue=203
      LightSaturation=160
      LightRadius=8
}
