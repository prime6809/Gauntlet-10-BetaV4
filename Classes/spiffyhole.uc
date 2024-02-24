class spiffyhole expands wormhole;
var int howbig;

auto state buildhole
{
ignores hitwall;
	simulated function tick(float dt)
	{
		lifetime+=dt;
                if(lifetime>=howbig) lifetime=howbig;
		drawscale=lifetime;
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
		bUnlit=false;
		LightType=LT_steady;
		LightEffect=LE_NonIncidence;
		LightRadius=10;
		//setTimer(3,false);

	}
    
	function timer()
	{
		//GotoState('collapsinghole');
	}

	function EndState()
	{
		if(previous!=none)
			previous.next=next;
	}
Begin:
}

function blowup()
{
        destroy();
}

function ClientFlashes()
{
	local Vector EndFlashFog;
	local float f;
	local PlayerPawn p;
	track(1);
	EndFlashFog.X=1;	EndFlashFog.Y=0;	EndFlashFog.Z=3;
	ForEach VisibleActors( class'PlayerPawn', p)
	{
		track(2);
		f=2000-vsize(location-p.location);
                if(f>0)p.ClientFlash( 1, 600*EndFlashFog );
		track(3);
	}
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
              foreach radiusactors(class'Pawn',p,150*drawscale)
		{
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
      function BeginState()
	{
		local vector BoomPosition;

		BoomPosition.x = location.x;
		BoomPosition.y = location.y;
		BoomPosition.z = location.z-72;

		spawn(class'boom0',,,BoomPosition,rotator(vect(0,0,0)));
             Mesh=none;
             DrawScale=0.000000;
             lifetime=0.01;
             Velocity*=0;
             bUnlit=false;
             LightType=LT_steady;
             LightEffect=LE_NonIncidence;
             LightRadius=10;
             SetTimer(0.1,true);
			 track(4);
	}	
Begin:
	sleep(2);
	SetTimer(0.0,false);
	spawn(class'QSGExplBall',,,Location);
	SetRotation(rotator(vect(0,0,1)));
	mesh=mesh'RingEx';
        skin=FireTexture'UnrealShare.CFLAM.cflame';
	PlayAnim('All',0.4);
		PlaySound(EffectSound1,,16,,3000,1.5);
	HurtRadius(200*damage,600,'exploded', 100000, Location );
	ClientFlashes();
	FinishAnim();
	GotoState('Fade');
}

simulated function track(int index)
{
	log("TRACKER:"@index);
}

defaultproperties
{
      howbig=1
      LifeSpan=0.000000
      LightEffect=LE_Shock
      LightRadius=20
}
