class gauntletHUD expands ChallengeTeamHUD;
var bool bSetRadar;
var float hudoff;
var float PositionX[32];
var float PositionY[32];
var float CurrentX;
var float CurrentY;
var int CurrentPlayerRank;

// This is going to be used for the new Rivals and followers feature
var PlayerReplicationInfo PlayerPRI[32], FollowerPRI, MyPRI, RivalPRI; 
var int AvailiblePRI;
var string PlayerName[arraycount(PlayerPRI)];
var int PlayerScore[arraycount(PlayerPRI)];

/*
simulated function DisplayProgressMessage( canvas Canvas )
{
	local int i;
	local float XL, YL, YOffset;
	local GameReplicationInfo GRI;

	PlayerOwner.ProgressTimeOut = FMin(PlayerOwner.ProgressTimeOut, Level.TimeSeconds + 8);
	Canvas.Style = ERenderStyle.STY_Normal;	

	Canvas.bCenter = True;
	Canvas.Font = MyFonts.GetBigFont( Canvas.ClipX );
	Canvas.StrLen("TEST", XL, YL);
	if ( UTIntro(Level.Game) != None )
		YOffset = 64 * scale + 2 * YL;
	else if ( (MOTDFadeOutTime <= 0) || (Canvas.ClipY < 300) )
		YOffset = 64 * scale + 6 * YL;
	else
	{
		YOffset = 64 * scale + 6 * YL;
		GRI = PlayerOwner.GameReplicationInfo;
		if ( GRI != None )
		{
			if ( GRI.MOTDLine1 != "" )
				YOffset += YL;
			if ( GRI.MOTDLine2 != "" )
				YOffset += YL;
			if ( GRI.MOTDLine3 != "" )
				YOffset += YL;
			if ( GRI.MOTDLine4 != "" )
				YOffset += YL;
		}
	}
	for (i=0; i<8; i++)
	{
		Canvas.SetPos(0, YOffset);
		Canvas.DrawColor = PlayerPawn(Owner).ProgressColor[i];
		if ( PlayerPawn(Owner).ProgressMessage[i] != "TurnPage" )
			Canvas.DrawText(PlayerPawn(Owner).ProgressMessage[i], False);
		YOffset += YL + 1;
	}
	Canvas.DrawColor = WhiteColor;
	Canvas.bCenter = False;
	HUDSetup(Canvas);	
}
*/

function PostBeginPlay()
{
	PositionX[0] = 1580;
	PositionY[0] = 1012;

	PositionX[1] = 0.09;
	PositionY[1] = 0.45;

	PositionX[2] = -0.21;
	PositionY[2] = 0.29;

	PositionX[3] = 0.11;
	PositionY[3] = 1.12;

	PositionX[4] = 0.09;
	PositionY[4] = 0.45;

	Super.PostBeginPlay();
}

simulated function Actor GetFocusedActor()
{
  local vector Look, EyePos;
  local Actor Winner;
  Local scriptedpawn Candidate;
  local float Score, HiScore;

  EyePos = Owner.Location;
  EyePos.Z += Pawn(Owner).EyeHeight;
  Look = vector(Pawn(Owner).ViewRotation);

  HiScore = 0;
  foreach AllActors(class'ScriptedPawn', Candidate)
  {
    if((candidate.IsA('boss1')) || (candidate.IsA('boss2')) || (candidate.IsA('boss3')) || (candidate.IsA('boss4')))
            Score = Normal(Candidate.Location - EyePos) dot Look;
    else Score=0;

    // Ignore actors too far to the sides (too low scores):
    if (Score >= 0.9) // adjust this threshold to taste
    {
      // See if this candidate is an improvement:
      if (Score > HiScore)
      {
        HiScore = Score;
        Winner = Candidate;
      }
    }
  }

  return Winner;
}

simulated function vector MapToScreen(vector TargetPos, Canvas Canvas)
{
  local vector Result, EyePos;
  local rotator Look, Focus;
  local float dYaw, dPitch, scale; // TanFOV,

  EyePos = Owner.Location;
  EyePos.Z += Pawn(Owner).EyeHeight;

  Look = rotator(vector(Pawn(owner).ViewRotation));

  Focus = rotator(TargetPos - EyePos);

  dYaw = (focus.yaw-look.yaw) * Pi / 32768.0;
  dPitch = (focus.pitch-look.pitch) * Pi / 32768.0;

  Scale = (Canvas.ClipX/2) / tan(Pawn(Owner).FOVAngle * Pi / 360.0);

  // Finally calculate actual screen coordinates:
  Result.x = Canvas.ClipX/2 + tan(dYaw) * Scale;
  Result.y = Canvas.ClipY/2 - tan(dPitch) * Scale;

  return Result;
}

