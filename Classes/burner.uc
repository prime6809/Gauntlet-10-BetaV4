//======================================================================
//   Burner
//          Set people on fire by spawning this.
//          all frags are traces back to the original fire person
//     i.e., i set bob on fire and bob sets archon and dodo on fire.
//     if they all die from burning, i get 3 frags.
//======================================================================
class Burner extends Projectile;

var Pawn Target, FireStarter;
var int burndamage, oldhealth;
var float burntime;
var bool bHitWater;
var BioFear MyFear;

function Destroyed()
{
  if ( MyFear != None )
    MyFear.Destroy();
  Super.Destroyed();
}

function KillOtherFlames (Pawn dude)
{
  local Burner Fire;

  foreach AllActors(class 'Burner', Fire)//go through all the burners
  {
    if ( Fire != None && Fire.Target == dude && Fire!=Self)
      Fire.Destroy();
    //if it's not me and it's pointing at him, kill it
  }
}

function PreBeginPlay()
{
  KillOtherFlames(Target); //kill anyone else burning this guy
  super.PreBeginPlay();
}

//Trying to make it work
auto state Flying
{
  simulated function ProcessTouch(Actor Other, Vector HitLocation)
  {
  }
  
  simulated function ZoneChange(ZoneInfo NewZone)
  {
    if (NewZone.bWaterZone)
      Destroy();
  }

  function Burnradius(Vector Location, float chance, int radius)
  {
    local Actor Victims;
    local Burner Fire;
  
    foreach VisibleCollidingActors( class 'Actor', Victims, radius, Location)
    {
      if( Pawn(Victims)!=None && FRand()>(1-chance) && Pawn(Victims)!=Target)
      {
        Fire=Spawn(class'Burner',,,Location, Rotator(Velocity));
        Fire.Target=Pawn(Victims);
        Fire.FireStarter=FireStarter;
      } 
    }
  }
  
  function Tick(float DeltaTime)
  {
    local vector temploc;

    tempLoc = Target.Location;
    temploc.Z-=33;
    SetLocation(temploc);
  }

  function SetUp()
  {
    local vector tempvect;

    tempvect=Vect(0.0,0.0,1.0);

    if (Target.HeadRegion.Zone.bWaterZone)
      destroy();
      //kill it if it's in the water
    KillOtherFlames(Target); //kill anyone else burning this guy
    SetLocation(Target.Location);
    SetRotation(Rotator(tempvect));
  }
  
  simulated function BeginState()
  {
    //Set it up ... riiiight
    SetUp();
    oldhealth=200;
    //in .1 seconds, call timer i think
	lifespan = 3;
    SetTimer(0.1, false);

    MyFear = Spawn(class'BioFear');
  }
  
  simulated function Timer()
  {
    local Vector hitloc; //hitlocation, so we can hit them if they're on the ground
    local Inventory I;
    //this is where we burn the poor bastard and hope it doesn't kill the game or something
	log("Tracker 1");
    //now we try to make sure that the Shield Belt Destroys the Fire, that way it's even better

	destroy();

	// Stop Accessed Nones!! (attempt)
	// if ( ScriptedPawn(Target) == None && StationaryPawn(Target) == None )
    	I = Target.FindInventoryType(class'UT_ShieldBelt');

	log("Tracker 2");

	// ShieldBelt Protects From Fire!
    if ( I != None )
      Destroy();

	log("Tracker 3");

    hitloc = Target.Location;

	if (burntime % 0.5 == 0.0)
		KillOtherFlames(Target);    

	log("Tracker 4");

	//if they go underwater, they go out
    if (Target.HeadRegion.Zone.bWaterZone)
      destroy();

	if ( (Target.Health - oldhealth) > 3 )//if they've picked up a health thing...
		burntime=burntime - (Target.Health - oldhealth);
	//decrease the time by how much higher their health is

	log("Tracker 5");

    if ( Target != None && Target.Health > 0 && burntime > 0.0 )
		{
			//It's a Witch!! BURN HER!!
			Burnradius (hitloc, 0.5, 100);
			Target.TakeDamage( burndamage, FireStarter, hitloc, Target.Velocity, 'burned');
			//Spawn(class'FlameExpl2',,, hitloc, rotator(Target.Velocity));
			//subtract the time
			burntime-=0.3;
			//let's do this again some time
			oldhealth=Target.Health;
			SetTimer(0.3, true);
			Return;
		}
    else
		if ( Target != None && Target.Health < 0 && burntime > 0.0 )
			{
				//special case, if they're on the ground, should work, i hope
      			//What do we burn apart from witches?
      			//MORE WITCHES!!!
				Burnradius (hitloc, 0.5, 100);
				Target.TakeDamage( burndamage, FireStarter, hitloc, Target.Velocity, 'burned');
				//Spawn(class'FlameExpl2',,, hitloc, rotator(Target.Velocity));
				//subtract the time
      			burntime-=0.3;
      			//let's do this again some time
				oldhealth=Target.Health;
				SetTimer(0.3, true);
				Return;
			}
		else
			destroy();
			//if they're gibbed, the fire would look weird sitting there.  
			log("Tracker 6");
		log("burntime"@burntime);
  }

}

defaultproperties
{
      Target=None
      FireStarter=None
      burndamage=3
      oldhealth=0
      BurnTime=7.500000
      bHitWater=False
      MyFear=None
      MyDamageType="Burned"
      Style=STY_Translucent
      Texture=FireTexture'UnrealShare.CFLAM.cflame'
      Mesh=LodMesh'Botpack.PBolt'
      DrawScale=2.000000
      LightEffect=LE_NonIncidence
      LightBrightness=159
      LightHue=32
      LightSaturation=79
      LightRadius=8
}
