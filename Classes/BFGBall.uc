//=============================================================================
// BFGBall.
//=============================================================================
class BFGBall expands Projectile;

var BFGRotRing rring;
var float lifetime;

simulated function SuperExplosion()
{
	HurtRadius(Damage*4, 500, 'jolted', MomentumTransfer*2, Location );
	Spawn(Class'BFGMasterExp',Owner,'',Location, Instigator.ViewRotation);
	Destroy(); 
}

auto state Flying
{
	simulated function ProcessTouch (Actor Other, vector HitLocation)
	{

		If (Other!=Instigator  && TazerProj(Other)==None)
		{
			if((Pawn(Other)!=None)&&(Pawn(Other).Health<Damage))
			{
				Damage-=Pawn(Other).Health;
				Other.TakeDamage(Pawn(Other).Health*2,Instigator, HitLocation, Normal(HitLocation-Other.Location),'jolted');
			}				
			Explode(HitLocation,Normal(HitLocation-Other.Location));
		}
	}
	simulated function Timer()
	{
		local Pawn p;
		local BFGexplosion e;
		ForEach VisibleActors(class'Pawn',p,500){
			if(p!=Instigator){
				Damage*=0.9;
				DrawScale*=0.9;
				SpawnEffect(p.location,location);
				e=spawn(class'BFGexplosion',self,,p.Location);
				e.DrawScale=((550-(VSize(Location-p.Location)))/550)*(Damage/Default.Damage);
				p.TakeDamage((550-(VSize(Location-p.Location)))*0.2*(Damage/Default.Damage)
					,Instigator,p.Location, Normal(Location-p.Location),'jolted');
			}
		}	
	}
	simulated function BeginState()
	{
		LightRadius = default.LightRadius*u4egauntlet(Level.Game).SafeLightScale;
		Velocity = vector(Rotation) * speed;
		rring=spawn(class'BFGRotRing',self);
		SetTimer(0.2,true);	
	}
}


simulated function Explode(vector HitLocation,vector HitNormal)
{
	local BFGMasterExp me;
	rring.Destroy();
	 PlaySound(ImpactSound, SLOT_Interface, 16.0,,8000);
	 PlaySound(ImpactSound, SLOT_None, 16.0,,8000);
	 PlaySound(ImpactSound, SLOT_Misc, 16.0,,8000);
	 PlaySound(ImpactSound, SLOT_Talk, 16.0,,8000);
	HurtRadius(Damage, 256, 'jolted', MomentumTransfer, Location );
	me=Spawn(Class'BFGMasterExp',Owner,'',Location, Instigator.ViewRotation);
	me.DamageMod=Damage/Default.Damage;
	spawn(class'BFGShockWave',,,HitLocation+ HitNormal*16);	
	GoToState('Fade');
}

state Fade
{
ignores Explode,ProcessTouch,HitWall;
	simulated function tick(float DeltaTime)
	{
		LightBrightness-=(255*DeltaTime);
		lifetime+=deltatime;
		if(lifetime<0.25) drawscale=30*lifetime;
		else drawscale=30*(1-lifetime)/2;
	}
Begin:
	DrawType=DT_None;
	LightBrightness=255;
	sleep(0.3);
	ClientFlashes();
	lifetime=0.01;
	DrawType=DT_Sprite;
	Style=STY_Translucent;
	texture=texture'T_PBurstGreen';
	lifespan=0.8;
}				

function SpawnEffect(vector HitLocation, vector SmokeLocation)
{
	local BFGShockBeam Smoke;
	local Vector DVector;
	local int NumPoints;
	local rotator SmokeRotation;

	DVector = HitLocation - SmokeLocation;
	NumPoints = VSize(DVector)/135.0;
	if ( NumPoints < 1 )
		return;
	SmokeRotation = rotator(DVector);
	SmokeRotation.roll = Rand(65535);
	
	Smoke = Spawn(class'BFGShockBeam',,,SmokeLocation,SmokeRotation);
	Smoke.MoveAmount = DVector/NumPoints;
	Smoke.NumPuffs = NumPoints - 1;	
}
simulated function ClientFlashes()
{
	local Vector EndFlashFog;
	local float f;
	local PlayerPawn p;
	EndFlashFog.X=1;	EndFlashFog.Y=3;	EndFlashFog.Z=0;
	ForEach VisibleActors( class'PlayerPawn', p)
	{
		f=4000-vsize(location-p.location);
		if(f>0)p.ClientFlash( 1, 1000*EndFlashFog );
	}
}

defaultproperties
{
      rring=None
      Lifetime=0.000000
      speed=500.000000
      MaxSpeed=500.000000
      Damage=750.000000
      MomentumTransfer=100000
      SpawnSound=Sound'Gauntlet-10-BetaV4.BFG.BFGRelease'
      ImpactSound=Sound'Gauntlet-10-BetaV4.BFG.BFGexplFull'
      bAlwaysRelevant=True
      bNetTemporary=False
      RemoteRole=ROLE_SimulatedProxy
      DrawType=DT_Sprite
      Style=STY_Translucent
      Texture=Texture'Gauntlet-10-BetaV4.BFG.BFGBall'
      DrawScale=0.500000
      AmbientGlow=255
      bUnlit=True
      SoundRadius=255
      SoundVolume=64
      SoundPitch=128
      CollisionRadius=25.000000
      CollisionHeight=10.000000
      LightType=LT_Steady
      LightEffect=LE_NonIncidence
      LightBrightness=160
      LightHue=80
      LightRadius=64
}
