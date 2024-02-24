//=============================================================================
// GauntletPlayerReplicationInfo.
//=============================================================================
class GauntletPlayerReplicationInfo expands PlayerReplicationInfo;

// Important Variables Regarding Identification
var string StatSlot;
var string ClientID;

var string RankTitlePrevious;
var string RankTitle;
var string RankTitleNext;

var string RankServer;
var string RankRegisteredPlayers;

var string ScoreBoardPage;
var bool Ready;

var GauntletStatistics StatisticsManager;

// STATISTIC Varibales

	// Class I Monsters
	var string Gasbag;
	var string Fly;
	var string Pupae;
	var string Mullog;

	// Class II Monsters
	var string Skaarj;
	var string Manta;
	var string Booger, SlimeBooger, IceBooger, FireBooger;
	var string Krail;
	var string Brute;

	// Class III Monsters
	var string Mercenary;
	var string Hank;
	var string KrallElite;
	var string GiantGasbag;
	var string Yeti;

	// Class IV Monsters
	var string LesserAngel, Angel, BattleAngel, WarAngel, ArchAngel, SolarGoddess;
	var string Maiden, Spinner;
	var string MAX;
	var string WarLord;
	var string Torchurer;

	// GATEWAYS

	// Class I Gateways
	var string GateGasbag;
	var string GateFly;
	var string GatePupae;
	var string GateMullog;

	// Class II Gateways
	var string GateSkaarj;
	var string GateManta;
	var string GateBooger;
	var string GateKrail;
	var string GateBrute;

	// Class III Gateways
	var string GateMercenary;
	var string GateHank;
	var string GateKrallElite;
	var string GateGiantGasbag;
	var string GateYeti;

	// Class IV Gateways
	var string GateAngel;
	var string GateMaiden;
	var string GateMAX;
	var string GateWarLord;
	var string GateTorchurer;

	// Game Statistics! 
	var string Wins;
	var string Losses;
	var string Leads;
	var string AllTimeScore;
	var string ScoreFromMonsters;
	var string ScoreFromGateways;

replication
{
	// Main
	reliable if ( Role == ROLE_Authority )
		StatSlot, ClientID,
		RankTitlePrevious, RankTitle, RankTitleNext,
		RankServer, RankRegisteredPlayers, Ready, ScoreBoardPage;

	// Monsters
	reliable if ( Role == ROLE_Authority )
		Gasbag, Fly, Pupae, Mullog, Skaarj, Manta, Booger, SlimeBooger, IceBooger, FireBooger,
		Krail, Brute, Mercenary, Hank, KrallElite, GiantGasbag, Yeti, LesserAngel, Angel,
		BattleAngel, WarAngel, ArchAngel, SolarGoddess, MAX, WarLord, Torchurer, Maiden, Spinner;

	// Gates
	reliable if ( Role == ROLE_Authority )
		GateGasbag, GateFly, GatePupae, GateMullog, GateSkaarj, GateManta, GateBooger, GateKrail, 
		GateBrute, GateMercenary, GateHank, GateKrallElite, GateGiantGasbag, GateYeti, GateAngel, 
		GateMAX, GateWarLord, GateTorchurer, GateMaiden;
	// Game Statistics
	reliable if ( Role == ROLE_Authority )
		Wins, Losses, Leads, AllTimeScore, ScoreFromMonsters, ScoreFromGateways;
}

function PostBeginPlay()
{
	ClientID = "";
	StatSlot = "";
	Ready = false;
	TurnPage();
	Super.PostBeginPlay();
}

function TurnPage()
{
	if ( ScoreBoardPage == "" )
		{
			ScoreBoardPage = "Current Scores";
			return;
		}
	if ( ScoreBoardPage == "Current Scores" )
		{
			ScoreBoardPage = "Top Ten Players";
			return;
		}
	if ( ScoreBoardPage == "Top Ten Players" )
		{
			ScoreBoardPage = "Personal Statistics";
			return;
		}
	if ( ScoreBoardPage == "Personal Statistics" )
		{
			ScoreBoardPage = "Current Scores";
			return;
		}
}

defaultproperties
{
      StatSlot=""
      ClientID=""
      RankTitlePrevious=""
      RankTitle=""
      RankTitleNext=""
      RankServer=""
      RankRegisteredPlayers=""
      ScoreBoardPage=""
      Ready=False
      StatisticsManager=None
      Gasbag=""
      Fly=""
      Pupae=""
      Mullog=""
      Skaarj=""
      Manta=""
      booger=""
      SlimeBooger=""
      IceBooger=""
      FireBooger=""
      Krail=""
      Brute=""
      Mercenary=""
      hank=""
      KrallElite=""
      GiantGasbag=""
      Yeti=""
      LesserAngel=""
      angel=""
      BattleAngel=""
      WarAngel=""
      ArchAngel=""
      SolarGoddess=""
      maiden=""
      spinner=""
      Max=""
      WarLord=""
      Torchurer=""
      gategasbag=""
      gateFly=""
      gatePupae=""
      GateMullog=""
      GateSkaarj=""
      GateManta=""
      gatebooger=""
      GateKrail=""
      gateBrute=""
      GateMercenary=""
      gatehank=""
      gateKrallElite=""
      GateGiantGasbag=""
      GateYeti=""
      GateAngel=""
      gateMaiden=""
      GateMAX=""
      gateWarLord=""
      GateTorchurer=""
      Wins=""
      Losses=""
      Leads=""
      AllTimeScore=""
      ScoreFromMonsters=""
      ScoreFromGateways=""
}
