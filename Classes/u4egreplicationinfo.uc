class u4egreplicationinfo expands TournamentGameReplicationInfo;

var int numberofgates;
var bool bSpawnedBoss;
var int BossesAlive;
var string GameVerdict;

var int RegisteredPlayers;

// For the Top Ten that's why I made the array 24 right? :P byte me
var string TopNames[24];
var string TopTitles[24];
var int TopScores[24];
var int TopWins[24];
var int TopLosses[24];
var int TopLeads[24];


replication
{
	// Things the server should send to the client.
	reliable if ( Role == ROLE_Authority )
                numberofgates, bSpawnedBoss, BossesAlive, GameVerdict, RegisteredPlayers,
				TopNames, TopScores, TopWins, TopLosses, TopLeads, TopTitles;
}

defaultproperties
{
      numberofgates=0
      bSpawnedBoss=False
      BossesAlive=0
      GameVerdict=""
      RegisteredPlayers=0
      TopNames(0)=""
      TopNames(1)=""
      TopNames(2)=""
      TopNames(3)=""
      TopNames(4)=""
      TopNames(5)=""
      TopNames(6)=""
      TopNames(7)=""
      TopNames(8)=""
      TopNames(9)=""
      TopNames(10)=""
      TopNames(11)=""
      TopNames(12)=""
      TopNames(13)=""
      TopNames(14)=""
      TopNames(15)=""
      TopNames(16)=""
      TopNames(17)=""
      TopNames(18)=""
      TopNames(19)=""
      TopNames(20)=""
      TopNames(21)=""
      TopNames(22)=""
      TopNames(23)=""
      TopTitles(0)=""
      TopTitles(1)=""
      TopTitles(2)=""
      TopTitles(3)=""
      TopTitles(4)=""
      TopTitles(5)=""
      TopTitles(6)=""
      TopTitles(7)=""
      TopTitles(8)=""
      TopTitles(9)=""
      TopTitles(10)=""
      TopTitles(11)=""
      TopTitles(12)=""
      TopTitles(13)=""
      TopTitles(14)=""
      TopTitles(15)=""
      TopTitles(16)=""
      TopTitles(17)=""
      TopTitles(18)=""
      TopTitles(19)=""
      TopTitles(20)=""
      TopTitles(21)=""
      TopTitles(22)=""
      TopTitles(23)=""
      TopScores(0)=0
      TopScores(1)=0
      TopScores(2)=0
      TopScores(3)=0
      TopScores(4)=0
      TopScores(5)=0
      TopScores(6)=0
      TopScores(7)=0
      TopScores(8)=0
      TopScores(9)=0
      TopScores(10)=0
      TopScores(11)=0
      TopScores(12)=0
      TopScores(13)=0
      TopScores(14)=0
      TopScores(15)=0
      TopScores(16)=0
      TopScores(17)=0
      TopScores(18)=0
      TopScores(19)=0
      TopScores(20)=0
      TopScores(21)=0
      TopScores(22)=0
      TopScores(23)=0
      TopWins(0)=0
      TopWins(1)=0
      TopWins(2)=0
      TopWins(3)=0
      TopWins(4)=0
      TopWins(5)=0
      TopWins(6)=0
      TopWins(7)=0
      TopWins(8)=0
      TopWins(9)=0
      TopWins(10)=0
      TopWins(11)=0
      TopWins(12)=0
      TopWins(13)=0
      TopWins(14)=0
      TopWins(15)=0
      TopWins(16)=0
      TopWins(17)=0
      TopWins(18)=0
      TopWins(19)=0
      TopWins(20)=0
      TopWins(21)=0
      TopWins(22)=0
      TopWins(23)=0
      TopLosses(0)=0
      TopLosses(1)=0
      TopLosses(2)=0
      TopLosses(3)=0
      TopLosses(4)=0
      TopLosses(5)=0
      TopLosses(6)=0
      TopLosses(7)=0
      TopLosses(8)=0
      TopLosses(9)=0
      TopLosses(10)=0
      TopLosses(11)=0
      TopLosses(12)=0
      TopLosses(13)=0
      TopLosses(14)=0
      TopLosses(15)=0
      TopLosses(16)=0
      TopLosses(17)=0
      TopLosses(18)=0
      TopLosses(19)=0
      TopLosses(20)=0
      TopLosses(21)=0
      TopLosses(22)=0
      TopLosses(23)=0
      TopLeads(0)=0
      TopLeads(1)=0
      TopLeads(2)=0
      TopLeads(3)=0
      TopLeads(4)=0
      TopLeads(5)=0
      TopLeads(6)=0
      TopLeads(7)=0
      TopLeads(8)=0
      TopLeads(9)=0
      TopLeads(10)=0
      TopLeads(11)=0
      TopLeads(12)=0
      TopLeads(13)=0
      TopLeads(14)=0
      TopLeads(15)=0
      TopLeads(16)=0
      TopLeads(17)=0
      TopLeads(18)=0
      TopLeads(19)=0
      TopLeads(20)=0
      TopLeads(21)=0
      TopLeads(22)=0
      TopLeads(23)=0
}
