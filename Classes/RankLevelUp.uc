//=============================================================================
// RankLevelUp.
//=============================================================================
class RankLevelUp expands CriticalEventPlus;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if ( GauntletPlayerReplicationInfo(RelatedPRI_1).RankTitleNext != "" )
		return "You have leveled up to:"@GauntletPlayerReplicationInfo(RelatedPRI_1).RankTitleNext;
	else
		{
			if ( GauntletPlayerReplicationInfo(RelatedPRI_1).RankTitle != "" )
				return "You have leveled up to:"@GauntletPlayerReplicationInfo(RelatedPRI_1).RankTitle;
			else
				{
					if ( GauntletPlayerReplicationInfo(RelatedPRI_1).RankTitlePrevious != "" )
						return "You have leveled up to:"@GauntletPlayerReplicationInfo(RelatedPRI_1).RankTitlePrevious;
					else
						{
							return "WERE OUT OF RANKS?!? WTF??";
							return "NEXT:"@GauntletPlayerReplicationInfo(RelatedPRI_1).RankTitleNext;
							return "CURRENT:"@GauntletPlayerReplicationInfo(RelatedPRI_1).RankTitle;
							return "PREVIOUS:"@GauntletPlayerReplicationInfo(RelatedPRI_1).RankTitlePrevious;
						}
				}
		}
}

static simulated function ClientReceive( 
	PlayerPawn P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	 GetString( Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

        P.ClientPlaySound(sound'SpreeSound',, true);
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

defaultproperties
{
}
