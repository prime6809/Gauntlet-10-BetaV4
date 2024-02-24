//======================================================================
//   WallFire, basicall a burner for nothing.
//======================================================================
class WallFire extends projectile;

var float burntime;
var bool bHitWater;
var BioFear MyFear;

function Destroyed()
{
  if ( MyFear != None )
    MyFear.Destroy();
  Super.Destroyed();
}

//Trying to make it work
auto state Flying
{
  simulated function ProcessTouch(Actor Other, Vector HitLocation)
  {
//    local burner Fire;
    if (Other.IsA('Pawn'))
      Other.TakeDamage(3, Instigator, HitLocation, Vect(0.0,0.0,2.0), 'burned');
    if (Other.IsA('WallFire'))
      Other.Destroy();
  }
  
  simulated function ZoneChange(ZoneInfo NewZone)
  {
    if (NewZone.bWaterZone)
      Destroy();
  }

  simulated function HitWall( vector HitNormal, actor Wall )
  {
    Velocity=Vect(0.0,0.0,0.0);

    SetPhysics(PHYS_None);
  }

  function Burnradius(Vector Location, float chance, int radius)
  {
    local Actor Victims;
    local Burner Fire;
  
    foreach VisibleCollidingActors( class 'Actor', Victims, radius, Location)
    {
      if( Pawn(Victims)!=None)
      {
        Victims.TakeDamage(3, Instigator, Victims.Location, Vect(0.0,0.0,2.0), 'burned');
        if (FRand()>(1-chance))
        {
          Fire=Spawn(class'Burner',,,Location, Rotator(Velocity));
          Fire.Target=Pawn(Victims);
          Fire.FireStarter=Instigator;
        }
      }
    }
  }
  
  function Tick(float DeltaTime)
  {
    /*if (Vsize(Velocity)>0)
      Velocity=Velocity-Velocity/VSize(Velocity);
    else
      Velocity=Vect(0.0, 0.0, 0.0);
    */

    if (drawscale<2.0)
      Drawscale+=deltatime;
    burntime-=deltatime;

    if (Burntime<2.0)
      Drawscale-=deltatime;

	drawscale = 0.5 * (lifespan / default.lifespan);

    if (Burntime<0)
      Destroy();
  }

  function SetUp()
  {
    local vector tempvect;

    tempvect=Vect(0.0,0.0,1.0);
    SetRotation(Rotator(tempvect));
  }
  
  simulated function BeginState()
  {
    //in .1 seconds, call timer i think
    SetTimer(0.5, false);

    //Velocity=Vector(Rotation)*Speed;

    MyFear = Spawn(class'BioFear');

    //Set it up ... riiiight
    SetUp();
  }
  
  simulated function Timer()
  {
    BurnRadius (Location, 0.4, 150);
    SetTimer(0.2, false);
  }
}

defaultproperties
{
      BurnTime=31.000000
      bHitWater=False
      MyFear=None
      RemoteRole=ROLE_SimulatedProxy
      LifeSpan=3.000000
      Style=STY_Translucent
      Texture=FireTexture'UnrealShare.CFLAM.cflame'
      Mesh=LodMesh'Botpack.PBolt'
      DrawScale=0.010000
      AmbientGlow=187
      bUnlit=True
      LightEffect=LE_NonIncidence
      LightBrightness=159
      LightHue=32
      LightSaturation=79
      LightRadius=8
}
