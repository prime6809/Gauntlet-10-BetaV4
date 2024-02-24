//=============================================================================
// GauntletScoreBoard.
// Written by nOs*Wildcard
//=============================================================================
class GauntletScoreBoard expands TournamentScoreBoard;

var float RowSpace;
var string ScoreBoardPage;
var GauntletHud GHUD;
var string PreviousMessage;

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
			if ( Spectator(Owner) == None )
				ScoreBoardPage = "Personal Statistics";
			else
				ScoreBoardPage = "Current Scores";
			return;
		}
	if ( ScoreBoardPage == "Personal Statistics" )
		{
			ScoreBoardPage = "Current Scores";
			return;
		}
}

function DrawCategoryHeaders(Canvas Canvas)
{
//	local float Offset, XL, YL;
/*
	Offset = Canvas.ClipX * 0.15;
	Canvas.DrawColor = WhiteColor;

	Canvas.StrLen(PlayerString, XL, YL);
	Canvas.SetPos((Canvas.ClipX / 8)*2 - XL/2, Offset);
	Canvas.DrawText(PlayerString);

	Canvas.StrLen("Score", XL, YL);
	Canvas.SetPos((Canvas.ClipX / 8)*5 - XL/2, Offset);
	Canvas.DrawText("Score");

	Canvas.StrLen(DeathsString, XL, YL);
	Canvas.SetPos((Canvas.ClipX / 8)*6 - XL/2, Offset);
	Canvas.DrawText(DeathsString);
*/
}

function DrawHeader( canvas Canvas )
{
	local GameReplicationInfo GRI;
	local float XL, YL;
	local font CanvasFont;

	Canvas.DrawColor = WhiteColor;
	GRI = PlayerPawn(Owner).GameReplicationInfo;

	Canvas.Font = MyFonts.GetHugeFont(Canvas.ClipX);

	Canvas.bCenter = True;
	Canvas.StrLen("Test", XL, YL);
	ScoreStart = 58.0/768.0 * Canvas.ClipY;
	CanvasFont = Canvas.Font;
	if ( GRI.GameEndedComments != "" )
	{
		Canvas.DrawColor = GoldColor;
		Canvas.SetPos(0, ScoreStart);
		Canvas.DrawText(GRI.GameEndedComments, True);
	}
	else
	{
		Canvas.SetPos(0, ScoreStart);
		DrawVictoryConditions(Canvas);
	}
	Canvas.bCenter = False;
	Canvas.Font = CanvasFont;
}

function DrawVictoryConditions(Canvas Canvas)
{
	local TournamentGameReplicationInfo TGRI;
	local float YL; //XL;

	TGRI = TournamentGameReplicationInfo(PlayerPawn(Owner).GameReplicationInfo);
	if ( TGRI == None )
		return;

	Canvas.SetPos(0, (Canvas.CurY - YL)*0.7);
	Canvas.DrawText(TGRI.GameName);

/*
	Canvas.StrLen("Test", XL, YL);
	Canvas.SetPos(0, (Canvas.CurY - YL)*0.8);

	Canvas.DrawText(TimeLimit@TGRI.TimeLimit$":00");
*/
}

