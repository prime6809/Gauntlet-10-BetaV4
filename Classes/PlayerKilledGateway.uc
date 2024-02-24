//=============================================================================
// PlayerKilledGateway.
//=============================================================================
class PlayerKilledGateway expands CriticalEventPlus;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if ( gateways(OptionalObject) != None )
		return "You have destroyed the"@gateways(OptionalObject).GateName@"Gateway!";
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

        P.ClientPlaySound(sound'GateDestroyedSound',, true);
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

defaultproperties
{
}
