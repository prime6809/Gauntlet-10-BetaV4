//=============================================================================
// FirePot.
//=============================================================================
class FirePot expands Projectile;

function Explode(vector HitLocation, vector HitNormal)
{
  SetPhysics(PHYS_None);
  SetRotation(Rotator(HitNormal));
  GotoState('Spraying');
}

state Spraying
{
  simulated function BeginState()
  {
    //in .1 seconds, call timer i think
    SetTimer(0.1, false);
  }

  simulated function Timer()
  {
    local ngFireGel fg;
    local vector start;
    local rotator rot;

    start = Location;
    Rot=Rotation;
    Rot.Yaw+=FRand()*15000-7500;
    Rot.Pitch+=FRand()*15000-7500;
    Rot.Roll+=FRand()*15000-7500;
    fg=Spawn( class 'FireSplash',, '', Start, Rot);
    fg.speed=475;

    SetTimer(0.2, False);
  }
}

defaultproperties
{
}
