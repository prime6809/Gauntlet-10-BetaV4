//=============================================================================
// WormHole.
//=============================================================================
class WormHole expands Effects;

//#exec OBJ LOAD FILE=textures\U4eWarp.utx

var float lifetime;
var WormHole previous,next;
var vector HoleNormal;
var() float Damage, MomentumTransfer;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	next=None; previous=None;
	lifetime=0;
}

function startHitWall( vector HitNormal )
{
	SetRotation(rotator(HitNormal));
	HoleNormal=HitNormal;
	
	GotoState('buildhole');
}

function startHitPawn( vector HitNormal )
{
	SetRotation(rotator(HitNormal));
	HoleNormal=HitNormal;
	GotoState('collapsinghole');
}

state buildhole
{
ignores hitwall;
	simulated function tick(float dt)
	{
		lifetime+=dt;
		if(lifetime>=3) lifetime=3;
		drawscale=lifetime;
	}
	function timer()
	{
		local pawn p;
		local decoration d;
		local projectile o;
		local inventory i;
		local WormHole w;
		local vector suck;
		local float force;
		PlaySound(AmbientSound,SLOT_Misc,2,true);
		foreach radiusactors(class'WormHole',w,110*drawscale)
		{
			if(w!=self)
			if((drawscale>2)&&(w.drawscale>2))
			{
				//w.Destroy();
				SetLocation(0.5*(Location+Location)+32*HoleNormal);
				GotoState('collapsinghole');
			}	
		}
		foreach radiusactors(class'Pawn',p,50)
		{
			if(p==instigator) touch(p);
		}
		foreach radiusactors(class'projectile',o,25)
		{
			touch(o);
		}
		foreach radiusactors(class'inventory',i,25)
		{
			touch(i);
		}
		foreach radiusactors(class'decoration',d,25)
		{
			//touch(d);
		}
		foreach radiusactors(class'Pawn',p,200*drawscale)
		{
			if ( PlayerPawn(p) == none && ScriptedPawn(p) == none && Bot(p) == none )
				continue;

			suck=location-p.location;
			force=0.1*(200*drawscale-vsize(suck));
			p.TakeDamage(0.01*force*force*damage, Instigator, p.location, momentumtransfer*force*normal(suck),'fell'); 
			p.velocity += 20*normal(suck)*force;

		}
		foreach radiusactors(class'decoration',d,200*drawscale)
		{
			suck=location-d.location;
			force=0.05*(200*drawscale-vsize(suck));
			d.velocity += 30*normal(suck)*force;
			d.TakeDamage(0.01*force*force*damage, Instigator, d.location, momentumtransfer*force*normal(suck),'fell'); 
		}
		foreach radiusactors(class'inventory',i,200*drawscale)
		{
			suck=location-i.location;
			force=0.05*(200*drawscale-vsize(suck));
			i.velocity += 30*normal(suck)*force;
		}
		foreach radiusactors(class'projectile',o,200*drawscale)
		{
			suck=location-o.location;
			force=0.1*(200*drawscale-vsize(suck));
			o.velocity += 20*normal(suck)*force;
			o.TakeDamage(0.01*force*force*damage, Instigator, o.location, momentumtransfer*force*normal(suck),'fell'); 
		}
	}
	function Touch(actor other)
	{
		//if((pawn(other)!=none)||(decoration(other)!=none)||(projectile(other)!=none))
		if(other==instigator || Pawn(Other)==None)
		if(next!=none)
		{
			other.SetLocation(next.location+150*next.HoleNormal);
			other.velocity=6000*next.HoleNormal;
			pawn(other).viewrotation=rotator(-next.HoleNormal);
		}
		else if (previous!=none)
		{
			other.SetLocation(previous.location+150*previous.HoleNormal);
			other.velocity=2000*previous.HoleNormal;
			pawn(other).viewrotation=rotator(-previous.HoleNormal);
		}
		else other.TakeDamage(10000, Instigator, location, 10000*HoleNormal,'fell');
	}
	function BeginState()
	{
		mesh=mesh'disc';
			if(frand()>0.5)
			{mesh=mesh'wave02';LoopAnim('All',0.4);SetLocation(0.5*(Location+Location)+32*HoleNormal);}
		bmeshenviromap=false;
		skin=texture'MyTex2';
		Style=STY_modulated;
		lifetime=0.1;
		Velocity*=0;
		bUnlit=false;
		LightType=LT_steady;
		LightEffect=LE_NonIncidence;
		LightRadius=10;
		SetTimer(0.1,true);
	}	
	function EndState()
	{
		if(previous!=none)
			previous.next=next;
	}
Begin:
	sleep(10);
	SetLocation(Location+32*HoleNormal);
	GotoState('CollapsingHole');
}

