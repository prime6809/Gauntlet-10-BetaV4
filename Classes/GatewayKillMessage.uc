//=============================================================================
// GatewayKillMessage.
//=============================================================================
class GatewayKillMessage expands GauntletMessages;

static function float GetOffset(int Switch, float YL, float ClipY )
{
	return ClipY - YL - (64.0/768)*ClipY;
}

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if ( OptionalObject != None )
		return Class<gateways>(OptionalObject).Default.GateName@"Gateway Destroyed! +"$string(gateways(OptionalObject).Reward);
}

static function int GetFontSize( int Switch )
{
	return 1;
}

defaultproperties
{
      bBeep=True
}