simulated function DrawActorTip(Canvas Canvas)
{
  local Actor FocusedActor;
  local vector ScreenPos;
//  local float x,y,z;

  // Find Target
  FocusedActor = GetFocusedActor();
  // Label Target
  if (FocusedActor != None)
  {
    Canvas.DrawColor = WhiteColor;
    Canvas.Style = ERenderStyle.STY_Translucent;
    Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
    ScreenPos = MapToScreen(FocusedActor.Location, Canvas);
    Canvas.SetPos(Screenpos.x, Screenpos.y);
    Canvas.DrawText(pawn(FocusedActor).health);
  }
}

simulated function PostRender(Canvas Canvas)
{
//	local float mX,mY,myTempX;
	local int GateCount, BossesAlive;
	local Texture CurrentTexture;
	local float CurrentTextureSize;
	local string text;
//	local int i;

  if ( !PlayerOwner.bShowScores && !bForceScores && !bHideHUD)
	  {			
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/// RIVALS And Followers Spread Display ///////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			PairSort();

			Canvas.Font = MyFonts.GetHugeFont( Canvas.ClipX );
			Canvas.Style = ERenderStyle.STY_Normal;
			Canvas.DrawColor = WhiteColor;

			if ( RivalPRI != None || FollowerPRI != None )
				{
					CurrentX = Canvas.ClipX - (Canvas.ClipX *0.99 );

					if ( RivalPRI != None && FollowerPRI != None )
						CurrentY = Canvas.ClipY - (184 * Scale );
					else
						CurrentY = Canvas.ClipY - (152 * Scale );

					Canvas.SetPos(CurrentX, CurrentY);

					text = OrdinalNumber(string(CurrentPlayerRank));
					Canvas.DrawText(text);
				}

			Canvas.Font = MyFonts.GetBigFont( Canvas.ClipX );
			Canvas.Style = ERenderStyle.STY_Normal;
			Canvas.DrawColor = WhiteColor;

			if ( FollowerPRI != None )
				{
					CurrentX = Canvas.ClipX - (Canvas.ClipX *0.99 );
					CurrentY = Canvas.ClipY - (112 * Scale );

					Canvas.SetPos(CurrentX, CurrentY);

					text = "Follower:"@FollowerPRI.PlayerName@int(FollowerPRI.Score - MyPRI.Score);
					Canvas.DrawText(text);
				}

			if ( RivalPRI != None )
				{
					CurrentX = Canvas.ClipX - (Canvas.ClipX *0.99 );

					if ( FollowerPRI != None )
						CurrentY = Canvas.ClipY - (144 * Scale );
					else
						CurrentY = Canvas.ClipY - (112 * Scale );

					Canvas.SetPos(CurrentX, CurrentY);

					text = "Rival:"@RivalPRI.PlayerName@"+"$int(RivalPRI.Score - MyPRI.Score);
					Canvas.DrawText(text);
				}
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/// Gateway Icon And Counter Display ///////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			if ( u4egreplicationinfo(playerpawn(owner).gamereplicationinfo).bSpawnedBoss == false )
				{

					GateCount = u4egreplicationinfo(playerpawn(owner).gamereplicationinfo).numberofgates;
					Canvas.DrawColor = GreenColor;
					Canvas.Style = ERenderStyle.STY_Translucent;
					Canvas.Font = MyFonts.GetBigFont( Canvas.ClipX );
	  				
					// Gateway Icon
					CurrentTexture = Texture'GatewayIcon';
					CurrentTextureSize = CurrentTexture.Uclamp*0.5;

					CurrentX = Canvas.ClipX - (Canvas.ClipX * PositionX[1]);
					CurrentY = Canvas.ClipY * PositionY[1];

					Canvas.SetPos(CurrentX, CurrentY);
					Canvas.Style = ERenderStyle.STY_Modulated;
					Canvas.DrawIcon(texture'GatewayIconModulated', Scale*0.5);

					Canvas.SetPos(CurrentX, CurrentY);
					Canvas.Style = ERenderStyle.STY_Translucent;
					Canvas.DrawIcon(CurrentTexture, Scale*0.5);
					
					// Gate Number //
					CurrentX = Canvas.ClipX - (Canvas.ClipX * PositionX[1]+(((CurrentTextureSize)*PositionX[2])*Scale));
					CurrentY = (Canvas.ClipY * PositionY[1])+(((CurrentTextureSize)*PositionY[2])*Scale);
					DrawBigNum(Canvas, GateCount, CurrentX, CurrentY);
				}

		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/// Boss Icon And Counter Display //////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			if ( u4egreplicationinfo(playerpawn(owner).gamereplicationinfo).bSpawnedBoss == true )
				{
					BossesAlive = u4egreplicationinfo(playerpawn(owner).gamereplicationinfo).BossesAlive;
					Canvas.DrawColor = WhiteColor;
					Canvas.Style = ERenderStyle.STY_Translucent;
					Canvas.Font = MyFonts.GetBigFont( Canvas.ClipX );
	  				
					// Boss Icon
					CurrentTexture = Texture'BossesIcon';
					CurrentTextureSize = CurrentTexture.Uclamp;

					CurrentX = Canvas.ClipX - (Canvas.ClipX * PositionX[1]);
					CurrentY = Canvas.ClipY * PositionY[1];
					Canvas.SetPos(CurrentX, CurrentY);
					Canvas.DrawIcon(CurrentTexture, Scale);
					
					// Boss Counter //
					CurrentX = Canvas.ClipX - (Canvas.ClipX * PositionX[1]+((CurrentTextureSize*PositionX[2])*Scale));
					CurrentY = (Canvas.ClipY * PositionY[1])+((CurrentTextureSize*PositionY[2])*Scale);
					DrawBigNum(Canvas, BossesAlive, CurrentX, CurrentY);
				}

			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			/// Game Clock /////////////////////////////////////////////////////////////////////////////////////////////////////////////
			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
			CurrentX = Canvas.ClipX - (Canvas.ClipX * PositionX[1]+((CurrentTextureSize*PositionX[3])*Scale));
			CurrentY = (Canvas.ClipY * PositionY[1])+((CurrentTextureSize*PositionY[3])*Scale);
			DrawTimeAt(Canvas, CurrentX, CurrentY);
	  }

  if(bSetRadar)
        DrawActorTip(Canvas);
  else
        bSetRadar=u4egreplicationinfo(playerpawn(owner).gamereplicationinfo).bSpawnedBoss;

  super.PostRender(Canvas);

	if ( PlayerOwner.bBadConnectionAlert && (PlayerOwner.Level.TimeSeconds > 5) )
	{
		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.DrawColor = WhiteColor;
		Canvas.SetPos(Canvas.ClipX - (64*Scale), Canvas.ClipY / 2);
		Canvas.DrawIcon(texture'LAG', Scale);
	}
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////  THE ASSAULT CLOCK  /////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

simulated function DrawTimeAt(Canvas Canvas, float X, float Y)
{
	local int Minutes, Seconds, d;
	local float Clipage;

	Clipage = 0.8;

	if ( PlayerOwner.GameReplicationInfo == None )
		return;

	Canvas.DrawColor = BlueColor;
	Canvas.CurX = X;
	Canvas.CurY = Y;
	Canvas.Style = Style;

	if ( PlayerOwner.GameReplicationInfo.RemainingTime > 0 )
	{
		Minutes = PlayerOwner.GameReplicationInfo.RemainingTime/60;
		Seconds = PlayerOwner.GameReplicationInfo.RemainingTime % 60;
	}
	else
	{
		Minutes = 0;
		Seconds = 0;
	}
	
	if ( Minutes > 0 )
	{
		if ( Minutes >= 10 )
		{
			d = Minutes/10;
			Canvas.DrawTile(Texture'BotPack.HudElements1', Scale*25, 64*Scale, d*25, 0, 25.0, 64.0*Clipage);
			Canvas.CurX += 7*Scale;
			Minutes= Minutes - 10 * d;
		}
		else
		{
			Canvas.DrawTile(Texture'BotPack.HudElements1', Scale*25, 64*Scale, 0, 0, 25.0, 64.0*Clipage);
			Canvas.CurX += 7*Scale;
		}

		Canvas.DrawTile(Texture'BotPack.HudElements1', Scale*25, 64*Scale, Minutes*25, 0, 25.0, 64.0*Clipage);
		Canvas.CurX += 7*Scale;
	} else {
		Canvas.DrawTile(Texture'BotPack.HudElements1', Scale*25, 64*Scale, 0, 0, 25.0, 64.0*Clipage);
		Canvas.CurX += 7*Scale;
	}
	Canvas.CurX -= 4 * Scale;
	Canvas.DrawTile(Texture'BotPack.HudElements1', Scale*25, 64*Scale, 32, 64, 25.0, 64.0*Clipage);
	Canvas.CurX += 3 * Scale;

	d = Seconds/10;
	Canvas.DrawTile(Texture'BotPack.HudElements1', Scale*25, 64*Scale, 25*d, 0, 25.0, 64.0*Clipage);
	Canvas.CurX += 7*Scale;

	Seconds = Seconds - 10 * d;
	Canvas.DrawTile(Texture'BotPack.HudElements1', Scale*25, 64*Scale, 25*Seconds, 0, 25.0, 64.0*Clipage);
	Canvas.CurX += 7*Scale;
}

simulated function SetPosPerc(Canvas Canvas, float InX,float InY ) 
{
	InX = Canvas.ClipX * InX;
	InY = Canvas.ClipY * InY;
	Canvas.SetPos(InX, InY);
}

// Entry point for string messages.
simulated function Message( PlayerReplicationInfo PRI, coerce string Msg, name MsgType )
{
	local int i;
	local Class<LocalMessage> MessageClass;

	switch (MsgType)
	{
		case 'Say':
			MessageClass = class'SayMessagePlus';
			break;
		case 'TeamSay':
			MessageClass = class'TeamSayMessagePlus';
			break;
		case 'CriticalEvent':
			MessageClass = class'CriticalStringPlus';
			LocalizedMessage( MessageClass, 0, None, None, None, Msg );
			return;
		case 'GatewayKillMessage':
			MessageClass = class'GatewayKillMessage';
			LocalizedMessage( MessageClass, 0, None, None, None, Msg );
			return;
		default:
			MessageClass= class'StringMessagePlus';
			break;
	}
	if ( ClassIsChildOf(MessageClass, class'SayMessagePlus') || 
				     ClassIsChildOf(MessageClass, class'TeamSayMessagePlus') )
	{
		FaceTexture = PRI.TalkTexture;
		FaceTeam = TeamColor[PRI.Team];
		if ( FaceTexture != None )
			FaceTime = Level.TimeSeconds + 3;
		if ( Msg == "" )
			return;
	} 

	for (i=0; i<4; i++)
	{
		if ( ShortMessageQueue[i].Message == None )
		{
			// Add the message here.
			ShortMessageQueue[i].Message = MessageClass;
			ShortMessageQueue[i].Switch = 0;
			ShortMessageQueue[i].RelatedPRI = PRI;
			ShortMessageQueue[i].OptionalObject = None;
			ShortMessageQueue[i].EndOfLife = MessageClass.Default.Lifetime + Level.TimeSeconds;
			if ( MessageClass.Default.bComplexString )
				ShortMessageQueue[i].StringMessage = Msg;
			else
				ShortMessageQueue[i].StringMessage = MessageClass.Static.AssembleString(self,0,PRI,Msg);
			return;
		}
	}

	// No empty slots.  Force a message out.
	for (i=0; i<3; i++)
		CopyMessage(ShortMessageQueue[i],ShortMessageQueue[i+1]);

	ShortMessageQueue[3].Message = MessageClass;
	ShortMessageQueue[3].Switch = 0;
	ShortMessageQueue[3].RelatedPRI = PRI;
	ShortMessageQueue[3].OptionalObject = None;
	ShortMessageQueue[3].EndOfLife = MessageClass.Default.Lifetime + Level.TimeSeconds;
	if ( MessageClass.Default.bComplexString )
		ShortMessageQueue[3].StringMessage = Msg;
	else
		ShortMessageQueue[3].StringMessage = MessageClass.Static.AssembleString(self,0,PRI,Msg);
}

function DrawPageFooter( canvas Canvas, string FootText )
{
	local font CanvasFont;

	CanvasFont = Canvas.Font;
	Canvas.Font = MyFonts.GetBigFont(Canvas.ClipX);

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
						
	Canvas.bCenter = true;
	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.SetPos(Canvas.ClipX * 0.025, Canvas.ClipY - 40);
	Canvas.DrawText(FootText);

	Canvas.bCenter = false;
	Canvas.DrawColor = WhiteColor;
	Canvas.Font = CanvasFont;
}

function PairSort()
{
	local int i, a, b;
//	local int Start, End;
	local int Temp;
	local PlayerReplicationInfo CurrentPRI;

	// Wipe everything.
	for ( i = 0; i < ArrayCount(PlayerPRI); i++ )
		PlayerPRI[i] = None;
	
	AvailiblePRI = 0;

	for ( i = 0; i < ArrayCount(PlayerPRI); i++ )
	{
		if (PlayerPawn(Owner).GameReplicationInfo.PRIArray[i] != None)
		{
			CurrentPRI = PlayerPawn(Owner).GameReplicationInfo.PRIArray[i];
			if ( !CurrentPRI.bIsSpectator || CurrentPRI.bWaitingPlayer )
			{
				PlayerPRI[AvailiblePRI] = CurrentPRI;
				AvailiblePRI++;
			}
		}
	}

	// Fill Up Score Array
	for ( i = 0; i < AvailiblePRI; i++ )
		{
			if ( PlayerPRI[i] != None )
				{
					PlayerScore[i] = PlayerPRI[i].Score;
				}
		}

	// Classic Bubble Sort Will Do For Now.
	for ( a = 0; a != AvailiblePRI; a++ )
		{
			for ( b = 0; b != AvailiblePRI; b++ )
				{
					if ( PlayerScore[b] < PlayerScore[a] )
						{
							Temp = PlayerScore[a];
							PlayerScore[a] = PlayerScore[b];
							PlayerScore[b] = Temp;

							CurrentPRI = PlayerPRI[a];
							PlayerPRI[a] = PlayerPRI[b];
							PlayerPRI[b] = CurrentPRI;
						}
				}
		}

	// Fill in names in the sorted order and determin our rival and follower
	for ( i = 0; i < AvailiblePRI; i++ )
		{
			PlayerName[i] = PlayerPRI[i].PlayerName;

			if ( PlayerPRI[i] == PlayerPawn(Owner).PlayerReplicationInfo )
				{
					if ( i != 0 )
						{
							if ( PlayerPRI[i-1] != None && PlayerPRI[i-1] != MyPRI )
								RivalPRI = PlayerPRI[i-1];
							else
								RivalPRI = None;
						}
					else
						RivalPRI = None;

					MyPRI = PlayerPRI[i];
					CurrentPlayerRank = i+1;

					if ( i != AvailiblePRI )
						{
							if ( PlayerPRI[i+1] != None && PlayerPRI[i+1] != MyPRI )
								FollowerPRI = PlayerPRI[i+1];
							else
								FollowerPRI = None;
						}
					else
						FollowerPRI = None;
				}
		}



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
      bSetRadar=False
      hudoff=2.000000
      PositionX(0)=0.000000
      PositionX(1)=0.000000
      PositionX(2)=0.000000
      PositionX(3)=0.000000
      PositionX(4)=0.000000
      PositionX(5)=0.000000
      PositionX(6)=0.000000
      PositionX(7)=0.000000
      PositionX(8)=0.000000
      PositionX(9)=0.000000
      PositionX(10)=0.000000
      PositionX(11)=0.000000
      PositionX(12)=0.000000
      PositionX(13)=0.000000
      PositionX(14)=0.000000
      PositionX(15)=0.000000
      PositionX(16)=0.000000
      PositionX(17)=0.000000
      PositionX(18)=0.000000
      PositionX(19)=0.000000
      PositionX(20)=0.000000
      PositionX(21)=0.000000
      PositionX(22)=0.000000
      PositionX(23)=0.000000
      PositionX(24)=0.000000
      PositionX(25)=0.000000
      PositionX(26)=0.000000
      PositionX(27)=0.000000
      PositionX(28)=0.000000
      PositionX(29)=0.000000
      PositionX(30)=0.000000
      PositionX(31)=0.000000
      PositionY(0)=0.000000
      PositionY(1)=0.000000
      PositionY(2)=0.000000
      PositionY(3)=0.000000
      PositionY(4)=0.000000
      PositionY(5)=0.000000
      PositionY(6)=0.000000
      PositionY(7)=0.000000
      PositionY(8)=0.000000
      PositionY(9)=0.000000
      PositionY(10)=0.000000
      PositionY(11)=0.000000
      PositionY(12)=0.000000
      PositionY(13)=0.000000
      PositionY(14)=0.000000
      PositionY(15)=0.000000
      PositionY(16)=0.000000
      PositionY(17)=0.000000
      PositionY(18)=0.000000
      PositionY(19)=0.000000
      PositionY(20)=0.000000
      PositionY(21)=0.000000
      PositionY(22)=0.000000
      PositionY(23)=0.000000
      PositionY(24)=0.000000
      PositionY(25)=0.000000
      PositionY(26)=0.000000
      PositionY(27)=0.000000
      PositionY(28)=0.000000
      PositionY(29)=0.000000
      PositionY(30)=0.000000
      PositionY(31)=0.000000
      CurrentX=0.000000
      CurrentY=0.000000
      CurrentPlayerRank=0
      PlayerPRI(0)=None
      PlayerPRI(1)=None
      PlayerPRI(2)=None
      PlayerPRI(3)=None
      PlayerPRI(4)=None
      PlayerPRI(5)=None
      PlayerPRI(6)=None
      PlayerPRI(7)=None
      PlayerPRI(8)=None
      PlayerPRI(9)=None
      PlayerPRI(10)=None
      PlayerPRI(11)=None
      PlayerPRI(12)=None
      PlayerPRI(13)=None
      PlayerPRI(14)=None
      PlayerPRI(15)=None
      PlayerPRI(16)=None
      PlayerPRI(17)=None
      PlayerPRI(18)=None
      PlayerPRI(19)=None
      PlayerPRI(20)=None
      PlayerPRI(21)=None
      PlayerPRI(22)=None
      PlayerPRI(23)=None
      PlayerPRI(24)=None
      PlayerPRI(25)=None
      PlayerPRI(26)=None
      PlayerPRI(27)=None
      PlayerPRI(28)=None
      PlayerPRI(29)=None
      PlayerPRI(30)=None
      PlayerPRI(31)=None
      FollowerPRI=None
      MyPRI=None
      RivalPRI=None
      AvailiblePRI=0
      PlayerName(0)=""
      PlayerName(1)=""
      PlayerName(2)=""
      PlayerName(3)=""
      PlayerName(4)=""
      PlayerName(5)=""
      PlayerName(6)=""
      PlayerName(7)=""
      PlayerName(8)=""
      PlayerName(9)=""
      PlayerName(10)=""
      PlayerName(11)=""
      PlayerName(12)=""
      PlayerName(13)=""
      PlayerName(14)=""
      PlayerName(15)=""
      PlayerName(16)=""
      PlayerName(17)=""
      PlayerName(18)=""
      PlayerName(19)=""
      PlayerName(20)=""
      PlayerName(21)=""
      PlayerName(22)=""
      PlayerName(23)=""
      PlayerName(24)=""
      PlayerName(25)=""
      PlayerName(26)=""
      PlayerName(27)=""
      PlayerName(28)=""
      PlayerName(29)=""
      PlayerName(30)=""
      PlayerName(31)=""
      PlayerScore(0)=0
      PlayerScore(1)=0
      PlayerScore(2)=0
      PlayerScore(3)=0
      PlayerScore(4)=0
      PlayerScore(5)=0
      PlayerScore(6)=0
      PlayerScore(7)=0
      PlayerScore(8)=0
      PlayerScore(9)=0
      PlayerScore(10)=0
      PlayerScore(11)=0
      PlayerScore(12)=0
      PlayerScore(13)=0
      PlayerScore(14)=0
      PlayerScore(15)=0
      PlayerScore(16)=0
      PlayerScore(17)=0
      PlayerScore(18)=0
      PlayerScore(19)=0
      PlayerScore(20)=0
      PlayerScore(21)=0
      PlayerScore(22)=0
      PlayerScore(23)=0
      PlayerScore(24)=0
      PlayerScore(25)=0
      PlayerScore(26)=0
      PlayerScore(27)=0
      PlayerScore(28)=0
      PlayerScore(29)=0
      PlayerScore(30)=0
      PlayerScore(31)=0
}
