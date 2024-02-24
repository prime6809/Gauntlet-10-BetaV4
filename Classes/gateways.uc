class gateways expands actor
config(GauntletGates);

var() config int timetillnext,MaxMonsters,pointworth,HoleSize,critnum;
var() config float health,maxhealth;
var() config int allowedmonster[5];
var() config int Reward;
var() class<scriptedpawn> critter[5];
var() string critterNickName[5];
var spiffyhole spiffer;
var bool bFirstSet,bBlownFirst,bBlownSecond;
var mesh damagedmesh,damagedmesh2;
var float healthhalf,healththird;
var() string GateName;

replication
{
	// Things the server should send to the client.
	reliable if ( Role == ROLE_Authority )
		GateName;
}

function dmodelsetup()
{
        healthhalf=health*2;
        healthhalf=healthhalf/3;
        healththird=health/3;
}

function postbeginplay()
{
	SaveConfig();
	if ( !level.game.IsA('u4egauntlet') )
		destroy();

	super.postbeginplay();
	bFirstSet=true;
	settimer(1,true);
}

function timer()
{
	if ( bFirstSet == true )
		{
			// Choose A Monster From This Gateway
			critnum = rand(4);

			GateName = critterNickName[critnum];
			log("Spawned A"@GateName@"gateway");

			if ( allowedmonster[critnum] == 0 )
				log("The "@GateName@" gateway had been DISABLED!");

			if ( emergencykill() == true )
				{
					takedamage(health,none,location,location,'');
					return;
				}
 
			do
				{
					if ( allowedmonster[critnum] != 1 )
						{
							if ( critnum == 4 )
								critnum = 0;
							else
								critnum++;
						}
				}
			until ( allowedmonster[critnum] == 1 );
                
			spawncritter();
			spiffer = spawn(class'spiffyhole',,,location,(rotation+rot(0,0,6400)));
			spiffer.howbig = HoleSize;
			spiffer.setbase(self);
			setphysics(phys_falling);
			bFirstSet = false;
		}

	spawncritter();
	settimer(timetillnext,true);
}

function spawncritter()
{
	local actor c;
	local int bob;
	local scriptedpawn sp;
	foreach radiusactors(critter[critnum],c,1000)
		{
			bob++;
			if (bob>MaxMonsters)
				return;
		}

	sp = spawn(critter[critnum],,,location,rotation);
	if ( sp == none )
		return;

	// Save the monsters VALUE for scoring because I hate typing
	// sp.SaveConfig();

	sp.teamleader = sp;
	sp.team = 0;

	if ( u4eGauntlet(Level.Game).AllowRoaming == true )
		sp.GotoState('Roaming');

	// Does this actually work o.O I don't think so lol
	sp.lifespan = 400;
}

function bool emergencykill()
{
	if ( allowedmonster[0] != 1 && allowedmonster[1] != 1 &&
		allowedmonster[2] != 1 && allowedmonster[3] !=1 &&
		allowedmonster[4] !=1 )
		return(true);
	else
		return(false);
}

