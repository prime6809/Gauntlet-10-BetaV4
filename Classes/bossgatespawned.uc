class BossGateSpawned extends CriticalEventPlus;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
        switch(SWITCH)
        {
                case 0:
                        return "All Gateways Destroyed! Boss Spawned!";
                        break;
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
        P.ClientPlaySound(sound'yousuck',, true);
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

defaultproperties
{
      bBeep=False
      DrawColor=(R=255,G=0,B=0)
}
