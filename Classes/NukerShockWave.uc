//=============================================================================
// NukerShockWave. (no damage)
//=============================================================================
class NukerShockWave extends ShockWave;

simulated function Timer()
{

	local actor Victims;
	local float  dist, MoScale;  	//damageScale,
	local vector dir;

	ShockSize =  13 * (Default.LifeSpan - LifeSpan) + 3.5/(LifeSpan/Default.LifeSpan+0.05);
	if ( Level.NetMode != NM_DedicatedServer )
	{
		if (ICount==4) spawn(class'WarExplosion2',,,Location);
		ICount++;
	}

	foreach VisibleCollidingActors( class 'Actor', Victims, ShockSize*29, Location )
	{
		dir = Victims.Location - Location;
		dist = FMax(1,VSize(dir));
		dir = dir/dist + vect(0,0,0.3); 
		if (dist> OldShockDistance || (dir dot Victims.Velocity < 0))
		{
			MoScale = FMax(0, 1100 - 1.1 * Dist);
			if ( Victims.bIsPawn )
				Pawn(Victims).AddVelocity(dir * (MoScale + 20));
			else
				Victims.Velocity = Victims.Velocity + dir * (MoScale + 20);	
		}
	}	
	OldShockDistance = ShockSize*29;	
}

defaultproperties
{
}
