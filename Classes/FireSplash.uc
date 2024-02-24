//=============================================================================
// BioSplash
//=============================================================================
class FireSplash extends ngFireGel;

auto state Flying
{
  function ProcessTouch (Actor Other, vector HitLocation) 
  { 
    if ( Other.IsA('ngFireGel') && (LifeSpan > Default.LifeSpan - 0.2) )
      return;
    if ( Pawn(Other)!=Instigator || bOnGround) 
      Global.Timer(); 
  }
}

defaultproperties
{
      speed=300.000000
}
