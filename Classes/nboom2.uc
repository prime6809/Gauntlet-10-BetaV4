//=============================================================================
// nboom2.
//=============================================================================
class nboom2 expands Actor;

function postbeginplay()
{
	loopanim('All');
}
simulated function tick(float dtime)
{
	fatness+=(dtime*320);
	ScaleGlow-=(dtime*4);	
}

defaultproperties
{
      RemoteRole=ROLE_SimulatedProxy
      LifeSpan=0.490000
      DrawType=DT_Mesh
      Style=STY_Translucent
      Mesh=LodMesh'Gauntlet-10-BetaV4.nboom2'
      ScaleGlow=2.000000
      Fatness=96
      bUnlit=True
}
