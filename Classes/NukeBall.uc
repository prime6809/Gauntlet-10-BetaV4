//=============================================================================
// NukeBall.
//=============================================================================
class NukeBall expands Projectile;

var float lifetime;
var() int expl_radius;
var bool bFade;

simulated function SuperExplosion()
{
	HurtRadius(Damage*4, expl_radius, 'jolted', MomentumTransfer*2, Location );
	Destroy(); 
}
simulated function skeletoring()
{
	local charredflameskeleton skl;
	local pawn other;
	local float skelDS;
	foreach radiusactors(class'pawn',other,(expl_radius*1.2))
	if ((!other.bHidden)&&( Role == ROLE_Authority ))
	{
		skelDS=Other.CollisionHeight/39;
		if(other.health<=0)
		if(other.bIsPlayer || other.isa('Skaarj') || other.isa('Brute') || other.isa('Krall') || other.isa('Nali'))
		{
			spawn(class'NBoom2',,,other.location);
			skl=spawn(class'charredflameskeleton',,,other.location,other.rotation);
			skl.DrawScale*=skelDS;
			skl.SetCollisionSize(skelDS*skl.CollisionRadius,skelDS*skl.CollisionHeight);
			if(other.bIsPlayer)
			{ other.hideplayer(); other.gotostate('dying');}
			else other.destroy();
		}
	}
}
auto state Flying
{
	simulated function ProcessTouch (Actor Other, vector HitLocation)
	{

		If (Other!=Instigator && NukeBall(Other)==None)
		{
			if((Pawn(Other)!=None)&&(Pawn(Other).Health<Damage))
			{
				Damage-=Pawn(Other).Health;
				Other.TakeDamage(Pawn(Other).Health*4,Instigator, HitLocation, Normal(HitLocation-Other.Location),'jolted');
				skeletoring();
			}				
			Explode(HitLocation,Normal(HitLocation-Other.Location));
		}
	}
	simulated function Timer()
	{
		local Pawn p;
		ForEach VisibleActors(class'Pawn',p,(expl_radius/3)){
			if(p!=Instigator){
				Damage*=0.95;
				DrawScale*=0.95;
				p.TakeDamage((expl_radius*0.4-(VSize(Location-p.Location)))*0.3*(Damage/Default.Damage)
					,Instigator,p.Location, Normal(Location-p.Location),'jolted');
				spawn(class'NBoom2',self,,p.location);
			}
		}	
		skeletoring();
		spawn(class'NBoom2');
	}
	simulated function BeginState()
	{
		bFade=false;
		Velocity = vector(Rotation) * speed;
		SetTimer(0.2,true);	
	}
}


simulated function Explode(vector HitLocation,vector HitNormal)
{
	local earthquake q;
	q=spawn(class'EarthQuake');
	q.radius=2000;
	q.duration=3;
	q.magnitude=700;
	q.trigger(instigator,instigator);
	PlaySound(ImpactSound, SLOT_Misc, 25,true,,);
	HurtRadius(Damage, expl_radius, 'jolted', MomentumTransfer, Location );
	skeletoring();
Spawn(Class'NFireBall');
	GoToState('Fade');
}

state Fade
{
ignores Explode,ProcessTouch,HitWall;
	simulated function Timer()
	{
		local actor s;
		local vector l;
		local int i;

		for(i=0;i<4;i++)
		{
			l = location;
			l+=(frand()*0.7*expl_radius*normal(vector(rotrand())));
			if((2+2*frand())>lifetime) s = spawn(class'ut_SpriteBallExplosion',,,l);
	  		else s = spawn(class'BlackSmoke',,,l);
  			s.drawscale*=(expl_radius-vsize(l-location))/200;
			s.RemoteRole = ROLE_None;
		}

		HurtRadius((LightSaturation+LightBrightness)/1500*Damage, expl_radius, 'jolted', MomentumTransfer, Location );
		skeletoring();
	}
	simulated function tick(float DeltaTime)
	{
		lifetime+=deltatime;
		if(lifetime<0.40) drawscale=10*lifetime;
		else drawscale=25*(1.2-lifetime);
		if(bFade)
		{
			if(LightSaturation>=100*deltatime)
				LightSaturation-=100*deltatime;
			else{
				LightSaturation=0;
				if(LightBrightness<=100*deltatime) destroy();
				else LightBrightness-=100*deltatime;
			}	
		}
	}
	function LightStart()
	{
		LightType=LT_Steady;
		LightBrightness=255;
		LightSaturation=255;
		LightRadius = default.LightRadius*u4egauntlet(Level.Game).SafeLightScale;
		bFade=true;
	}
Begin:
	LightStart();
	SetTimer(0.2,true);
	SetPhysics(PHYS_None);
	DrawType=DT_None;
	sleep(0.3);
	ClientFlashes();
	lifetime=0.01;
//	texture=texture'Nredlight';
Spawn(Class'NukerShockWave');
Spawn(Class'NFireBall1');
	lifespan=5;
	sleep(0.40);
	texture=texture'Nredflare';
	DrawType=DT_Sprite;
	Style=STY_Translucent;
Spawn(Class'NFireBall2');
}				

simulated function ClientFlashes()
{
	local Vector EndFlashFog;
	local float f;
	local PlayerPawn p;
	EndFlashFog.X=4;	EndFlashFog.Y=2;	EndFlashFog.Z=1;
	ForEach VisibleActors( class'PlayerPawn', p)
	{
		f=4000-vsize(location-p.location);
		if(f>0)p.ClientFlash( 1, 800*EndFlashFog );
	}
}

defaultproperties
{
      Lifetime=0.000000
      expl_radius=1024
      bFade=False
      speed=400.000000
      MaxSpeed=400.000000
      Damage=500.000000
      MomentumTransfer=100000
      SpawnSound=Sound'Gauntlet-10-BetaV4.BFG.BFGRelease'
      ImpactSound=Sound'Gauntlet-10-BetaV4.BFG.BFGexpl1'
      bAlwaysRelevant=True
      bNetTemporary=False
      RemoteRole=ROLE_SimulatedProxy
      DrawType=DT_Sprite
      Style=STY_Translucent
      Texture=FireTexture'Gauntlet-10-BetaV4.NukerBall'
      DrawScale=0.400000
      AmbientGlow=255
      bUnlit=True
      SoundRadius=255
      SoundVolume=64
      SoundPitch=128
      CollisionRadius=25.000000
      CollisionHeight=10.000000
      LightType=LT_Steady
      LightBrightness=200
      LightHue=16
      LightSaturation=120
      LightRadius=64
}
