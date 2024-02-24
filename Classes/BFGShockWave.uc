//=============================================================================
// BFGShockWave.
//=============================================================================
class BFGShockWave extends ShockWave;

simulated function Tick( float DeltaTime )
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		ShockSize =  (13 * (Default.LifeSpan - LifeSpan) + 3.5/(LifeSpan/Default.LifeSpan+0.05));
		ScaleGlow = Lifespan;
		AmbientGlow = ScaleGlow * 255;
		DrawScale = ShockSize;
	}
}

simulated function Timer()
{

	local actor Victims;
	local float  dist, MoScale; 	// damageScale,
	local vector dir;

	ShockSize =  (13 * (Default.LifeSpan - LifeSpan) + 3.5/(LifeSpan/Default.LifeSpan+0.05));
	if ( Level.NetMode != NM_DedicatedServer )
	{
		if ( Level.NetMode == NM_Client )
		{
			foreach VisibleCollidingActors( class 'Actor', Victims, ShockSize*29, Location )
				if ( Victims.Role == ROLE_Authority )
				{
					dir = Victims.Location - Location;
					dist = FMax(1,VSize(dir));
					dir = dir/dist +vect(0,0,0.3); 
					if ( (dist> OldShockDistance) || (dir dot Victims.Velocity <= 0))
					{
						MoScale = FMax(0, 0.5/*!*/*1100 - 1.1 * Dist);
						Victims.Velocity = Victims.Velocity + dir * (MoScale + 20);	
						Victims.TakeDamage
						(
							MoScale,
							Instigator, 
							Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
							(1000 * dir),
							'BFG20kDeath'
						);
					}
				}	
			return;
		}
	}

	foreach VisibleCollidingActors( class 'Actor', Victims, ShockSize*29, Location )
	{
		dir = Victims.Location - Location;
		dist = FMax(1,VSize(dir));
		dir = dir/dist + vect(0,0,0.3); 
		if (dist> OldShockDistance || (dir dot Victims.Velocity < 0))
		{
			MoScale = FMax(0, 0.5/*!*/*1100 - 1.1 * Dist);
			if ( Victims.bIsPawn )
				Pawn(Victims).AddVelocity(dir * (MoScale + 20));
			else
				Victims.Velocity = Victims.Velocity + dir * (MoScale + 20);	
			Victims.TakeDamage
			(
				MoScale,
				Instigator, 
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(1000 * dir),
				'BFG20kDeath'
			);
		}
	}	
	OldShockDistance = ShockSize*29;	
}

simulated function PostBeginPlay()
{
	local Pawn P;

	if ( Role == ROLE_Authority ) 
	{
		for ( P=Level.PawnList; P!=None; P=P.NextPawn )
			if ( P.IsA('PlayerPawn') && (VSize(P.Location - Location) < 3000) )
				PlayerPawn(P).ShakeView(0.5, 0.25/*!*/*600000.0/VSize(P.Location - Location), 0.5/*!*/*10);

		if ( Instigator != None )
			MakeNoise(10.0);
	}

	SetTimer(0.1, True);

	if ( Level.NetMode != NM_DedicatedServer )
		SpawnEffects();
}

simulated function SpawnEffects()
{
	 PlaySound(Sound'Expl03', SLOT_None, 8.0);
}

defaultproperties
{
      LifeSpan=1.250000
}
