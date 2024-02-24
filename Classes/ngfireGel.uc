//=============================================================================
// ngFireGel.
//    It burns stuff
//=============================================================================
class ngfireGel extends Projectile;

var vector SurfaceNormal;  
var bool bOnGround;
var bool bCheckedSurface;
var int numBio;
var float wallTime;
var float BaseOffset;
var BioFear MyFear;

function PostBeginPlay()
{
  SetTimer(3.0, false);
  Super.PostbeginPlay();
}

function Destroyed()
{
  if ( MyFear != None )
    MyFear.Destroy();
  Super.Destroyed();
}

function Timer()
{
  local Actor Victims;
//  local FireRock Fire;
  //local ut_spark f;

  spawn(class'ut_spark',,,Location + SurfaceNormal*8);

  PlaySound (MiscSound,,3.0*DrawScale);  
  if ( (Mover(Base) != None) && Mover(Base).bDamageTriggered )
    Base.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
  
  HurtRadius(damage * Drawscale, FMin(150, DrawScale * 50), MyDamageType, MomentumTransfer * Drawscale, Location);
  
  //set people on fire
  foreach VisibleCollidingActors( class 'Actor', Victims, FMin(100, DrawScale * 35), Location)
  {
    if( (Pawn(Victims)!=None) && (FRand()>0.4))
    {
      Spawn(class'FireRock',self);
    }
  }

  Destroy();  
}
  
simulated function SetWall(vector HitNormal, Actor Wall)
{
//  local vector TraceNorm, TraceLoc, Extent;
//  local actor HitActor;
  local rotator RandRot;

  SurfaceNormal = HitNormal;
  if ( Level.NetMode != NM_DedicatedServer && Pawn(Wall)==None)
    spawn(class'botpack.boltscorch',,,Location, rotator(SurfaceNormal)); //put the plasmasphere's decal here
  RandRot = rotator(HitNormal);
  RandRot.Roll += 32768;
  SetRotation(RandRot);  
  if ( Mover(Wall) != None )
    SetBase(Wall);
  if ( Pawn(Wall) != None)
    SetBase(Wall);
}

singular function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation, 
            vector momentum, name damageType )
{
  //if ( damageType == MyDamageType )
  //  numBio = 3;
  //GoToState('Exploding');
}

auto state Flying
{
  function ProcessTouch (Actor Other, vector HitLocation) 
  { 
//    local FireRock Fire;

    if ( Pawn(Other)!=None && (Pawn(Other)!=Instigator || bOnGround))
    {
      Spawn(class'FireRock');
      Destroy();
    }
  }

  simulated function HitWall( vector HitNormal, actor Wall )
  {
    /*
    SetPhysics(PHYS_None);    
    MakeNoise(0.3);  
    bOnGround = True;
    PlaySound(ImpactSound);
    SetWall(HitNormal, Wall);
    PlayAnim('Hit');
    GoToState('OnSurface');
    */
    Spawn(class'FireRock',self);

    Destroy();
  }

  simulated function Landed( vector Hitnormal)
  {
    Spawn(class'FireRock',self);

    Destroy();
  }

  //kill the fire in water
  simulated function ZoneChange( Zoneinfo NewZone )
  {
    if (NewZone.bWaterZone)
      Destroy();
  }

  function Timer()
  {
    GotoState('Exploding');  
  }

  function BeginState()
  {  
    if ( Role == ROLE_Authority )
    {
      Velocity = Vector(Rotation) * Speed;
      Velocity.z += 120;
        //just to make sure that the velocity isn't too fast
      if (Vsize(Velocity) > speed)
      {
        Velocity = Normal(Velocity) * Speed;
      }

      if( Region.zone.bWaterZone )
        Velocity=Velocity*0.7;
    }
    if ( Level.NetMode != NM_DedicatedServer )
      RandSpin(100000);
    LoopAnim('Flying',0.4);
    bOnGround=False;
    PlaySound(SpawnSound);
  }
}

defaultproperties
{
      SurfaceNormal=(X=0.000000,Y=0.000000,Z=0.000000)
      bOnGround=False
      bCheckedSurface=False
      numBio=9
      wallTime=0.000000
      BaseOffset=0.000000
      MyFear=None
      speed=840.000000
      MaxSpeed=1500.000000
      Damage=20.000000
      MomentumTransfer=20000
      MyDamageType="Corroded"
      ImpactSound=Sound'Botpack.BioRifle.GelHit'
      MiscSound=Sound'UnrealShare.General.Explg02'
      bNetTemporary=False
      Physics=PHYS_Falling
      RemoteRole=ROLE_SimulatedProxy
      LifeSpan=12.000000
      AnimSequence="Flying"
      Style=STY_Translucent
      Texture=FireTexture'UnrealShare.CFLAM.cflame'
      Mesh=LodMesh'Botpack.BioGelm'
      DrawScale=2.000000
      AmbientGlow=255
      bUnlit=True
      bMeshEnviroMap=True
      CollisionRadius=2.000000
      CollisionHeight=2.000000
      bProjTarget=True
      LightType=LT_Steady
      LightEffect=LE_NonIncidence
      LightBrightness=159
      LightHue=32
      LightSaturation=79
      LightRadius=5
      bBounce=True
      Buoyancy=170.000000
}
