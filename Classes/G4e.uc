//=============================================================================
// G4e.
//=============================================================================
class G4e extends UT_Grenade;

var() float GP4eSpeed;

simulated function SetupGP4ePhysics()
{
	if ( Role == ROLE_Authority )
	{
		SetPhysics(PHYS_Projectile);
		Velocity = Vector(Rotation) * GP4eSpeed;
		MaxSpeed = GP4eSpeed;
		bCanHitOwner = true;
	}	
}
simulated function ProcessTouch( actor Other, vector HitLocation )
{
	if ( (G4e(Other)==None) && ((Other!=instigator) || bCanHitOwner) )
		Explosion(HitLocation);
}
simulated function Explosion(vector HitLocation)
{
	local UT_SpriteBallExplosion s;

	BlowUp(HitLocation);
	if ( Level.NetMode != NM_DedicatedServer )
	{
		spawn(class'Botpack.BlastMark',,,,rot(16384,0,0));
  		s = spawn(class'UT_SpriteBallExplosion',,,HitLocation);
		s.RemoteRole = ROLE_None;

		Spawn( class 'UTChunk1',, '', HitLocation,RotRand());
		Spawn( class 'UTChunk2',, '', HitLocation,RotRand());
		Spawn( class 'UTChunk3',, '', HitLocation,RotRand());
		Spawn( class 'UTChunk4',, '', HitLocation,RotRand());
	}
 	Destroy();
}
simulated function PostBeginPlay()
{
	local vector X,Y,Z;
//	local rotator RandRot;

	Super.PostBeginPlay();
	if ( Level.NetMode != NM_DedicatedServer )
		PlayAnim('WingIn');
	SetTimer(2.5+FRand()*0.5,false);                  //Grenade begins unarmed

	if ( Role == ROLE_Authority )
	{
		GetAxes(Instigator.ViewRotation,X,Y,Z);	
		Velocity = X * (Instigator.Velocity Dot X)*0.4 + Vector(Rotation) * (Speed +
			FRand() * 100);

	if(X.z >= 0)
	{
		if(X.z < 0.707) Velocity *= (1+(X.z/0.707));
		else Velocity *= (2-3.0*(X.z-0.707));
	}
	else
		Velocity *= (1+X.z);

	//Velocity.z += 210;
		MaxSpeed = 1000;
		RandSpin(50000);	
		bCanHitOwner = False;
		if (Instigator.HeadRegion.Zone.bWaterZone)
		{
			bHitWater = True;
			Disable('Tick');
			Velocity=0.6*Velocity;			
		}
	}	
}

defaultproperties
{
      GP4eSpeed=50.000000
      MyDamageType="Grenades4eDeath"
      Mesh=Mesh'Gauntlet-10-BetaV4.G4eSolo'
      DrawScale=0.700000
      CollisionRadius=4.000000
      CollisionHeight=4.000000
}