function DrawName(Canvas Canvas, PlayerReplicationInfo PRI, float XOffset, float YOffset, float YOffsetNext, optional bool DrawHead )
{
	local float XL, YL, XL2; //, YL2, XL3, YL3;
//	local Font CanvasFont;
	local bool bLocalPlayer;
	local PlayerPawn PlayerOwner;
//	local int Time, i;

//	local float DrawX, DrawY;
//	local float BorderSpace, NameSpacer;
	local float TextOffsetY;
	local float RowHeight;
	local float ScoreSlotX;
	local float HeadScale;
	local GauntletPlayerReplicationInfo GauntletPRI;

	local string QuickStats;

	PlayerOwner = PlayerPawn(Owner);
	GauntletPRI = GauntletPlayerReplicationInfo(PRI);

	TextOffsetY = 4;
	RowHeight = (YOffsetNext-YOffset);

	// Row Locations
	ScoreSlotX = Canvas.ClipX * 0.625 + XL * 0.5 - XL2;

	if ( DrawHead == true )
		{
			Canvas.DrawColor.r = 144; 
			Canvas.DrawColor.g = 0;
			Canvas.DrawColor.b = 255;

			HeadScale = Canvas.ClipY * 0.025;
			
			// BOTTOM FOOTER OF PAGE
			Canvas.Style = ERenderStyle.STY_Translucent;
			// LEFT
			Canvas.SetPos((Canvas.ClipX * 0.16)-RowHeight,(YOffset-TextOffsetY)-HeadScale);
			Canvas.DrawRect(texture'PageFooterLeft', 64, HeadScale);
			// CENTER
			Canvas.SetPos(((Canvas.ClipX * 0.16)-RowHeight)+64,(YOffset-TextOffsetY)-HeadScale);
			Canvas.DrawRect(texture'PageFooterCenter', (ScoreSlotX+(RowHeight*0.35))-64, HeadScale);
			// RIGHT
			Canvas.SetPos((((Canvas.ClipX * 0.16)-RowHeight)+64)+(ScoreSlotX+(RowHeight*0.35))-64,(YOffset-TextOffsetY)-HeadScale);
			Canvas.DrawRect(texture'PageFooterRight', 64, HeadScale);

			Canvas.DrawColor.r = 64; 
			Canvas.DrawColor.g = 144;
			Canvas.DrawColor.b = 255;

			// Draw Score
			Canvas.SetPos(Canvas.ClipX * 0.61, Canvas.ClipY * 0.19 );
			Canvas.DrawText("Score");

			// Draw Name
			Canvas.SetPos(Canvas.ClipX * 0.22, Canvas.ClipY * 0.19 );
			Canvas.DrawText("Player Name");

			// Draw Deaths
			Canvas.SetPos(Canvas.ClipX * 0.70, Canvas.ClipY * 0.19 );
			Canvas.DrawText("Deaths");

			Canvas.DrawColor = WhiteColor;

		}

	// Fancey Background
	Canvas.SetPos(Canvas.ClipX * 0.16, YOffset-TextOffsetY);
	Canvas.Style = ERenderStyle.STY_Modulated;
	Canvas.DrawRect(texture'RowBackground',ScoreSlotX , RowHeight);
	// Border Edge
	Canvas.SetPos((Canvas.ClipX * 0.16)+ScoreSlotX, YOffset-TextOffsetY);
	Canvas.DrawRect(texture'BorderEdge',RowHeight , RowHeight);

	// Reset Style To Normal
	Canvas.Style = ERenderStyle.STY_Normal;

	// Reset Color To Normal
	Canvas.DrawColor = WhiteColor;

	// Draw Player TalkTexture
	if ( PRI.TalkTexture == None )
		PRI.TalkTexture = texture'UnknownPlayer';
	Canvas.SetPos((Canvas.ClipX * 0.16)-RowHeight, YOffset-TextOffsetY);
	Canvas.DrawRect(texture'MenuBlack', RowHeight, RowHeight);
	Canvas.SetPos((Canvas.ClipX * 0.16)-RowHeight, YOffset-TextOffsetY);
	Canvas.DrawRect(PRI.TalkTexture, RowHeight, RowHeight);

	bLocalPlayer = (PRI.PlayerName == PlayerOwner.PlayerReplicationInfo.PlayerName);
	Canvas.Font = MyFonts.GetBigFont(Canvas.ClipX);

	// Draw Name
	if ( PRI.bAdmin )
		Canvas.DrawColor = WhiteColor;
	else if ( bLocalPlayer ) 
		Canvas.DrawColor = GoldColor;
	else 
		Canvas.DrawColor = CyanColor;
	
	
	Canvas.SetPos(Canvas.ClipX * 0.1875, YOffset);
	Canvas.DrawText(PRI.PlayerName, False);

	// Draw Title
	Canvas.Font = MyFonts.GetSmallFont(Canvas.ClipX);
	Canvas.SetPos(Canvas.ClipX * 0.1875, ((YOffset-TextOffsetY)+RowHeight)-16);

	QuickStats = "";
	QuickStats = QuickStats$"Server Rank:"@OrdinalNumber(GauntletPRI.RankServer)@"Of";
	QuickStats = QuickStats@u4egreplicationinfo(PlayerOwner.GameReplicationInfo).RegisteredPlayers;
	QuickStats = QuickStats@"Title:"@GauntletPRI.RankTitle;
	QuickStats = QuickStats@"";

	Canvas.DrawText(QuickStats, False);

/*
	Canvas.SetPos(Canvas.ClipX * 0.65, ((YOffset-TextOffsetY)+RowHeight)-16);

	QuickStats = "";
	QuickStats = QuickStats$"Ping:"@GauntletPRI.Ping;

	Canvas.DrawText(QuickStats, False);

	Canvas.StrLen( "0000", XL, YL );

	Canvas.Font = MyFonts.GetMediumFont(Canvas.ClipX*0.75);
*/

	// Draw Score
	if ( !bLocalPlayer )
		Canvas.DrawColor = LightCyanColor;

	Canvas.StrLen( int(PRI.Score), XL2, YL );
	Canvas.SetPos( Canvas.ClipX * 0.625 + XL * 0.5 - XL2, YOffset );
	Canvas.DrawText( int(PRI.Score), false );

	// Draw Deaths
	Canvas.StrLen( int(PRI.Deaths), XL2, YL );
	Canvas.SetPos( Canvas.ClipX * 0.75 + XL * 0.5 - XL2, YOffset );
	Canvas.DrawText( int(PRI.Deaths), false );

	/*

	if ( (Canvas.ClipX > 512) && (Level.NetMode != NM_Standalone) )
	{
		Canvas.DrawColor = WhiteColor;
		Canvas.Font = MyFonts.GetSmallestFont(Canvas.ClipX);

		// Draw Time
		Time = Max(1, (Level.TimeSeconds + PlayerOwner.PlayerReplicationInfo.StartTime - PRI.StartTime)/60);
		Canvas.TextSize( TimeString$": 999", XL3, YL3 );
		Canvas.SetPos( Canvas.ClipX * 0.75 + XL, YOffset );
		Canvas.DrawText( TimeString$":"@Time, false );

		// Draw FPH
		Canvas.TextSize( FPHString$": 999", XL2, YL2 );
		Canvas.SetPos( Canvas.ClipX * 0.75 + XL, YOffset + 0.5 * YL );
		Canvas.DrawText( FPHString$": "@int(60 * PRI.Score/Time), false );

		XL3 = FMax(XL3, XL2);
		// Draw Ping
		Canvas.SetPos( Canvas.ClipX * 0.75 + XL + XL3 + 16, YOffset );
		Canvas.DrawText( PingString$":"@PRI.Ping, false );
	}
	*/

}

