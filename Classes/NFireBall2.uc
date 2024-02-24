//=============================================================================
// NFireBall2.
//=============================================================================
class NFireBall2 expands NFireBall;

simulated function tick(float dtime)
{
	drawscale+=(dtime*35);
	fatness+=(dtime*160/1.58);
	ScaleGlow-=(dtime*2/1.58);	
}

defaultproperties
{
      LifeSpan=1.581000
      DrawScale=1.250000
}
