//===================================================
//U4e gauntlet gametype
//Brad aka 'Sonic'-Feb 2002
//Last Update: Guess who discovered how to do recusive
//functions? I'm going to use it for the gate setup
//see if we can get rid of that nasty crash bug.
//===================================================

class u4egauntlet expands teamgameplus
config(GauntletGame);

// PHS 2024-02-06, more level nodes fixes gate distribution on some maps.
const NoLevelNodes = 512;

enum ENBool
{
	EB_False,
	EB_True
};

var int numpoints,number;
var int numsmall,nummed,numbig,numhuge,numgiant;
var() globalconfig int maxsmall,maxmed,maxbig,maxhuge,maxgiant;
var() globalconfig int smallhealth,medhealth,bighealth,hugehealth,gianthealth;
var() globalconfig int smallspawn,medspawn,bigspawn,hugespawn,giantspawn;
var() globalconfig int smallmax,medmax,bigmax,hugemax,giantmax;
var() globalconfig int smallallow[5],medallow[5],bigallow[5],hugeallow[5],giantallow[5];
var() globalconfig bool bBossRegen;
var() globalconfig int regenamount;

// After monster spawn from their gateway allow them to roam arround looking for trouble
var() globalconfig bool AllowRoaming;

// Stop the client side "Light Crashes" comonly caused by Angels and Maxes when they spam there BFG's
var() globalconfig float SafeLightScale;

var int totalgates,totalgatesleft;
var gateways gw2;
var navigationpoint navip;
var bool bSpawnedBoss;
var pawn theboss[4];


var int bossinithealth[4];
var bool bLevelGatesSet;
var pathnode levelNodes[NoLevelNodes];
var ENBool NodeTaken[NoLevelNodes];

var GauntletStatistics StatisticsManager;

// New!
var() globalconfig String MessageGameEndWin;
var() globalconfig String MessageGameEndLose;
var() globalconfig int MaxAttemptsSpawningBoss;
var() globalconfig bool UseTreeSpawnMethodForGates;

// Revised
var() globalconfig int BossInitialNumber;
var() globalconfig class<scriptedpawn> BossPosibilities[12];
var int BossesAlive;

replication
{
	// Things the server should send to the client.
	reliable if ( Role == ROLE_Authority )
		StatisticsManager;
}

///////////////////////////// Borrowed From SiegeXtreme LOL /////////////////////////////////////////////
event PlayerPawn Login(string portal, string options, out string error,
  class<PlayerPawn> spawnClass)
{ 	
	local PlayerPawn newPlayer;
    local class<PlayerReplicationInfo> priClass;

    // Ugly hack to spawn the correct type of PRI
    priClass = spawnClass.default.PlayerReplicationInfoClass;
    spawnClass.default.PlayerReplicationInfoClass = class'GauntletPlayerReplicationInfo';
    newPlayer = Super.Login(portal, options, error, spawnClass);
    spawnClass.default.PlayerReplicationInfoClass = priClass;

	log("******************** Player logging in!!"@spawnClass);