function ShowScores( canvas Canvas )
{
	local PlayerReplicationInfo PRI;
	local GauntletPlayerReplicationInfo GPI;
	local int PlayerCount, i;
	local float XL, YL;
	local float YOffset, YStart;
	local float YOffsetNext;
	local font CanvasFont;
	local string text;
	local string text_value;
	local color GreyColor;
//	local float w_scale;

	local float column_x[8];
	local float row_y[8];
	local float row_progress[8];

	local int trim;
	local float text_width, text_height;

//	local float pagetitle_y;
//	local float CrownOffsetTop;
//	local float CrownOffsetBottom;

	local bool odd;

	GreyColor.R = 127;
	GreyColor.G = 127;
	GreyColor.B = 127;

	Canvas.Style = ERenderStyle.STY_Normal;

	if ( ScoreBoardPage == "" )
		{
			//PlayerPawn(Owner).ConsoleCommand("set input f3 mutate GauntletStatisticsFlipPage");
			PlayerPawn(Owner).ConsoleCommand("set input f3 set input Unknown8E TurnPage");
			log("--== ASSIGNED HOTKEY ==--");
			ScoreBoardPage = "Current Scores";
		}

	if ( PlayerPawn(Owner).ConsoleCommand("get input Unknown8E") == "TurnPage" )
		{
			PlayerPawn(Owner).ConsoleCommand("set input Unknown8E");
			TurnPage();
		}

	if ( u4egreplicationinfo(PlayerPawn(Owner).GameReplicationInfo).GameVerdict == "Fail" )
		{
			// FAIL! I mean... gameover you did your best :'(
			Canvas.SetPos(0,0);
			Canvas.Style = ERenderStyle.STY_Modulated;
			// Canvas.DrawPattern(texture'LoseBackground', Canvas.ClipX, Canvas.ClipY, 0.5);
			Canvas.DrawRect(texture'LoseBackground', Canvas.ClipX, Canvas.ClipY);

			Canvas.Style = ERenderStyle.STY_Normal;
			
			Canvas.Font = MyFonts.GetHugeFont( Canvas.ClipX );

			Canvas.bCenter = true;

			Canvas.SetPos( Canvas.ClipX * 0.025, Canvas.ClipY * 0.35);
			Canvas.DrawText("GAME OVER", true );

			Canvas.Font = MyFonts.GetBigFont( Canvas.ClipX );
			Canvas.SetPos( Canvas.ClipX* 0.025 , Canvas.ClipY * 0.45);
			Canvas.DrawText("The Monsters Have Invaded", true );

			Canvas.Font = MyFonts.GetMediumFont( Canvas.ClipX );
			Canvas.SetPos( Canvas.ClipX* 0.025 , Canvas.ClipY * 0.9);
			Canvas.DrawText("Your Team Has Lost The Game", true );

			Canvas.bCenter = false;
		}
	else
		{
			//========================================================================
			//====  Current Scores Normal Scoreboard  ===============================
			//========================================================================
			if ( ScoreBoardPage == "Current Scores" )
				{
					DrawPageTitle(Canvas);
/*
					// Header
					Canvas.SetPos(0, 0);
					DrawHeader(Canvas);
*/
				
					// Wipe everything.
					for ( i=0; i<ArrayCount(Ordered); i++ )
						Ordered[i] = None;
							
					for ( i=0; i<32; i++ )
						{
							if (PlayerPawn(Owner).GameReplicationInfo.PRIArray[i] != None)
								{
									PRI = PlayerPawn(Owner).GameReplicationInfo.PRIArray[i];
									if ( !PRI.bIsSpectator || PRI.bWaitingPlayer )
										{
											Ordered[PlayerCount] = PRI;
											PlayerCount++;
											if ( PlayerCount == ArrayCount(Ordered) )
												break;
										}
								}
						}
							
					SortScores(PlayerCount);
			
					CanvasFont = Canvas.Font;
					Canvas.Font = MyFonts.GetBigFont(Canvas.ClipX);
							
					Canvas.SetPos(0, 160.0/768.0 * Canvas.ClipY);
					DrawCategoryHeaders(Canvas);
							
					Canvas.StrLen( "TEST", XL, YL );
					YStart = (Canvas.CurY)*0.8;
					YStart = Canvas.ClipY * 0.225;
					YOffset = YStart;
							
					if ( PlayerCount > 15 )
						PlayerCount = FMin(PlayerCount, (Canvas.ClipY - YStart)/YL - 1);
							
					Canvas.SetPos(0, 0);

					// DRAW SOME DAMN ROWS!!! ===============================
					for ( I=0; I<PlayerCount; I++ )
						{
							RowSpace = 1.9;
							YOffset = YStart + I * (YL*RowSpace);
							YOffsetNext = YStart + (I+1) * (YL*RowSpace);

							if ( I == 0 )
								DrawName( Canvas, Ordered[I], 0, YOffset, YOffsetNext, true);
							else
								DrawName( Canvas, Ordered[I], 0, YOffset, YOffsetNext, false);
						}
							
					Canvas.DrawColor = WhiteColor;
					Canvas.Font = CanvasFont;
							
					// Trailer
										/*
							if ( !Level.bLowRes )
								{
									Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
									DrawTrailer(Canvas);
								}
											*/
					DrawPageFooter(Canvas,"Press F3 to see the Leader Board");
				}
			//========================================================================
			//====  Top Ten Players  =================================================
			//========================================================================
			if ( ScoreBoardPage == "Top Ten Players" )
				{
					DrawPageTitle(Canvas);

					YOffset = 0.20;
					YOffset += 0.05;
					row_y[0] = 0.225;
					row_y[1] = 0.275;
					row_progress[0] = ((Canvas.ClipY-(Canvas.ClipY * row_y[0])) / 12) / Canvas.ClipY;

					column_x[0] = 0.05;
					column_x[1] = 0.12;
					column_x[2] = 0.40;
					column_x[3] = 0.60;
					column_x[4] = 0.70;
					column_x[5] = 0.85;

					// SET RANK TEXT

					for ( i = 0; i < 10; i ++ )
						{

							text = OrdinalNumber(string(i+1));

							Canvas.Font = MyFonts.GetBigFont( Canvas.ClipX );

							// DRAW RANKS
							Canvas.DrawColor = WhiteColor;
							Canvas.SetPos(Canvas.ClipX * column_x[0], Canvas.ClipY * row_y[0]);
							Canvas.DrawText(text, true );

							// SET NAME TEXT

							if ( u4egreplicationinfo(PlayerPawn(owner).gamereplicationinfo).TopNames[i] == "" )
								{
									text = "Nobody";
									Canvas.DrawColor = GreyColor;
								}
							else
								{
									text = u4egreplicationinfo(PlayerPawn(owner).gamereplicationinfo).TopNames[i];
									Canvas.DrawColor = WhiteColor;
								}

							// text = "I_HAVE_THE_LONGEST_NAME_EVER_WORK_HARDER_PROGRAMMER";

							Canvas.StrLen(text, text_width, text_height);
							trim = 0;

							while ( ((Canvas.ClipX * column_x[1]) + text_width) > (Canvas.ClipX * column_x[2]))
								{
									if ( trim >= 512 )
										break;
									else
										trim ++;

									text = mid(text,0,len(text)-trim);
									Canvas.StrLen(text$"...", text_width, text_height);
								}

							if ( trim != 0 )
								text = text$"...";
								


							// DRAW NAMES
							Canvas.SetPos(Canvas.ClipX * column_x[1], Canvas.ClipY * row_y[0]);
							Canvas.DrawText(text, true );
							// Draw Titles Under Names
							Canvas.DrawColor.r = 196;
							Canvas.DrawColor.g = 196;
							Canvas.DrawColor.b = 196;
							Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
							Canvas.SetPos(Canvas.ClipX * column_x[1], Canvas.ClipY * (row_y[0] + (row_progress[0]*0.5)));
							text = u4egreplicationinfo(PlayerPawn(owner).gamereplicationinfo).TopTitles[i];
							text = "Title:"@text;
							Canvas.DrawText(text, true );

							// Don't forget to reset!
							Canvas.DrawColor = WhiteColor;
							Canvas.Font = MyFonts.GetBigFont( Canvas.ClipX );

							// SET SCORE TEXT
							text = "Score:";
							text = text@u4egreplicationinfo(PlayerPawn(owner).gamereplicationinfo).TopScores[i];

							// DRAW SCORES
							Canvas.SetPos(Canvas.ClipX * column_x[2], Canvas.ClipY * row_y[0]);
							Canvas.DrawText(text, true );

							// SET WINS TEXT
							Canvas.DrawColor.r = 128;
							Canvas.DrawColor.g = 255;
							Canvas.DrawColor.b = 128;
							text = "Wins:";
							text = text@u4egreplicationinfo(PlayerPawn(owner).gamereplicationinfo).TopWins[i];

							// DRAW WINS
							Canvas.SetPos(Canvas.ClipX * column_x[3], Canvas.ClipY * row_y[0]);
							Canvas.DrawText(text, true );

							// SET LOSSES TEXT
							Canvas.DrawColor.r = 255;
							Canvas.DrawColor.g = 128;
							Canvas.DrawColor.b = 128;
							text = "Losses:";
							text = text@u4egreplicationinfo(PlayerPawn(owner).gamereplicationinfo).TopLosses[i];

							// DRAW LOSSES
							Canvas.SetPos(Canvas.ClipX * column_x[4], Canvas.ClipY * row_y[0]);
							Canvas.DrawText(text, true );

							// SET LEADS TEXT
							Canvas.DrawColor.r = 255;
							Canvas.DrawColor.g = 255;
							Canvas.DrawColor.b = 128;
							text = "Leads:";
							text = text@u4egreplicationinfo(PlayerPawn(owner).gamereplicationinfo).TopLeads[i];

							// DRAW LEADS
							Canvas.SetPos(Canvas.ClipX * column_x[5], Canvas.ClipY * row_y[0]);
							Canvas.DrawText(text, true );

							// === MAKE NEW ROW ===
							row_y[0] += row_progress[0];
						}

					if ( Spectator(Owner) == None )
						DrawPageFooter(Canvas,"Press F3 to see your Personal Statistics");
					else
						DrawPageFooter(Canvas,"Press F3 to see the Current Scores");

					Canvas.bCenter = false;
					Canvas.DrawColor = WhiteColor;
					Canvas.Font = CanvasFont;
				}
			//========================================================================
			//====  Personal Statistics  =============================================
			//========================================================================
			if ( ScoreBoardPage == "Personal Statistics" )
				{
					DrawPageTitle(Canvas);

					GPI = GauntletPlayerReplicationInfo(PlayerPawn(Owner).PlayerReplicationInfo);

					YOffset = 0.20;
					YOffset += 0.025;
					row_y[0] = 0.225;
					row_progress[0] = ((Canvas.ClipY-(Canvas.ClipY * row_y[0])) / 32) / Canvas.ClipY;

					column_x[0] = 0.05;
					column_x[1] = 0.20;
					column_x[2] = 0.30;
					column_x[3] = 0.47;
					column_x[4] = 0.55;
					column_x[5] = 0.75;

					///////////////////////////////////////////////////////
					///////// MONSTERS KILLED /////////////////////////////
					///////////////////////////////////////////////////////

					for ( i = 0; i <= 26; i ++ )
						{

							switch( i )
								{
									case 0:
										text = "Flies:";
										text_value = GPI.Fly;
										break;
									case 1:
										text = "Pupaes:";
										text_value = GPI.Pupae;
										break;
									case 2:
										text = "Spinners:";
										text_value = GPI.Spinner;
										break;
									case 3:
										text = "Gasbags:";
										text_value = GPI.Gasbag;
										break;
									case 4:
										text = "Mullogs:";
										text_value = GPI.Mullog;
										break;
									case 5:
										text = "Mantas:";
										text_value = GPI.Manta;
										break;
									case 6:
										text = "Krall:";
										text_value = GPI.Krail;
										break;
									case 7:
										text = "Boogers:";
										text_value = GPI.Booger;
										break;
									case 8:
										text = "Slime Boogers:";
										text_value = GPI.SlimeBooger;
										break;
									case 9:
										text = "Ice Boogers:";
										text_value = GPI.Icebooger;
										break;
									case 10:
										text = "Fire Boogers:";
										text_value = GPI.FireBooger;
										break;
									case 11:
										text = "Brutes:";
										text_value = GPI.Brute;
										break;
									case 12:
										text = "Skaarj:";
										text_value = GPI.Skaarj;
										break;
									case 13:
										text = "Krall Elite:";
										text_value = GPI.KrallElite;
										break;
									case 14:
										text = "Mercenaries:";
										text_value = GPI.Mercenary;
										break;
									case 15:
										text = "Giant Gasbags:";
										text_value = GPI.GiantGasbag;
										break;
									case 16:
										text = "Yetis:";
										text_value = GPI.Yeti;
										break;
									case 17:
										text = "Warlords:";
										text_value = GPI.Warlord;
										break;
									case 18:
										text = "Maidens:";
										text_value = GPI.Maiden;
										break;
									case 19:
										text = "Torchurers:";
										text_value = GPI.Torchurer;
										break;
									case 20:
										text = "MAXs:";
										text_value = GPI.MAX;
										break;
									case 21:
										text = "Lesser Angels:";
										text_value = GPI.LesserAngel;
										break;
									case 22:
										text = "Angels:";
										text_value = GPI.Angel;
										break;
									case 23:
										text = "Battle Angels:";
										text_value = GPI.BattleAngel;
										break;
									case 24:
										text = "War Angels:";
										text_value = GPI.WarAngel;
										break;
									case 25:
										text = "Arch Angels:";
										text_value = GPI.ArchAngel;
										break;
									case 26:
										text = "Solar Goddesses:";
										text_value = GPI.SolarGoddess;
										break;
								}

							Canvas.Font = MyFonts.GetBigFont( Canvas.ClipX * 0.60 );
							// Canvas.Font = MyFonts.GetMediumFont( Canvas.ClipX );



							// Catagory Title "Monsters Killed"
							if ( i == 0 )
								{
									Canvas.Font = MyFonts.GetBigFont( Canvas.ClipX * 1.25 );
									Canvas.DrawColor.r = 255;
									Canvas.DrawColor.g = 32;
									Canvas.DrawColor.b = 32;
									Canvas.SetPos(Canvas.ClipX * column_x[0], Canvas.ClipY * (row_y[0]*0.85) );
									Canvas.DrawText("Monsters Killed", true );
								}

							if ( odd == true )
								{
									Canvas.DrawColor.r = 255;
									Canvas.DrawColor.g = 196;
									Canvas.DrawColor.b = 196;
								}
							else
								{
									Canvas.DrawColor.r = 255;
									Canvas.DrawColor.g = 128;
									Canvas.DrawColor.b = 128;
								}

							odd = !odd;

							Canvas.Font = MyFonts.GetBigFont( Canvas.ClipX * 0.60 );

							// Monster Name
							Canvas.SetPos(Canvas.ClipX * column_x[0], Canvas.ClipY * row_y[0]);
							Canvas.DrawText(text, true );
							// Monster Kills
							Canvas.SetPos(Canvas.ClipX * column_x[1], Canvas.ClipY * row_y[0]);
							Canvas.DrawText(text_value, true );

							// reset color
							Canvas.DrawColor = WhiteColor;

							// === MAKE NEW ROW ===
							row_y[0] += row_progress[0];
						}

					// FOR GATEWAYS
					YOffset = 0.20;
					YOffset += 0.025;
					row_y[0] = 0.225;
					row_progress[0] = ((Canvas.ClipY-(Canvas.ClipY * row_y[0])) / 32) / Canvas.ClipY;

					///////////////////////////////////////////////////////
					///////// GATEWAYS KILLED /////////////////////////////
					///////////////////////////////////////////////////////

					for ( i = 0; i <= 17; i ++ )
						{

							switch( i )
								{
									case 0:
										text = "Fly Gates:";
										text_value = GPI.GateFly;
										break;
									case 1:
										text = "Pupae Gates:";
										text_value = GPI.GatePupae;
										break;
									case 2:
										text = "Gasbag Gates:";
										text_value = GPI.GateGasbag;
										break;
									case 3:
										text = "Mullog Gates:";
										text_value = GPI.GateMullog;
										break;
									case 4:
										text = "Manta Gates:";
										text_value = GPI.GateManta;
										break;
									case 5:
										text = "Krall Gates:";
										text_value = GPI.GateKrail;
										break;
									case 6:
										text = "Booger Gates:";
										text_value = GPI.GateBooger;
										break;
									case 7:
										text = "Brute Gates:";
										text_value = GPI.GateBrute;
										break;
									case 8:
										text = "Skaarj:";
										text_value = GPI.GateSkaarj;
										break;
									case 9:
										text = "Krall Elite:";
										text_value = GPI.GateKrallElite;
										break;
									case 10:
										text = "Mercenarie Gates:";
										text_value = GPI.GateMercenary;
										break;
									case 11:
										text = "Giant Gasbag Gates:";
										text_value = GPI.GateGiantGasbag;
										break;
									case 12:
										text = "Yeti Gates:";
										text_value = GPI.GateYeti;
										break;
									case 13:
										text = "Warlord Gates:";
										text_value = GPI.GateWarlord;
										break;
									case 14:
										text = "Maiden Gates:";
										text_value = GPI.GateMaiden;
										break;
									case 15:
										text = "Torchurer Gates:";
										text_value = GPI.GateTorchurer;
										break;
									case 16:
										text = "MAX Gates:";
										text_value = GPI.GateMAX;
										break;
									case 17:
										text = "Angel Gates:";
										text_value = GPI.GateAngel;
										break;
								}

							Canvas.Font = MyFonts.GetBigFont( Canvas.ClipX * 0.60 );
							// Canvas.Font = MyFonts.GetMediumFont( Canvas.ClipX );



							// Catagory Title "Gateways Killed"
							if ( i == 0 )
								{
									Canvas.Font = MyFonts.GetBigFont( Canvas.ClipX * 1.25 );
									Canvas.DrawColor.r = 32;
									Canvas.DrawColor.g = 32;
									Canvas.DrawColor.b = 255;
									Canvas.SetPos(Canvas.ClipX * column_x[2], Canvas.ClipY * (row_y[0]*0.85) );
									Canvas.DrawText("Gateways Killed", true );
								}

							if ( odd != true )
								{
									Canvas.DrawColor.r = 196;
									Canvas.DrawColor.g = 196;
									Canvas.DrawColor.b = 255;
								}
							else
								{
									Canvas.DrawColor.r = 128;
									Canvas.DrawColor.g = 128;
									Canvas.DrawColor.b = 255;
								}

							odd = !odd;

							Canvas.Font = MyFonts.GetBigFont( Canvas.ClipX * 0.60 );

							// Monster Name
							Canvas.SetPos(Canvas.ClipX * column_x[2], Canvas.ClipY * row_y[0]);
							Canvas.DrawText(text, true );
							// Monster Kills
							Canvas.SetPos(Canvas.ClipX * column_x[3], Canvas.ClipY * row_y[0]);
							Canvas.DrawText(text_value, true );

							// reset color
							Canvas.DrawColor = WhiteColor;

							// === MAKE NEW ROW ===
							row_y[0] += row_progress[0];
						}

					// FOR GATEWAYS
					YOffset = 0.20;
					YOffset += 0.025;
					row_y[0] = 0.225;
					row_progress[0] = ((Canvas.ClipY-(Canvas.ClipY * row_y[0])) / 32) / Canvas.ClipY;

					///////////////////////////////////////////////////////
					///////// GAME STATS /////////////////////////////
					///////////////////////////////////////////////////////

					for ( i = 0; i <= 7; i ++ )
						{

							switch( i )
								{
									case 0:
										text = "Title:";
										text_value = GPI.RankTitle;
										break;
									case 1:
										text = "Rank On Server:";
										text_value = OrdinalNumber(GPI.RankServer);
										break;
									case 2:
										text = "All Time Score:";
										text_value = GPI.AllTimeScore;
										break;
									case 3:
										text = "Wins:";
										text_value = GPI.Wins;
										break;
									case 4:
										text = "Losses:";
										text_value = GPI.Losses;
										break;
									case 5:
										text = "Leads:";
										text_value = GPI.Leads;
										break;
									case 8:
										text = "Leads:";
										text_value = GPI.Leads;
										break;
									case 6:
										text = "Score From Monsters:";
										text_value = GPI.ScoreFromMonsters;
										break;
									case 7:
										text = "Score From Gateways:";
										text_value = GPI.ScoreFromGateways;
										break;
								}

							Canvas.Font = MyFonts.GetBigFont( Canvas.ClipX * 0.60 );
							// Canvas.Font = MyFonts.GetMediumFont( Canvas.ClipX );



							// Catagory Title "Gateways Killed"
							if ( i == 0 )
								{
									Canvas.Font = MyFonts.GetBigFont( Canvas.ClipX * 1.25 );
									Canvas.DrawColor.r = 32;
									Canvas.DrawColor.g = 255;
									Canvas.DrawColor.b = 32;
									Canvas.SetPos(Canvas.ClipX * column_x[4], Canvas.ClipY * (row_y[0]*0.85) );
									Canvas.DrawText("Game Statistics", true );
								}

							if ( odd != true )
								{
									Canvas.DrawColor.r = 196;
									Canvas.DrawColor.g = 255;
									Canvas.DrawColor.b = 196;
								}
							else
								{
									Canvas.DrawColor.r = 128;
									Canvas.DrawColor.g = 255;
									Canvas.DrawColor.b = 128;
								}

							odd = !odd;

							Canvas.Font = MyFonts.GetBigFont( Canvas.ClipX * 0.60 );

							// Monster Name
							Canvas.SetPos(Canvas.ClipX * column_x[4], Canvas.ClipY * row_y[0]);
							Canvas.DrawText(text, true );
							// Monster Kills
							Canvas.SetPos(Canvas.ClipX * column_x[5], Canvas.ClipY * row_y[0]);
							Canvas.DrawText(text_value, true );

							// reset color
							Canvas.DrawColor = WhiteColor;

							// === MAKE NEW ROW ===
							row_y[0] += row_progress[0];
						}

					DrawPageFooter(Canvas,"Press F3 to see the Current Scores");

					Canvas.bCenter = false;
					Canvas.DrawColor = WhiteColor;
					Canvas.Font = CanvasFont;
				}
		}
}

