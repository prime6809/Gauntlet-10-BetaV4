//=============================================================================
// SpinnerProjectile2.
//=============================================================================
class SpinnerProjectile2 extends SpinnerProjectile;

auto simulated state Flying
{
 function BlowUp(vector HitLocation)
	{
		HurtRadius( Damage * DrawScale, 240 * DrawScale, 'zapped', MomentumTransfer * DrawScale, Location );
		MakeNoise(1.0);
  PlaySound( ImpactSound );
	}

	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		local EnergyBurst e;
  local vector momentum;
		
		if (  Pawn(Other)!=Instigator )
		{
			if ( Role == ROLE_Authority )
				{
    e = spawn( class 'EnergyBurst', , , HitLocation );
 		 e.RemoteRole = ROLE_None;
    momentum = 10000.0 * Normal(Velocity);
				Other.TakeDamage(Damage, instigator, HitLocation, momentum, 'zapped');
				}
			Destroy();
		}
	}
}

defaultproperties
{
      speed=1300.000000
      MaxSpeed=1500.000000
      Damage=40.000000
      MomentumTransfer=30000
}
