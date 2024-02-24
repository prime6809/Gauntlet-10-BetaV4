//======================================================================
//   quickWallFire
//======================================================================
class quickWallFire extends WallFire;

auto state Flying
{
  function Tick(float DeltaTime)
  {
    if (drawscale<1.0)
      Drawscale+=deltatime;
    burntime-=deltatime;

    if (Burntime<1.0)
      Drawscale-=deltatime;

	drawscale = 0.25 * (lifespan / default.lifespan);

    if (Burntime<0)
      Destroy();
  }
}

defaultproperties
{
      BurnTime=6.000000
}