function DrawPageTitle( canvas Canvas )
{
	local float pagetitle_y;
	local float CrownOffsetTop;
	local float CrownOffsetBottom;
	local float w_scale;

	Canvas.SetPos(0,0);
	Canvas.Style = ERenderStyle.STY_Modulated;
	Canvas.DrawRect(texture'TopTenBackShadeWave', Canvas.ClipX, Canvas.ClipY);
	
	Canvas.Font = MyFonts.GetHugeFont( Canvas.ClipX );
	
	pagetitle_y = 0.05;

	Canvas.DrawColor.r = 140; 
	Canvas.DrawColor.g = 0;
	Canvas.DrawColor.b = 255;

	Canvas.Style = ERenderStyle.STY_Translucent;
	Canvas.SetPos(0,Canvas.ClipY * pagetitle_y);
	Canvas.DrawRect(texture'TitleBarBack', Canvas.ClipX*0.5, 64);
	Canvas.SetPos(Canvas.ClipX*0.5, Canvas.ClipY * pagetitle_y );
	Canvas.DrawRect(texture'TitleBarBack', Canvas.ClipX*0.5, 64);

	Canvas.DrawColor = WhiteColor;
	CrownOffsetTop = 0.1;
	CrownOffsetBottom = 0.025;

	// Crown Top
	Canvas.Style = ERenderStyle.STY_Modulated;
	Canvas.SetPos((Canvas.ClipX*0.5)-128, (Canvas.ClipY * (pagetitle_y-CrownOffsetTop)));
	Canvas.DrawRect(texture'CenterTitleCrown',256, 128);

	Canvas.Style = ERenderStyle.STY_Modulated;
	Canvas.SetPos((Canvas.ClipX*0.5)-256, (Canvas.ClipY * (pagetitle_y-CrownOffsetTop)));
	Canvas.DrawRect(texture'CenterTitleCrown',512, 128);

	Canvas.Style = ERenderStyle.STY_Modulated;
	Canvas.SetPos((Canvas.ClipX*0.5)-512, (Canvas.ClipY * (pagetitle_y-CrownOffsetTop)));
	Canvas.DrawRect(texture'CenterTitleCrown',1024, 128);

	// Crown Bottom

	Canvas.Style = ERenderStyle.STY_Modulated;
	Canvas.SetPos((Canvas.ClipX*0.5)-128, (Canvas.ClipY * (pagetitle_y+CrownOffsetBottom)));
	Canvas.DrawRect(texture'CenterTitleCrownDown',256, 128);

	Canvas.Style = ERenderStyle.STY_Modulated;
	Canvas.SetPos((Canvas.ClipX*0.5)-256, (Canvas.ClipY * (pagetitle_y+CrownOffsetBottom)));
	Canvas.DrawRect(texture'CenterTitleCrownDown',512, 128);

	Canvas.Style = ERenderStyle.STY_Modulated;
	Canvas.SetPos((Canvas.ClipX*0.5)-512, (Canvas.ClipY * (pagetitle_y+CrownOffsetBottom)));
	Canvas.DrawRect(texture'CenterTitleCrownDown',1024, 128);


	Canvas.Style = ERenderStyle.STY_Translucent;
	w_scale = 1.25;

	// Draw Wildcard's Gauntlet Title
	if ( ScoreBoardPage == "Current Scores" )
		{
			Canvas.SetPos((Canvas.ClipX*0.5)-((256*w_scale)-(64*w_scale)*0),Canvas.ClipY * pagetitle_y);
			Canvas.DrawRect(texture'WildcardsGauntlet001', 64*w_scale, 64);
			Canvas.SetPos((Canvas.ClipX*0.5)-((256*w_scale)-(64*w_scale)*1),Canvas.ClipY * pagetitle_y);
			Canvas.DrawRect(texture'WildcardsGauntlet002', 64*w_scale, 64);
			Canvas.SetPos((Canvas.ClipX*0.5)-((256*w_scale)-(64*w_scale)*2),Canvas.ClipY * pagetitle_y);
			Canvas.DrawRect(texture'WildcardsGauntlet003', 64*w_scale, 64);
			Canvas.SetPos((Canvas.ClipX*0.5)-((256*w_scale)-(64*w_scale)*3),Canvas.ClipY * pagetitle_y);
			Canvas.DrawRect(texture'WildcardsGauntlet004', 64*w_scale, 64);
			Canvas.SetPos((Canvas.ClipX*0.5)-((256*w_scale)-(64*w_scale)*4),Canvas.ClipY * pagetitle_y);
			Canvas.DrawRect(texture'WildcardsGauntlet005', 64*w_scale, 64);
			Canvas.SetPos((Canvas.ClipX*0.5)-((256*w_scale)-(64*w_scale)*5),Canvas.ClipY * pagetitle_y);
			Canvas.DrawRect(texture'WildcardsGauntlet006', 64*w_scale, 64);
			Canvas.SetPos((Canvas.ClipX*0.5)-((256*w_scale)-(64*w_scale)*6),Canvas.ClipY * pagetitle_y);
			Canvas.DrawRect(texture'WildcardsGauntlet007', 64*w_scale, 64);
			Canvas.SetPos((Canvas.ClipX*0.5)-((256*w_scale)-(64*w_scale)*7),Canvas.ClipY * pagetitle_y);
			Canvas.DrawRect(texture'WildcardsGauntlet008', 64*w_scale, 64);
		}
	// Draw Leader Board Title
	if ( ScoreBoardPage == "Top Ten Players" )
		{
			Canvas.SetPos((Canvas.ClipX*0.5)-((256*w_scale)-(64*w_scale)*0),Canvas.ClipY * pagetitle_y);
			Canvas.DrawRect(texture'GauntletLeadersGlow001', 64*w_scale, 64);
			Canvas.SetPos((Canvas.ClipX*0.5)-((256*w_scale)-(64*w_scale)*1),Canvas.ClipY * pagetitle_y);
			Canvas.DrawRect(texture'GauntletLeadersGlow002', 64*w_scale, 64);
			Canvas.SetPos((Canvas.ClipX*0.5)-((256*w_scale)-(64*w_scale)*2),Canvas.ClipY * pagetitle_y);
			Canvas.DrawRect(texture'GauntletLeadersGlow003', 64*w_scale, 64);
			Canvas.SetPos((Canvas.ClipX*0.5)-((256*w_scale)-(64*w_scale)*3),Canvas.ClipY * pagetitle_y);
			Canvas.DrawRect(texture'GauntletLeadersGlow004', 64*w_scale, 64);
			Canvas.SetPos((Canvas.ClipX*0.5)-((256*w_scale)-(64*w_scale)*4),Canvas.ClipY * pagetitle_y);
			Canvas.DrawRect(texture'GauntletLeadersGlow005', 64*w_scale, 64);
			Canvas.SetPos((Canvas.ClipX*0.5)-((256*w_scale)-(64*w_scale)*5),Canvas.ClipY * pagetitle_y);
			Canvas.DrawRect(texture'GauntletLeadersGlow006', 64*w_scale, 64);
			Canvas.SetPos((Canvas.ClipX*0.5)-((256*w_scale)-(64*w_scale)*6),Canvas.ClipY * pagetitle_y);
			Canvas.DrawRect(texture'GauntletLeadersGlow007', 64*w_scale, 64);
			Canvas.SetPos((Canvas.ClipX*0.5)-((256*w_scale)-(64*w_scale)*7),Canvas.ClipY * pagetitle_y);
			Canvas.DrawRect(texture'GauntletLeadersGlow008', 64*w_scale, 64);
		}
	// Draw Personal Statistics Title
	if ( ScoreBoardPage == "Personal Statistics" )
		{
			Canvas.SetPos((Canvas.ClipX*0.5)-((256*w_scale)-(64*w_scale)*0),Canvas.ClipY * pagetitle_y);
			Canvas.DrawRect(texture'PersonalStatistics001', 64*w_scale, 64);
			Canvas.SetPos((Canvas.ClipX*0.5)-((256*w_scale)-(64*w_scale)*1),Canvas.ClipY * pagetitle_y);
			Canvas.DrawRect(texture'PersonalStatistics002', 64*w_scale, 64);
			Canvas.SetPos((Canvas.ClipX*0.5)-((256*w_scale)-(64*w_scale)*2),Canvas.ClipY * pagetitle_y);
			Canvas.DrawRect(texture'PersonalStatistics003', 64*w_scale, 64);
			Canvas.SetPos((Canvas.ClipX*0.5)-((256*w_scale)-(64*w_scale)*3),Canvas.ClipY * pagetitle_y);
			Canvas.DrawRect(texture'PersonalStatistics004', 64*w_scale, 64);
			Canvas.SetPos((Canvas.ClipX*0.5)-((256*w_scale)-(64*w_scale)*4),Canvas.ClipY * pagetitle_y);
			Canvas.DrawRect(texture'PersonalStatistics005', 64*w_scale, 64);
			Canvas.SetPos((Canvas.ClipX*0.5)-((256*w_scale)-(64*w_scale)*5),Canvas.ClipY * pagetitle_y);
			Canvas.DrawRect(texture'PersonalStatistics006', 64*w_scale, 64);
			Canvas.SetPos((Canvas.ClipX*0.5)-((256*w_scale)-(64*w_scale)*6),Canvas.ClipY * pagetitle_y);
			Canvas.DrawRect(texture'PersonalStatistics007', 64*w_scale, 64);
			Canvas.SetPos((Canvas.ClipX*0.5)-((256*w_scale)-(64*w_scale)*7),Canvas.ClipY * pagetitle_y);
			Canvas.DrawRect(texture'PersonalStatistics008', 64*w_scale, 64);
		}
}