state collapsinghole
{
ignores hitwall;
	simulated function tick(float dt)
	{
		lifetime+=dt;
		if(lifetime<=1)	drawscale=3*lifetime;			//growing
		else if(lifetime<=1.9) drawscale=6-3*lifetime;	//collapsing
		else drawscale=3*lifetime;		//explosion
	}
	function timer()
	{
		local pawn p;
		local decoration d;
		local projectile o;
		local vector suck;
		local float force;
/*		foreach radiusactors(class'Pawn',p,50)
		{
			if(p==instigator) touch(p);
		}
*/		foreach radiusactors(class'Pawn',p,150*drawscale)
		{
			if ( PlayerPawn(p) == none && ScriptedPawn(p) == none && Bot(p) == none )
				continue;

			suck=location-p.location;
			force=0.07*(150*drawscale-vsize(suck));
			p.velocity += 30*normal(suck)*force;
			p.TakeDamage(0.01*force*force*damage, Instigator, p.location, momentumtransfer*force*normal(suck),'fell'); 

		}
		foreach radiusactors(class'decoration',d,150*drawscale)
		{
			suck=location-d.location;
			force=0.07*(150*drawscale-vsize(suck));
			d.velocity += 30*normal(suck)*force;
			d.TakeDamage(0.01*force*force*damage, Instigator, d.location, momentumtransfer*force*normal(suck),'fell'); 
		}
		foreach radiusactors(class'projectile',o,150*drawscale)
		{
			suck=location-o.location;
			force=0.1*(150*drawscale-vsize(suck));
			o.velocity += 20*normal(suck)*force;
			o.TakeDamage(0.01*force*force*damage, Instigator, o.location, momentumtransfer*force*normal(suck),'fell'); 
		}
	}
/*	function Touch(actor other)
	{
		//if((pawn(other)!=none)||(decoration(other)!=none)||(projectile(other)!=none))
		if(other==instigator)
		if(next!=none)
		{
			other.SetLocation(next.location+150*next.HoleNormal);
			other.velocity=10000*next.HoleNormal;
			pawn(other).viewrotation=rotator(-next.HoleNormal);
		}
		else if (previous!=none)
		{
			other.SetLocation(previous.location+150*previous.HoleNormal);
			other.velocity=10000*previous.HoleNormal;
			pawn(other).viewrotation=rotator(-previous.HoleNormal);
		}
		else other.TakeDamage(10000, Instigator, location, 10000*HoleNormal,'fell');
	}
*/	function BeginState()
	{
		mesh=mesh'wave02';
		LoopAnim('All',0.2);
		bmeshenviromap=false;
		skin=texture'MyTex2';
		Style=STY_modulated;
		lifetime=0.01;
		Velocity*=0;
		bUnlit=false;
		LightType=LT_steady;
		LightEffect=LE_NonIncidence;
		LightRadius=10;
		SetTimer(0.1,true);
	}	
Begin:
	sleep(2);
	SetTimer(0.0,false);
	spawn(class'QSGExplBall',,,Location);
	SetRotation(rotator(vect(0,0,1)));
	mesh=mesh'RingEx';
	skin=texture'MyTex3';
	PlayAnim('All',0.4);
		PlaySound(EffectSound1,,16,,3000,1.5);
	HurtRadius(200*damage,600,'exploded', 100000, Location );
	ClientFlashes();
	FinishAnim();
	GotoState('Fade');
}
state Fade
{
	simulated function tick(float dtime)
	{
		lifetime+=dtime;
		if(lifetime<0.25) drawscale=50*lifetime;
		else drawscale=50*(1-lifetime)/3;
	}
Begin:
	DrawType=DT_Sprite;
	Style=STY_Translucent;
	texture=texture'T_PBurstPurple';
	lifetime=0.01;
	sleep(1);
	Destroy();
}

function ClientFlashes()
{
	local Vector EndFlashFog;
	local float f;
	local PlayerPawn p;
	EndFlashFog.X=1;	EndFlashFog.Y=0;	EndFlashFog.Z=3;
	ForEach VisibleActors( class'PlayerPawn', p)
	{
		f=2000-vsize(location-p.location);
		if(f>0)p.ClientFlash( 1, 500*EndFlashFog );
	}
}

defaultproperties
{
      Lifetime=0.000000
      Previous=None
      Next=None
      HoleNormal=(X=0.000000,Y=0.000000,Z=0.000000)
      Damage=1.000000
      MomentumTransfer=0.000000
      EffectSound1=Sound'Gauntlet-10-BetaV4.BFG.BFGexplFull'
      bNetTemporary=False
      LifeSpan=60.000000
      AmbientSound=Sound'Gauntlet-10-BetaV4.QSG.BlackHole3'
      DrawType=DT_Mesh
      Style=STY_Modulated
      DrawScale=0.001000
      SoundRadius=64
      LightType=LT_Steady
      LightEffect=LE_NonIncidence
      LightBrightness=255
      LightHue=185
      LightSaturation=50
      LightRadius=8
      NetPriority=8.000000
}