    return newPlayer;
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////



function AddToTeam( int num, Pawn Other )
{
        bBalanceTeams=false;
        super.AddToTeam(0,other);
}

event PostLogin( playerpawn NewPlayer )
{
	Super.PostLogin(NewPlayer);
//        if ( Level.NetMode != NM_Standalone )
                NewPlayer.ClientChangeTeam(0);
	// StatisticsManager.CheckRank(NewPlayer);
/*
	if ( StatisticsManager.ScanComplete == true )
		{
			StatisticsManager.CheckRank(NewPlayer);
			StatisticsManager.RankPlayer(NewPlayer);
		}
*/
}


function gateways getgate(class<gateways> myGate)
{
	local int myRand;
    local gateways g;
    local bool bSpotTaken;
	local SymTree Tree;
	local vector NewLocation;
	local PathNode PN;
	local int ValidNodes[NoLevelNodes];
	local int ValidCount;
	local int MySpot;
	local int Idx;

	if ( UseTreeSpawnMethodForGates == true )
	{
    	 myRand = Rand(numpoints);

    	foreach allactors(class'PathNode',PN)
    	{
			Tree = PN.Spawn(class'SymTree');
			Tree.BuildTree();

			while ( g == none )
			{
				NewLocation = Tree.GetSpot();

	        	foreach radiusactors(class'gateways',g,50,NewLocation)
        		{
					if ( g != none )  //make sure we dont have gates on top of each other
						continue;
					else
						g = spawn(myGate,,,NewLocation);

					if ( g == none )
						continue;
					else
						return g;
        		}
			}
        }
	}
	else
	{
		// initialize these so that loop is entered at least once.
		g = None;
		ValidCount=1;
		
		// Loop until we either spawn a gate, or run out of valid points.
		while ((g == None) && (ValidCount != 0)) 
		{
			// get an array of not currently taken points
			ValidCount=0;
			for(Idx=0; Idx<numpoints; Idx++)
			{
				if (NodeTaken[Idx] == EB_False)
				{
					ValidNodes[ValidCount]=Idx;
					ValidCount++;
				}
			}

			// only proceed if we have valid points.
			if (ValidCount > 0)
			{
				myRand = Rand(ValidCount);
				MySpot = ValidNodes[myRand];

				// flag node taken, even if it fails.....
				NodeTaken[MySpot]=EB_True;

				g = spawn(myGate,,,levelnodes[MySpot].location);
			}
		}
		
		return g;
	}
}
        
function setupgates(class<gateways> thegate, int bob)
{
	local int i,j,numgates,health,spawnrate,maxmonsters;
//	local pathnode pn;
	local gateways spawnedgate;
	local int allowedmonster[5];
	local int eger;

	numgates = 0;
	eger = Rand(numpoints);
	j = 0;

	switch (bob)
		{
			case 0:
				spawnrate = smallspawn;
				health = smallhealth;
				maxmonsters = smallmax;

				for ( i = 0; i < 5; i++ )
					allowedmonster[i] = smallallow[i];
				break;
			case 1:
				spawnrate = medspawn;
				health = medhealth;
				maxmonsters = medmax;

				for ( i = 0; i < 5; i++ )
					allowedmonster[i] = medallow[i];
				break;
			case 2:
				spawnrate = bigspawn;
				health = bighealth;
				maxmonsters = bigmax;

				for ( i = 0; i < 5; i++ )
					allowedmonster[i] = bigallow[i];
				break;
			case 3:
				spawnrate = hugespawn;
				health = hugehealth;
				maxmonsters = hugemax;

				for ( i = 0; i < 5; i++ )
					allowedmonster[i] = hugeallow[i];
				break;
		}

	spawnedgate = getgate(thegate);
	if (spawnedgate != None)
	{
		spawnedgate.health = health;
		spawnedgate.default.health = health;
		spawnedgate.maxhealth = health;
		spawnedgate.default.maxhealth = health;
		spawnedgate.timetillnext = spawnrate;
		spawnedgate.maxmonsters = maxmonsters;
		spawnedgate.dmodelsetup();
		for ( i = 0; i < 5; i++ )
			spawnedgate.allowedmonster[i] = allowedmonster[i];
		numgates++;
	}
}

function PostBeginPlay()
{
	local pathnode pn;
	local botreplicationinfo b;
//	local int jonbob;
	local gateways myGate;
//	local int j;
//	local Mutator m;
	local int i;
	local int maxtotal;
	local int mingates;
	local int SmallPerLoop;
	local int MedPerLoop;
	local int BigPerLoop;
	local int HugePerLoop;
	local int GiantPerLoop;
	local int SpawnLoop;
	
	super.postbeginplay();

	//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	// Stuff set here so all the other classes will have it DO NOT REMOVE
	//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	ScoreBoardType = Class'GauntletScoreBoard';

	log("//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
	log("ScoreBoardType:"@ScoreBoardType);
	log("//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");

	// Spawn the statistics
	StatisticsManager = Spawn(class'GauntletStatistics',self);

	log("");
	log("");
	log("");
	log("");
	log("");
	log("=-*-=-*-=-*-=-*-=-*-=-*-=-*-=-*-=-*-=-*-=-*-=-*-=-*-=-*-=-*-=-*-=-*-=-*-=-*-=-*-=");
	log("=-*-=-*-=-*-=-*-=-* Gauntlet Statistics Manager Created =-*-=-*-=-*-=-*-=-*-=-*-=");
	log("=-*-=-*-=-*-=-*-=-*-=-*-=-*-=-*-=-*-=-*-=-*-=-*-=-*-=-*-=-*-=-*-=-*-=-*-=-*-=-*-=");
	log("");

	StatisticsManager.Start();
	bBalanceTeams = false;

	foreach allactors(class'pathnode',pn)
	{
		if( numpoints < NoLevelNodes )
		{
			levelNodes[numpoints] = pn;
			NodeTaken[numpoints]=EB_False;
		}
		numpoints++;
	}
	
	//	PHS, 2024-02-06. Ensure non used levelNodes[] are cleared.
	for(i=numpoints+1; i < NoLevelNodes; i++)
	{
		levelNodes[i]=None;
		NodeTaken[numpoints]=EB_True;
	}
	log("Number of nodes allocated: "@numpoints);
	
	foreach allactors(class'gateways',myGate)
	{
		if ( myGate != none )
		{
			bLevelGatesSet = true;
			return;
		}
		else
			continue;
	}

	// calculate total gates needed....
	maxtotal = maxsmall + maxmed + maxbig + maxhuge + maxgiant;

	// Find the lowest gate total
	mingates = maxsmall;
	mingates = min(mingates, maxmed);
	mingates = min(mingates, maxbig);
	mingates = min(mingates, maxhuge);
	mingates = min(mingates, maxgiant);
	
	// Work out how many of each gate type per gate spawn loop. 
	// One of these should work out as 1 (the one that is the minimum).
	SmallPerLoop 	= maxsmall / mingates;
	MedPerLoop		= maxmed / mingates;
	BigPerLoop		= maxbig / mingates;
	HugePerLoop		= maxhuge / mingates;
	GiantPerLoop	= maxgiant / mingates;
	
	log("minimum gate count: "@mingates);
	log("SmallPerLoop="@SmallPerLoop@" MedPerLoop="@MedPerLoop@" BigPerLoop="@BigPerLoop@"HugePerLoop="@HugePerLoop@"GiantPerLoop="@GiantPerLoop);

	// loop over gates, spawning them.
	if( !bLevelgatesSet )
	{
		for ( SpawnLoop = 0; SpawnLoop < mingates ; SpawnLoop++)
		{
			for ( numsmall = 0; numsmall < SmallPerLoop; numsmall++ )
				setupgates(class'smallgate',0);
			for ( nummed = 0; nummed < MedPerLoop; nummed++ )
				setupgates(class'medgate',1);
			for ( numbig = 0; numbig < BigPerLoop; numbig++ )
				setupgates(class'biggate',2);
			for ( numhuge = 0; numhuge < HugePerLoop; numhuge++ )
				setupgates(class'hugegate',3);
			for ( numgiant = 0; numgiant < GiantPerLoop; numgiant++ )
				setupgates(class'giantgate',4);
		}
	}

	foreach AllActors(class'gateways',gw2)
	{
		totalgates++;
	}

	totalgatesleft=totalgates;

	foreach allactors(class'botreplicationinfo',b)
	{
		if ( b.team != 0 )
				b.team = 0;
	}

	u4egreplicationinfo(gamereplicationinfo).numberofgates=totalgates;
}

// Gateway was Destroyed!
function GateDestroyed(gateways DestroyedGate, pawn Destroyer,int PointWorth)
{
//        local int i;
		local gateways ThatGate;
		local int FoundGates;

		foreach allactors(class'gateways',ThatGate)
			{
				if ( ThatGate != none )
					FoundGates++;
			}

		// Let's see if a player destroyed this gateway or some dumb monster.
		if ( PlayerPawn(Destroyer) != None )
			{	
				// Award the gates value to the player
				Destroyer.PlayerReplicationInfo.Score += DestroyedGate.Reward;
				// Update score statistics for gates
				StatisticsManager.UpdateScoreFromGateways(PlayerPawn(Destroyer),DestroyedGate.Reward);
				// update total gates killed records
				StatisticsManager.UpdateGatesDestroyed(DestroyedGate, PlayerPawn(Destroyer));

				
			}

		TotalGatesLeft = FoundGates-1;
        // TotalGatesLeft--;

		// Um.. so we tell the Game replication info how many gates are left?
		// Does this actually work? oh well look into it later :\
		u4egreplicationinfo(gamereplicationinfo).numberofgates = TotalGatesLeft;

        // teams[0].score += PointWorth;

		// This is the time when Bosses Are Spawned!!
        if ( TotalGatesLeft <= 0 && !bSpawnedBoss )
			{
				MakeBoss(BossInitialNumber);
				u4egreplicationinfo(gamereplicationinfo).BossesAlive = BossesAlive;
			}
}

function Killed( pawn Killer, pawn Other, name damageType )
{
	if ( ScriptedPawn(Killer) != None && PlayerPawn(Other) != None )
		ScoreKill(Killer , Other);

	Super.Killed(Killer, Other, damageType );
}

function ScoreKill(pawn Killer, pawn Victim)
{
	if ( PlayerPawn(Victim) != None )
		{
			Victim.PlayerReplicationInfo.Deaths += 1;
		}
}

function bool ChangeTeam(Pawn Other, int N)
{
	Other.PlayerReplicationInfo.Team = 0;
	return true;
}

function bool IsOnTeam(Pawn Other, int TeamNum)
{
	if ( PlayerPawn(Other) == None )
		return false;

	if ( Other.PlayerReplicationInfo.Team == TeamNum )
		return true;

	return false;
}

function MakeBoss(int bossnum)
{
	local int i;
	local PathNode Node;
	local int NodeCount;
	local int Attempts;
	local int BossesSpawned;
	local ScriptedPawn SpawnedBoss;
	local class<ScriptedPawn> ChosenBoss;
	local int BossesAvailible;

	BossPosibilities[0] = class'boss1';
	BossPosibilities[1] = class'boss2';
	BossPosibilities[2] = class'boss3';
	BossPosibilities[3] = class'boss4';

	// Zero this so that we can detect if a spawned boss is killed straight away
	BossesAlive = 0;

	// AnnounceAll("Attempting to spawn a boss");

	foreach AllActors(class'PathNode',Node)
		NodeCount++;

	log("Node Count:"@NodeCount);

	for ( i = 0; i != ArrayCount(BossPosibilities) ; i++ )
		{
			if ( BossPosibilities[i] != None )
				{
					BossesAvailible++;
					log("There are"@BossesAvailible@"boss possibilities to be chosen from");
				}
			else
				break;
		}

	while ( true == true )
		{
			foreach AllActors(class'PathNode',Node)
				{
					if ( rand(NodeCount) == 0 )
						{
							log("Spawn Attempts:"@Attempts);
							
							// Choose A Boss
							ChosenBoss = BossPosibilities[Rand(BossesAvailible)];
							// Then Spawn It!
							SpawnedBoss = spawn(ChosenBoss,,,Node.location);
							
							if ( SpawnedBoss != None && bSpawnedBoss == false )
								{
									BossesSpawned++;
									log("bossnum"@bossnum);
									log("BossesSpawned"@BossesSpawned);
									if ( BossesSpawned == bossnum )
										break;
								}
							else
								Attempts++;
						}
					else
						{
							Attempts++;
							continue;
						}
				}
			
			// Keep looping until bosses are set up >:(
			if ( BossesSpawned == bossnum || Attempts >= MaxAttemptsSpawningBoss )
				break;
			else
				continue;
		}

	// Since we set BossesAlive to zero before spawning bosses, it may be less than zero
	// if any of the bosses have been killed immediately on spawning e.g. by telefragging,
	// environmental dangers. So we account for this here. 
	BossesAlive = BossesAlive + BossesSpawned;
	BroadcastLocalizedMessage( class'BossGateSpawned',0);
	bSpawnedBoss = true;
	u4egreplicationinfo(gamereplicationinfo).bSpawnedBoss =true;

}


/*
function MakeBoss(int bossnum)
{
        local int i,j;
//        local navigationpoint pn;
        local int randcrit;
        local int betterbenone;
        local pathnode pn;
        local int bob3,bob2;
        local earthquake q;

        bosscount=0; //this is an emergency quit
        betterbenone=0;

		AnnounceAll("We Tried to spawn a boss! did we succeed? (probally not) :\ ");


        foreach AllActors(class'gateways',gw2)
        {
                betterbenone++;
        }
        if (betterbenone>=1)
                return;
        

        i = Rand(numpoints);
	j = 0;
      do                              
      {
       bob3=rand(numpoints);
       bob2=0;
       foreach AllActors(class'PathNode',pn)
        {
                bob2++;
                if(bob2==bob3)
                {
                        randcrit=rand(4);
                        theboss[bossnum]=spawn(bosscritter[randcrit],,,pn.location);
                }
        }
       } until (theboss[bossnum]!=none)
       BroadcastLocalizedMessage( class'BossGateSpawned',0);
       bossinithealth[bossnum]=theboss[bossnum].health-regenamount;

       bSpawnedBoss=true;
       u4egreplicationinfo(gamereplicationinfo).bSpawnedBoss=true;
}
*/

function bool AddBot()
{
        local bot NewBot; //, myBot;
	local NavigationPoint StartSpot;
        local int numGates; //,numbots;
        numGates=maxSmall+maxMed+maxBig+maxhuge;
        numGates=numgates/3;

/*        foreach allactors(class'bot',myBot)
        {
                numbots++;
        }
        if(numBots>=numGates)
                return false;*/
	NewBot = SpawnBot(StartSpot);
	if ( NewBot == None )
	{
//                log("Failed to spawn bot.");
		return false;
	}

	StartSpot.PlayTeleportEffect(NewBot, true);

	NewBot.PlayerReplicationInfo.bIsABot = True;

	// Log it.
	if (LocalLog != None)
	{
		LocalLog.LogPlayerConnect(NewBot);
		LocalLog.FlushLog();
	}
	if (WorldLog != None)
	{
		WorldLog.LogPlayerConnect(NewBot);
		WorldLog.FlushLog();
	}
        newbot.playerreplicationinfo.team=0;
	return true;
}

function StartMatch()
{
	super.StartMatch();
	log("GAME START");

	if (numpoints ==0)
	{
		EndGame("No spawn points!");
	}
}


function EndGame( string Reason )
{
	log("===============================================================");

	log("Reason:"@Reason);

	if ( reason == "timelimit" )
	{
		// You Lost!
		Teams[0].score= -1;
		log(MessageGameEndLose);
		StatisticsManager.GameEnded(false);
	}
	else
	{
		log(MessageGameEndWin);
		StatisticsManager.GameEnded(true);
	}

	log("===============================================================");
	super.EndGame(Reason);
}

function timer()
{
        local int i;
		local Pawn P;

        super.timer();
        if(bSpawnedBoss && bBossregen)
        {
                for( i = 0; i < BossInitialNumber; i++ )
                {
                        
                        if(theboss[i]!=none && theboss[i].health<bossinithealth[i])
                                theboss[i].health+=regenamount;
                }
        }

		// My simple attempt to fix monster waking up before game and generaly just being retarded
		//...well on a second thought can't fix everything! lol.

		if ( bNetReady )
		{
			for (P=Level.PawnList; P!=None; P=P.NextPawn )
				if ( P.IsA('PlayerPawn') )
					PlayerPawn(P).Health = 0;
			return;
		}
}

function bosskilled()
{
	BossesAlive--;
	u4egreplicationinfo(gamereplicationinfo).BossesAlive = BossesAlive;
	
	// Only end the game *IF* the bosses have finished spawning, this prevents
	// a boss being killed whilst spawning from ending the game prematurely.
	if (( BossesAlive <= 0 ) && (bSpawnedBoss == true))
		endgame("teamscorelimit");
}

function MonsterKilled(int Value, pawn Killer, scriptedpawn Victim)
{
//	local int RefrenceInt;
//	local String NexGenId;
		
	if ( PlayerPawn(Killer) != None )
		{
			// Award the points
			Killer.PlayerReplicationInfo.Score += Value;

			// Test Statistics
			// NexGenId = Stats.GetPlayerID(PlayerPawn(Killer));
			// Stats.Message(Killer.PlayerReplicationInfo.PlayerName$"'s ID:"@NexGenID);

			// Have Statictics Update The Score From Monsters
			StatisticsManager.UpdateScoreFromMonsters(PlayerPawn(Killer), Value);

			// Record historical information about killed monsters
			// StatisticsManager.UpdateMonstersKilled(PlayerPawn(Killer), Victim);
		}

}

function MonsterXXXXXXXXXKilled(int Value, pawn Killer, scriptedpawn Victim)
{
//	local int RefrenceInt;
//	local String NexGenId;
		
	if ( PlayerPawn(Killer) != None )
		{
			// Award the points
			Killer.PlayerReplicationInfo.Score += Value;

			// Test Statistics
			// NexGenId = Stats.GetPlayerID(PlayerPawn(Killer));
			// Stats.Message(Killer.PlayerReplicationInfo.PlayerName$"'s ID:"@NexGenID);

			// Have Statictics Update The Score From Monsters
			StatisticsManager.UpdateScoreFromMonsters(PlayerPawn(Killer), Value);

			// Record historical information about killed monsters
			// StatisticsManager.UpdateMonstersKilled(PlayerPawn(Killer), Victim);
		}

}

function AnnounceAll(string sMessage)
{
    local Pawn p;

    for ( p = Level.PawnList; p != None; p = p.nextPawn )
	    if ( (p.bIsPlayer || p.IsA('MessagingSpectator')) &&
          p.PlayerReplicationInfo != None  )
		    p.ClientMessage(sMessage);
}

function bool SetEndCams(string Reason)
{
	local pawn P, Best;
	local PlayerPawn Player;
	local gateways Gate;
	local ScriptedPawn Boss;

	// find individual winner
	for ( P=Level.PawnList; P!=None; P=P.nextPawn )
		if ( P.bIsPlayer && !P.IsA('Spectator') && ((Best == None) || (P.PlayerReplicationInfo.Score > Best.PlayerReplicationInfo.Score)) )
			Best = P;

	// check for tie
	for ( P=Level.PawnList; P!=None; P=P.nextPawn )
		if ( P.bIsPlayer && (Best != P) && (P.PlayerReplicationInfo.Score == Best.PlayerReplicationInfo.Score) )
		{
			BroadcastLocalizedMessage( DMMessageClass, 0 );
			return false;
		}		

	EndTime = Level.TimeSeconds + 3.0;
	GameReplicationInfo.GameEndedComments = Best.PlayerReplicationInfo.PlayerName@GameEndedMessage;
	GameReplicationInfo.GameEndedComments = "";
	log( "Game ended at "$EndTime);
	for ( P=Level.PawnList; P!=None; P=P.nextPawn )
	{
		Player = PlayerPawn(P);
		if ( Player != None )
		{
			if (!bTutorialGame)
				PlayWinMessage(Player, (Player == Best));
			Player.bBehindView = true;
			if ( Player == Best )
				Player.ViewTarget = None;
			else
				Player.ViewTarget = Best;
			
			if ( MessageGameEndWin == "" )
				{
					MessageGameEndWin = "Invasion stopped! Your Team Is Victorious!";
					SaveConfig();
				}
				
			if ( MessageGameEndLose == "" )
				{
					MessageGameEndLose = "The monsters have invaded! GAME OVER!!";
					SaveConfig();
				}

			if ( Reason != "timelimit" )
				{
					u4egreplicationinfo(gamereplicationinfo).GameVerdict = "Win";
					GameReplicationInfo.GameEndedComments = MessageGameEndWin;
				}
			else
				{
					u4egreplicationinfo(gamereplicationinfo).GameVerdict = "Fail";
					GameReplicationInfo.GameEndedComments = MessageGameEndLose;
				}
				
			ForEach AllActors(class'gateways',Gate)
			{
				Player.ViewTarget = Gate;
				break;
			}
			
			ForEach AllActors(class'ScriptedPawn',Boss)
			{
				if ( Reason != "timelimit" )
					break;
				
				if ( Boss1(Boss) != None || Boss2(Boss) != None || Boss3(Boss) != None || Boss4(Boss) != None )
					{
						Player.ViewTarget = Boss;
						break;
					}
			}			
			Player.ClientGameEnded();
		}
		P.GotoState('GameEnded');
	}
	CalcEndStats();
	return true;
}

defaultproperties
{
      NumPoints=0
      Number=0
      numSmall=0
      nummed=0
      numbig=0
      numhuge=0
      numgiant=0
      maxsmall=24
      maxmed=18
      maxbig=12
      maxhuge=9
      maxgiant=3
      smallhealth=1000
      medhealth=2000
      bighealth=3000
      hugehealth=4000
      gianthealth=10000
      smallspawn=2
      medspawn=3
      bigspawn=4
      hugespawn=5
      giantspawn=5
      smallmax=20
      medmax=15
      bigmax=10
      hugemax=5
      giantmax=5
      smallallow(0)=1
      smallallow(1)=1
      smallallow(2)=1
      smallallow(3)=1
      smallallow(4)=1
      medallow(0)=1
      medallow(1)=1
      medallow(2)=1
      medallow(3)=1
      medallow(4)=1
      bigallow(0)=1
      bigallow(1)=1
      bigallow(2)=1
      bigallow(3)=1
      bigallow(4)=1
      hugeallow(0)=1
      hugeallow(1)=1
      hugeallow(2)=1
      hugeallow(3)=1
      hugeallow(4)=1
      giantallow(0)=0
      giantallow(1)=0
      giantallow(2)=0
      giantallow(3)=0
      giantallow(4)=0
      bBossRegen=False
      regenamount=10
      AllowRoaming=False
      SafeLightScale=0.250000
      totalgates=0
      totalgatesleft=0
      gw2=None
      navip=None
      bSpawnedBoss=False
      theboss(0)=None
      theboss(1)=None
      theboss(2)=None
      theboss(3)=None
      bossinithealth(0)=0
      bossinithealth(1)=0
      bossinithealth(2)=0
      bossinithealth(3)=0
      bLevelGatesSet=False
      levelNodes(0)=None
      levelNodes(1)=None
      levelNodes(2)=None
      levelNodes(3)=None
      levelNodes(4)=None
      levelNodes(5)=None
      levelNodes(6)=None
      levelNodes(7)=None
      levelNodes(8)=None
      levelNodes(9)=None
      levelNodes(10)=None
      levelNodes(11)=None
      levelNodes(12)=None
      levelNodes(13)=None
      levelNodes(14)=None
      levelNodes(15)=None
      levelNodes(16)=None
      levelNodes(17)=None
      levelNodes(18)=None
      levelNodes(19)=None
      levelNodes(20)=None
      levelNodes(21)=None
      levelNodes(22)=None
      levelNodes(23)=None
      levelNodes(24)=None
      levelNodes(25)=None
      levelNodes(26)=None
      levelNodes(27)=None
      levelNodes(28)=None
      levelNodes(29)=None
      levelNodes(30)=None
      levelNodes(31)=None
      levelNodes(32)=None
      levelNodes(33)=None
      levelNodes(34)=None
      levelNodes(35)=None
      levelNodes(36)=None
      levelNodes(37)=None
      levelNodes(38)=None
      levelNodes(39)=None
      levelNodes(40)=None
      levelNodes(41)=None
      levelNodes(42)=None
      levelNodes(43)=None
      levelNodes(44)=None
      levelNodes(45)=None
      levelNodes(46)=None
      levelNodes(47)=None
      levelNodes(48)=None
      levelNodes(49)=None
      levelNodes(50)=None
      levelNodes(51)=None
      levelNodes(52)=None
      levelNodes(53)=None
      levelNodes(54)=None
      levelNodes(55)=None
      levelNodes(56)=None
      levelNodes(57)=None
      levelNodes(58)=None
      levelNodes(59)=None
      levelNodes(60)=None
      levelNodes(61)=None
      levelNodes(62)=None
      levelNodes(63)=None
      levelNodes(64)=None
      levelNodes(65)=None
      levelNodes(66)=None
      levelNodes(67)=None
      levelNodes(68)=None
      levelNodes(69)=None
      levelNodes(70)=None
      levelNodes(71)=None
      levelNodes(72)=None
      levelNodes(73)=None
      levelNodes(74)=None
      levelNodes(75)=None
      levelNodes(76)=None
      levelNodes(77)=None
      levelNodes(78)=None
      levelNodes(79)=None
      levelNodes(80)=None
      levelNodes(81)=None
      levelNodes(82)=None
      levelNodes(83)=None
      levelNodes(84)=None
      levelNodes(85)=None
      levelNodes(86)=None
      levelNodes(87)=None
      levelNodes(88)=None
      levelNodes(89)=None
      levelNodes(90)=None
      levelNodes(91)=None
      levelNodes(92)=None
      levelNodes(93)=None
      levelNodes(94)=None
      levelNodes(95)=None
      levelNodes(96)=None
      levelNodes(97)=None
      levelNodes(98)=None
      levelNodes(99)=None
      levelNodes(100)=None
      levelNodes(101)=None
      levelNodes(102)=None
      levelNodes(103)=None
      levelNodes(104)=None
      levelNodes(105)=None
      levelNodes(106)=None
      levelNodes(107)=None
      levelNodes(108)=None
      levelNodes(109)=None
      levelNodes(110)=None
      levelNodes(111)=None
      levelNodes(112)=None
      levelNodes(113)=None
      levelNodes(114)=None
      levelNodes(115)=None
      levelNodes(116)=None
      levelNodes(117)=None
      levelNodes(118)=None
      levelNodes(119)=None
      levelNodes(120)=None
      levelNodes(121)=None
      levelNodes(122)=None
      levelNodes(123)=None
      levelNodes(124)=None
      levelNodes(125)=None
      levelNodes(126)=None
      levelNodes(127)=None
      levelNodes(128)=None
      levelNodes(129)=None
      levelNodes(130)=None
      levelNodes(131)=None
      levelNodes(132)=None
      levelNodes(133)=None
      levelNodes(134)=None
      levelNodes(135)=None
      levelNodes(136)=None
      levelNodes(137)=None
      levelNodes(138)=None
      levelNodes(139)=None
      levelNodes(140)=None
      levelNodes(141)=None
      levelNodes(142)=None
      levelNodes(143)=None
      levelNodes(144)=None
      levelNodes(145)=None
      levelNodes(146)=None
      levelNodes(147)=None
      levelNodes(148)=None
      levelNodes(149)=None
      levelNodes(150)=None
      levelNodes(151)=None
      levelNodes(152)=None
      levelNodes(153)=None
      levelNodes(154)=None
      levelNodes(155)=None
      levelNodes(156)=None
      levelNodes(157)=None
      levelNodes(158)=None
      levelNodes(159)=None
      levelNodes(160)=None
      levelNodes(161)=None
      levelNodes(162)=None
      levelNodes(163)=None
      levelNodes(164)=None
      levelNodes(165)=None
      levelNodes(166)=None
      levelNodes(167)=None
      levelNodes(168)=None
      levelNodes(169)=None
      levelNodes(170)=None
      levelNodes(171)=None
      levelNodes(172)=None
      levelNodes(173)=None
      levelNodes(174)=None
      levelNodes(175)=None
      levelNodes(176)=None
      levelNodes(177)=None
      levelNodes(178)=None
      levelNodes(179)=None
      levelNodes(180)=None
      levelNodes(181)=None
      levelNodes(182)=None
      levelNodes(183)=None
      levelNodes(184)=None
      levelNodes(185)=None
      levelNodes(186)=None
      levelNodes(187)=None
      levelNodes(188)=None
      levelNodes(189)=None
      levelNodes(190)=None
      levelNodes(191)=None
      levelNodes(192)=None
      levelNodes(193)=None
      levelNodes(194)=None
      levelNodes(195)=None
      levelNodes(196)=None
      levelNodes(197)=None
      levelNodes(198)=None
      levelNodes(199)=None
      levelNodes(200)=None
      levelNodes(201)=None
      levelNodes(202)=None
      levelNodes(203)=None
      levelNodes(204)=None
      levelNodes(205)=None
      levelNodes(206)=None
      levelNodes(207)=None
      levelNodes(208)=None
      levelNodes(209)=None
      levelNodes(210)=None
      levelNodes(211)=None
      levelNodes(212)=None
      levelNodes(213)=None
      levelNodes(214)=None
      levelNodes(215)=None
      levelNodes(216)=None
      levelNodes(217)=None
      levelNodes(218)=None
      levelNodes(219)=None
      levelNodes(220)=None
      levelNodes(221)=None
      levelNodes(222)=None
      levelNodes(223)=None
      levelNodes(224)=None
      levelNodes(225)=None
      levelNodes(226)=None
      levelNodes(227)=None
      levelNodes(228)=None
      levelNodes(229)=None
      levelNodes(230)=None
      levelNodes(231)=None
      levelNodes(232)=None
      levelNodes(233)=None
      levelNodes(234)=None
      levelNodes(235)=None
      levelNodes(236)=None
      levelNodes(237)=None
      levelNodes(238)=None
      levelNodes(239)=None
      levelNodes(240)=None
      levelNodes(241)=None
      levelNodes(242)=None
      levelNodes(243)=None
      levelNodes(244)=None
      levelNodes(245)=None
      levelNodes(246)=None
      levelNodes(247)=None
      levelNodes(248)=None
      levelNodes(249)=None
      levelNodes(250)=None
      levelNodes(251)=None
      levelNodes(252)=None
      levelNodes(253)=None
      levelNodes(254)=None
      StatisticsManager=None
      MessageGameEndWin="Invasion stopped! Your Team Is Victorious!"
      MessageGameEndLose="The monsters have invaded! GAME OVER!!"
      MaxAttemptsSpawningBoss=10000
      UseTreeSpawnMethodForGates=False
      BossInitialNumber=21
      BossPosibilities(0)=Class'Gauntlet-10-BetaV4.boss1'
      BossPosibilities(1)=Class'Gauntlet-10-BetaV4.boss2'
      BossPosibilities(2)=Class'Gauntlet-10-BetaV4.boss3'
      BossPosibilities(3)=Class'Gauntlet-10-BetaV4.boss4'
      BossPosibilities(4)=None
      BossPosibilities(5)=None
      BossPosibilities(6)=None
      BossPosibilities(7)=None
      BossPosibilities(8)=None
      BossPosibilities(9)=None
      BossPosibilities(10)=None
      BossPosibilities(11)=None
      BossesAlive=0
      bBalanceTeams=False
      bPlayersBalanceTeams=False
      GoalTeamScore=0.000000
      FragLimit=0
      TimeLimit=20
      NetWait=0
      StartUpMessage="Destroy the monster gateways!"
      MaxCommanders=0
      InitialBots=0
      bNoMonsters=False
      bNoCheating=False
      bAllowFOV=True
      GameSpeed=1.200000
      MaxSpectators=5
      AdminPassword="vYnunpAw9Xxgxd9ScTh4uyzf"
      BotMenuType="gateway.gatewaybotconfig"
      HUDType=Class'Gauntlet-10-BetaV4.gauntletHUD'
      MapListType=Class'Gauntlet-10-BetaV4.GauntletMapList'
      MapPrefix=""
      GameName="Wildcards Gauntlet"
      MaxPlayers=10
      GameReplicationInfoClass=Class'Gauntlet-10-BetaV4.u4egreplicationinfo'
      ServerLogName="Superserver.log"
      bWorldLog=False
      ActionToTake=DO_Log
}