function DrawPageFooter( canvas Canvas, string FootText )
{
	local font CanvasFont;
	local PlayerReplicationInfo CurrentPRI;
	local PlayerReplicationInfo PlayerPRI[32];
	local int AvailiblePRI;
	local string SpectatorString;
	local int i;

	log("Pawn(Owner).bIsplayer"@Pawn(Owner).bIsplayer);
	log("Pawn(Owner)"@Pawn(Owner));

	if ( Pawn(Owner).bIsplayer == false )
		return;

	CanvasFont = Canvas.Font;
	Canvas.Font = MyFonts.GetBigFont(Canvas.ClipX);

	Canvas.DrawColor.r = 0; 
	Canvas.DrawColor.g = 0;
	Canvas.DrawColor.b = 255;

	// BOTTOM FOOTER OF PAGE
	Canvas.Style = ERenderStyle.STY_Translucent;
	// LEFT
	Canvas.SetPos(0,Canvas.ClipY - 64);
	Canvas.DrawRect(texture'PageFooterLeft', 256, 64);
	// RIGHT
	Canvas.SetPos(Canvas.ClipX-256,Canvas.ClipY - 64);
	Canvas.DrawRect(texture'PageFooterRight', 256, 64);
	// CENTER
	Canvas.SetPos(256,Canvas.ClipY - 64);
	Canvas.DrawRect(texture'PageFooterCenter', Canvas.ClipX-512, 64);

	Canvas.Style = ERenderStyle.STY_Modulated;
	Canvas.SetPos((Canvas.ClipX*0.5)-128, Canvas.ClipY - 96);
	Canvas.DrawRect(texture'CenterTitleCrown',256, 128);

	Canvas.Style = ERenderStyle.STY_Modulated;
	Canvas.SetPos((Canvas.ClipX*0.5)-256, Canvas.ClipY - 96);
	Canvas.DrawRect(texture'CenterTitleCrown',512, 128);

	Canvas.Style = ERenderStyle.STY_Modulated;
	Canvas.SetPos((Canvas.ClipX*0.5)-512, Canvas.ClipY - 96);
	Canvas.DrawRect(texture'CenterTitleCrown',1024, 128);
		
	Canvas.DrawColor.r = 0; 
	Canvas.DrawColor.g = 144;
	Canvas.DrawColor.b = 255;
				
	Canvas.bCenter = true;
	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.SetPos(Canvas.ClipX * 0.025, Canvas.ClipY - 40);
	Canvas.DrawText(FootText);

	if ( ScoreBoardPage == "Current Scores" )
		{
			// Wipe everything.
			for ( i = 0; i < ArrayCount(PlayerPRI); i++ )
				PlayerPRI[i] = None;
	
			AvailiblePRI = 0;
	
			for ( i = 0; i < ArrayCount(PlayerPRI); i++ )
				{
					if (PlayerPawn(Owner).GameReplicationInfo.PRIArray[i] != None)
						{
							CurrentPRI = PlayerPawn(Owner).GameReplicationInfo.PRIArray[i];

							if ( CurrentPRI.bIsSpectator && CurrentPRI.PlayerName != "Player" )
								{
									PlayerPRI[AvailiblePRI] = CurrentPRI;
						
									if ( AvailiblePRI == 0 )
										SpectatorString = SpectatorString@CurrentPRI.PlayerName;
									else
										SpectatorString = SpectatorString$", "$CurrentPRI.PlayerName;
					
									AvailiblePRI++;
								}
						}
				}

			if ( AvailiblePRI > 0 )
				{
					if ( AvailiblePRI == 1 )
						SpectatorString = "Spectator:"@SpectatorString;
					else
						SpectatorString = "Spectators:"@SpectatorString;

					CanvasFont = Canvas.Font;
					Canvas.Font = MyFonts.GetSmallestFont(Canvas.ClipX);

					Canvas.bCenter = true;
					Canvas.Style = ERenderStyle.STY_Normal;
					Canvas.SetPos(Canvas.ClipX * 0.025, Canvas.ClipY - 20);
					Canvas.DrawText(SpectatorString);
				}

		}








	Canvas.bCenter = false;
	Canvas.DrawColor = WhiteColor;
	Canvas.Font = CanvasFont;
}

function string OrdinalNumber( string RankNumber )
{
	local string RankText, Eleven;
	
	RankText = right(RankNumber,1);
	Eleven = right(RankNumber,2);

	if ( Eleven == "11" || Eleven == "13" || Eleven == "12" )
		RankText = RankNumber$"th";
	else
		{
			if ( RankText == "1" )
				RankText = RankNumber$"st";
			else
				{
					if ( RankText == "2" )
						RankText = RankNumber$"nd";
					else
						{
							if ( RankText == "3" )
								RankText = RankNumber$"rd";
							else
								RankText = RankNumber$"th";
						}
				}
		}
	return RankText;
}

defaultproperties
{
      RowSpace=0.000000
      ScoreBoardPage=""
      GHUD=None
      PreviousMessage=""
}
