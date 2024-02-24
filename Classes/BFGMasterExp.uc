//=============================================================================
// BFGMasterExp.
//=============================================================================
class BFGMasterExp expands BFGexplosion;

var float DamageMod;

simulated function timer()
{
	local Pawn p;
	local BFGexplosion e;
	
	if(Texture==Texture'bfgexplrays')	Texture=Texture'bfgexpl3'; else
	if(Texture==Texture'bfgexpl3')
	{
		Texture=Texture'bfgexpl2';
		ForEach VisibleActors(class'Pawn',p,500){
			if((p!=Pawn(Owner))||((VSize(Location-p.Location))<250)){
				e=spawn(class'BFGexplosion',self,,p.Location);
				e.DrawScale=2*DamageMod*((550-(VSize(Location-p.Location)))/450);
				e.LightRadius*=DamageMod;
				p.TakeDamage((550-(VSize(Location-p.Location)))*0.3*DamageMod,Instigator
					,p.Location, Normal(Location-p.Location),'jolted');
			}
		}	
	}else
	if(Texture==Texture'bfgexpl2')	Texture=Texture'bfgexpl1'; else
	if(Texture==Texture'bfgexpl1')	Texture=Texture'bfgexpl0'; else
	{
		spawn(class'WeaponLight');
		Destroy();
	}
	SetTimer(0.05,false);
}

simulated function BeginPlay(){
	Super.BeginPlay();
	LightRadius *= DamageMod*u4egauntlet(Level.Game).SafeLightScale;
}

defaultproperties
{
      DamageMod=0.000000
      DrawScale=2.000000
      LightBrightness=200
      LightRadius=128
}
