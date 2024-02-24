//=============================================================================
// SpinnerProjectile. 
//=============================================================================
class SpinnerProjectile extends Projectile;

//#exec texture IMPORT NAME=SpProjPal FILE=Models\SpProjPal.pcx GROUP=SpEffect
//#exec texture IMPORT NAME=e8_a00 FILE=Models\e8_a00.pcx GROUP=SpEffect
//#exec texture IMPORT NAME=e8_a01 FILE=Models\e8_a01.pcx GROUP=SpEffect
//#exec texture IMPORT NAME=e8_a02 FILE=Models\e8_a02.pcx GROUP=SpEffect
//#exec texture IMPORT NAME=e8_a03 FILE=Models\e8_a03.pcx GROUP=SpEffect
//#exec texture IMPORT NAME=e8_a04 FILE=Models\e8_a04.pcx GROUP=SpEffect
//#exec texture IMPORT NAME=e8_a05 FILE=Models\e8_a05.pcx GROUP=SpEffect
//#exec texture IMPORT NAME=e8_a06 FILE=Models\e8_a06.pcx GROUP=SpEffect
//#exec texture IMPORT NAME=e8_a07 FILE=Models\e8_a07.pcx GROUP=SpEffect
//#exec texture IMPORT NAME=e8_a08 FILE=Models\e8_a08.pcx GROUP=SpEffect
//#exec texture IMPORT NAME=e8_a09 FILE=Models\e8_a09.pcx GROUP=SpEffect

//#exec AUDIO IMPORT FILE="Sounds\spFire.wav"  NAME="spFire"   GROUP="Spinner"
//#exec AUDIO IMPORT FILE="Sounds\spHit.wav" NAME="spHit"    GROUP="Spinner"


auto simulated state Flying
{
	simulated function ProcessTouch( Actor Other, Vector HitLocation )
	{
		if ( Spinner( Other ) == None )
		{
			if ( Role == ROLE_Authority )
				Explode( HitLocation, Normal(Velocity) );
			else
				Destroy();
		}
	}

	simulated function HitWall( vector HitNormal, actor Wall )
	{
		Explode( Location, HitNormal );
	}

 function BlowUp(vector HitLocation)
	{
		HurtRadius( Damage * DrawScale, 240 * DrawScale, 'corroded', MomentumTransfer * DrawScale, Location );
		MakeNoise(1.0);
  PlaySound( ImpactSound );
	}

	simulated function Explode( vector HitLocation, vector HitNormal )
	{
		local EnergyBurst e;

		e = spawn( class 'EnergyBurst', , , HitLocation + HitNormal * 9 );
		e.RemoteRole = ROLE_None;
  BlowUp(HitLocation);
 	Destroy();
	}

	simulated function BeginState()
	{
		if( ScriptedPawn( Instigator ) != None )
			Speed = ScriptedPawn( Instigator ).ProjectileSpeed;
		Velocity = Vector( Rotation ) * speed;
		Velocity.z += 200;  // Lob vertical component
		PlaySound( SpawnSound );
		if( Region.zone.bWaterZone )
			Velocity *= 0.7;
	}

Begin:
	Sleep( LifeSpan - 0.3 ); //self destruct after 7.0 seconds
	Explode( Location, vect(0,0,0) );
}

defaultproperties
{
      speed=300.000000
      MaxSpeed=500.000000
      Damage=30.000000
      MomentumTransfer=20000
      SpawnSound=Sound'Gauntlet-10-BetaV4.spinner.spFire'
      ImpactSound=Sound'Gauntlet-10-BetaV4.spinner.spHit'
      Physics=PHYS_Falling
      RemoteRole=ROLE_SimulatedProxy
      LifeSpan=7.300000
      DrawType=DT_Sprite
      Style=STY_Translucent
      Texture=Texture'Gauntlet-10-BetaV4.SpEffect.e8_a00'
      DrawScale=0.500000
      bUnlit=True
      LightType=LT_Steady
      LightEffect=LE_NonIncidence
      LightBrightness=149
      LightHue=165
      LightSaturation=186
      LightRadius=4
      bBounce=True
}
