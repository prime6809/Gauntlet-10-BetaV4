//=============================================================================
// PlasmaBall.
//=============================================================================
class PlasmaBall extends Projectile;

var() Sound ExploSound;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( Level.bDropDetail )
		LightType = LT_None;
}

auto state Flying
{
	function ProcessTouch (Actor Other, vector HitLocation)
	{
		local DisruptorHit DH;

		If ( (Other!=Instigator) && (!Other.IsA('Projectile') || (Other.CollisionRadius > 0)) )
		{
			if (Other.IsA('Pawn'))
			{
				DH=spawn(class'DisruptorHit',Other,,Other.location,Other.rotation);
				DH.Mesh = Other.Mesh;
				DH.Texture = Texture;
				DH.LowDetailTexture = Texture;
				Other.TakeDamage(Damage,Instigator,HitLocation,MomentumTransfer*Normal(Velocity),MyDamageType);
				Destroy();
			}
			else Explode(HitLocation,Normal(HitLocation-Other.Location));
		}
	}

	function BeginState()
	{
		Velocity = vector(Rotation) * speed;	
	}
}

function Explode(vector HitLocation,vector HitNormal)
{
	PlaySound(ImpactSound, SLOT_Misc, 0.5,,, 0.5+FRand());
	HurtRadius(Damage*0.5, 32, MyDamageType, MomentumTransfer, Location );
	Spawn(class'U4ePlasmaExpl',,, HitLocation+HitNormal*0,rotator(HitNormal));		

	Destroy();
}

defaultproperties
{
      ExploSound=Sound'UnrealShare.General.SpecialExpl'
      speed=1500.000000
      Damage=15.000000
      MomentumTransfer=10000
      MyDamageType="Disrupted"
      ImpactSound=Sound'UnrealShare.General.Expla02'
      ExplosionDecal=Class'Botpack.EnergyImpact'
      bNetTemporary=False
      RemoteRole=ROLE_SimulatedProxy
      LifeSpan=10.000000
      Style=STY_Translucent
      Texture=Texture'Gauntlet-10-BetaV4.BluePBall_A00'
      Skin=Texture'Gauntlet-10-BetaV4.BluePBall_A03'
      Mesh=Mesh'Gauntlet-10-BetaV4.MzFlX'
      DrawScale=0.250000
      ScaleGlow=2.000000
      AmbientGlow=187
      bUnlit=True
      CollisionRadius=8.000000
      CollisionHeight=8.000000
      bProjTarget=True
      LightType=LT_Steady
      LightEffect=LE_NonIncidence
      LightBrightness=255
      LightHue=150
      LightSaturation=64
      LightRadius=6
      bFixedRotationDir=True
      RotationRate=(Roll=65000)
}