function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
{
	health -= damage;

	// The Gateway Was Destroyed!
	if ( health <= 0 )
		{
			
			// Chose the proper message when announce when the gateway is destroyed
			if ( PlayerPawn(EventInstigator) != none )
				AnnounceAll(EventInstigator.PlayerReplicationInfo.PlayerName@"Has Destroyed The"@GateName@"Gateway!");
			else
				{
					if ((EventInstigator != None) && ( EventInstigator.MenuName != "" ))
						AnnounceAll("LOL! a"@EventInstigator.MenuName@"Destroyed The"@GateName@"Gateway!");
					else
						AnnounceAll("The"@GateName@"Gateway Was Destroyed.");
				}

			// Let the player know they killed the gateway, if it was a player.
			if ( PlayerPawn(EventInstigator) != none )
				PlayerPawn(EventInstigator).ReceiveLocalizedMessage(class'PlayerKilledGateway',,,,self);

			// Let the game know we have destroyed the gateway >IMPORTANT!<
			u4egauntlet(level.game).GateDestroyed(self,eventinstigator,pointworth);

			// Uh, whatever the hell this does? well DO IT :S
			closegateway(location);
		}

	if(health<=healthhalf && health>healththird && !bBlownFirst)// && mesh!= damagedmesh2)
		{
			mesh=damagedmesh;
			bBlownFirst=true;
			bBlownSecond=false;
			spawn(class'utchunk',,,location,rotrand());
			spawn(class'WoodFragments',,,location,rotrand());
			spawn(class'utchunk2',,,location,rotrand());
			spawn(class'WoodFragments',,,location,rotrand());
			spawn(class'utchunk4',,,location,rotrand());
			spawn(class'ut_spriteballexplosion',,,location,rotation);
        }
	else
		if(health<=healththird && !bBlownSecond)
        	{
				mesh=damagedmesh2;
                bBlownFirst=true;
                bBlownSecond=true;
                spawn(class'utchunk',,,location,rotrand());
                spawn(class'WoodFragments',,,location,rotrand());
                spawn(class'utchunk2',,,location,rotrand());
                spawn(class'WoodFragments',,,location,rotrand());
                spawn(class'utchunk4',,,location,rotrand());
                spawn(class'ut_spriteballexplosion',,,location,rotation);
			}
}

function tick(float deltatime)
{
        local float glowMod;

		glowMod=health/default.health;
		scaleglow=glowmod;

		if( health >= healthhalf )
			{
				mesh = default.mesh;
				bBlownFirst = false;
				bBlownSecond = false;
			}
        else
			if ( mesh == damagedmesh2 && health > healththird )
				{
					mesh = damagedmesh;
					bBlownFirst = true;
					bBlownSecond = false;
				}

		if ( health >= maxhealth )
			return;
		else
			health+=0.1;
}

function closegateway(vector closelocation)
{
	spawn(class'utchunk',,,location,rotrand());
    spawn(class'WoodFragments',,,location,rotrand());
    spawn(class'utchunk2',,,location,rotrand());
    spawn(class'WoodFragments',,,location,rotrand());
    spawn(class'utchunk4',,,location,rotrand());
    spawn(class'ut_spriteballexplosion',,,location,rotation);

		
    if (spiffer != None)
		spiffer.GotoState('collapsinghole');
		
    destroy();
}

function AnnounceAll(string sMessage)
{
    local Pawn p;

	log(sMessage);

    for ( p = Level.PawnList; p != None; p = p.nextPawn )
	    if ( (p.bIsPlayer || p.IsA('MessagingSpectator')) &&
          p.PlayerReplicationInfo != None  )
		    p.ClientMessage(sMessage);
}

defaultproperties
{
      timetillnext=10000000
      maxmonsters=20
      pointworth=5
      HoleSize=1
      critnum=0
      Health=0.001000
      maxhealth=0.000000
      allowedmonster(0)=0
      allowedmonster(1)=0
      allowedmonster(2)=0
      allowedmonster(3)=0
      allowedmonster(4)=0
      Reward=0
      critter(0)=None
      critter(1)=None
      critter(2)=None
      critter(3)=None
      critter(4)=None
      critterNickName(0)=""
      critterNickName(1)=""
      critterNickName(2)=""
      critterNickName(3)=""
      critterNickName(4)=""
      spiffer=None
      bFirstSet=False
      bBlownFirst=False
      bBlownSecond=False
      damagedmesh=None
      damagedmesh2=None
      healthhalf=0.000000
      healththird=0.000000
      GateName=""
      DrawType=DT_Mesh
      Texture=FireTexture'UnrealShare.Belt_fx.ShieldBelt.N_Shield'
      DrawScale=2.000000
      bMeshEnviroMap=True
      CollisionRadius=45.000000
      CollisionHeight=70.000000
      bCollideActors=True
      bCollideWorld=True
      bProjTarget=True
}
