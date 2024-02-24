//=============================================================================
// NFireBall1.
//=============================================================================
class NFireBall1 expands NFireBall;

simulated function tick(float dtime)
{
	drawscale+=(dtime*15);
	fatness+=(dtime*160);
	ScaleGlow-=(dtime*2);	
}

defaultproperties
{
      LifeSpan=1.000000
}
