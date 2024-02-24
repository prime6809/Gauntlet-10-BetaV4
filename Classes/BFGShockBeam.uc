//=============================================================================
// BFGShockBeam.
//=============================================================================
class BFGShockBeam extends ShockBeam;

simulated function Tick( float DeltaTime )
{
	if ( Level.NetMode  != NM_DedicatedServer )
	{
		ScaleGlow = (Lifespan/Default.Lifespan)*1.0;
		AmbientGlow = ScaleGlow * 210;
		DrawScale = (Lifespan/Default.Lifespan)*Default.DrawScale;
	}
}

simulated function Timer()
{
	local BFGShockBeam r;
	
	if (NumPuffs>0)
	{
		r = Spawn(class'BFGShockbeam',,,Location+MoveAmount);
		r.RemoteRole = ROLE_None;
		r.NumPuffs = NumPuffs -1;
		r.MoveAmount = MoveAmount;
	}
}

defaultproperties
{
      LifeSpan=0.150000
      Texture=Texture'Gauntlet-10-BetaV4.BFG.bfgexpl3'
      DrawScale=0.025000
}
