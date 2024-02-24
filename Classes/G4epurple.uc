//=============================================================================
// G4epurple.
//=============================================================================
class G4epurple extends G4e;

function BlowUp(vector HitLocation)
{
}
simulated function Explosion(vector HitLocation)
{
	local WormHole W;

	MakeNoise(1.0);
		W=Spawn( class 'Wormhole',, '', Location,Rotation);
		W.GotoState('buildhole');
 	Destroy();
}

defaultproperties
{
      GP4eSpeed=0.000000
      MyDamageType="G4eWpurpleDeath"
      ExplosionDecal=None
      Skin=Texture'Gauntlet-10-BetaV4.Skins.JG4ePurple'
}
