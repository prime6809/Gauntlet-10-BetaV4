//=============================================================================
// Flame2.
//=============================================================================
class Flame2 extends Projectile;

var() texture FireTexs[9];

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( Level.bDropDetail )
		LightType = LT_None;
	Texture = FireTexs[1+Rand(7)];
}

auto state flying
{
	simulated function HitWall (vector HitNormal, actor Wall)
	{
		local vector newDir;
		newDir = Velocity + MirrorVectorByNormal(Velocity, HitNormal);	//Slide along wall!
		SetLocation(Location + 2.0*HitNormal);		//and prevent hitting same wall again
		Velocity = 0.5 * newDir;
		Acceleration *= 0;
		Lifespan *= 0.8;
	}
	simulated function ZoneChange( Zoneinfo NewZone )
	{
		local Splash w;
		if (!NewZone.bWaterZone) Return;
		if ( Level.NetMode != NM_DedicatedServer )
		{
			Spawn(class'UT_BlackSmoke');
			if(frand() < 0.1)	//only about 2 per second
			{
				w = Spawn(class'Splash',,,,rot(16384,0,0));
				w.DrawScale = 0.5;
				w.RemoteRole = ROLE_None;
			}
		}
		Destroy();
	}
	simulated function ProcessTouch(Actor Other, Vector HitLocation)
	{
		if ((Other!=Instigator) && (Projectile(Other)==None))
			Velocity*=0;
	}
	simulated function tick(float dtime)
	{
		if(Lifespan < 0.34*Default.Lifespan)
			Drawscale += dtime*1.5;
		else
			Drawscale += dtime*1.0;
	}
	simulated function timer()
	{
		local charredflameskeleton skl;
		local actor other;
		local float skelDS;
		if ( Level.NetMode == NM_Client )
		{
			foreach RadiusActors(class'actor',other,Drawscale*80)
				if ( other.Role == ROLE_Authority )
				{
					if ((pawn(other)!=none)||(decoration(other)!=none))
					if ((!other.bHidden)&&(other!=instigator)&&( Role == ROLE_Authority ))
				{
					Other.TakeDamage(Damage, instigator,Location,vect(0,0,0), 'burned');
					skelDS=Other.CollisionHeight/39;
					if(Pawn(other)!=none && (pawn(other).health<=0) && (frand()>(0.7)))
					if(pawn(other).bIsPlayer || other.isa('Skaarj') || other.isa('Brute') || other.isa('Krall')
						|| other.isa('Nali'))
					{
						skl=spawn(class'charredflameskeleton',,,other.location,other.rotation);
						skl.DrawScale*=skelDS;
						skl.SetCollisionSize(skelDS*skl.CollisionRadius,skelDS*skl.CollisionHeight);
						if(pawn(other).bIsPlayer)
						{ pawn(other).hideplayer(); pawn(other).gotostate('dying');}
						else pawn(other).destroy();
					}
				}
				}
			return;
		}

		foreach RadiusActors(class'actor',other,Drawscale*80)
			if ((pawn(other)!=none)||(decoration(other)!=none))
			if ((!other.bHidden)&&(other!=instigator)&&( Role == ROLE_Authority ))
		{
			Other.TakeDamage(Damage, instigator,Location,vect(0,0,0), 'burned');
			skelDS=Other.CollisionHeight/39;
			if(Pawn(other)!=none && (pawn(other).health<=0) && (frand()>(0.7)))
			if(pawn(other).bIsPlayer || other.isa('Skaarj') || other.isa('Brute') || other.isa('Krall')
				|| other.isa('Nali'))
			{
				skl=spawn(class'charredflameskeleton',,,other.location,other.rotation);
				skl.DrawScale*=skelDS;
				skl.SetCollisionSize(skelDS*skl.CollisionRadius,skelDS*skl.CollisionHeight);
				if(pawn(other).bIsPlayer)
				{ pawn(other).hideplayer(); pawn(other).gotostate('dying');}
				else pawn(other).destroy();
			}
		}
	}
	simulated function BeginState()
	{
		Velocity = vector(Rotation) * speed;
		Velocity = VSize(Velocity) * (normal(Velocity) + 0.05*normal(VRand()));
		//Acceleration = (-0.5) * Velocity;
		Acceleration.Z += 0.25 * Region.Zone.ZoneGravity.Z;
		SetTimer(0.2,true);
		RandSpin(50000);
	}
Begin:
}

defaultproperties
{
      FireTexs(0)=Texture'Botpack.WarExplosionS.we_a00'
      FireTexs(1)=Texture'Botpack.UT_Explosions.exp1_a00'
      FireTexs(2)=Texture'Botpack.UT_Explosions.Exp4_a00'
      FireTexs(3)=Texture'Botpack.UT_Explosions.Exp7_a00'
      FireTexs(4)=Texture'Botpack.UT_Explosions.Exp4_a00'
      FireTexs(5)=Texture'Botpack.UT_Explosions.Exp5_a00'
      FireTexs(6)=Texture'Botpack.UT_Explosions.Exp6_a00'
      FireTexs(7)=Texture'Botpack.UT_Explosions.Exp7_a00'
      FireTexs(8)=Texture'Botpack.WarExplosionS2.ne_a00'
      speed=1000.000000
      MaxSpeed=1000.000000
      Damage=3.000000
      bNetTemporary=False
      RemoteRole=ROLE_SimulatedProxy
      LifeSpan=1.490000
      DrawType=DT_SpriteAnimOnce
      Style=STY_Translucent
      DrawScale=0.200000
      ScaleGlow=2.000000
      AmbientGlow=187
      bUnlit=True
      LightType=LT_Steady
      LightEffect=LE_NonIncidence
      LightBrightness=64
      LightHue=12
      LightSaturation=96
      LightRadius=8
}
