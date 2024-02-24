//=============================================================================
// FireGlob
//    A big ball of burning gel
//=============================================================================
class FireGlob extends ngFireGel;

var int NumSplash;
var vector SpawnPoint;

auto state Flying
{
  function ProcessTouch (Actor Other, vector HitLocation) 
  { 
    if ( Other.IsA('FireSplash') )
      return;
    if ( Pawn(Other)!=Instigator || bOnGround) 
      Global.Timer(); 
  }
  simulated function HitWall( vector HitNormal, actor Wall )
  {

    SetPhysics(PHYS_None);    
    MakeNoise(1);  
    bOnGround = True;
    PlaySound(ImpactSound);  
    SetWall(HitNormal, Wall);
    if ( DrawScale > 1 )
      NumSplash = int(4 * DrawScale) - 1;
    SpawnPoint = Location + 5 * HitNormal;
    DrawScale= FMin(DrawScale, 3.0);
    if ( NumSplash > 0 )
    {
      SpawnSplash();
      if ( NumSplash > 0 )
        SpawnSplash();
    }
    GoToState('OnSurface');
  }
}

function SpawnSplash()
{
  local vector Start;

  NumSplash--;
  Start = SpawnPoint + 4 * VRand();
  Spawn(class'FireRock',,,Start,Rotator(Start - Location));
	//Fire is BROKEN!!! that sucks but we need something else for the beta
	// Spawn(class'FireSplash',,,Start,Rotator(Start - Location));
}

state OnSurface
{
  function Tick(float DeltaTime)
  {
    if ( NumSplash > 0 )
    {
      SpawnSplash();
      if ( NumSplash > 0 )
        SpawnSplash();
      else
        Disable('Tick');
    }
    else
      Disable('Tick');
  }

  function ProcessTouch (Actor Other, vector HitLocation)
  {
    if ( Other.IsA('FireSplash') )
      return;
    GotoState('Exploding');
  }
}

defaultproperties
{
      NumSplash=0
      Spawnpoint=(X=0.000000,Y=0.000000,Z=0.000000)
      speed=700.000000
      Damage=75.000000
      MomentumTransfer=30000
}
