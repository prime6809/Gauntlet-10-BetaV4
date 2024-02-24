//=============================================================================
// Angel.
//=============================================================================
class Angel extends Warlord;

var() class<projectile> altProj[4];
var() int altProj2Shots[4];
var int ix;

function PlayRangedAttack()
{
	local float decision;
	local vector X,Y,Z, projStart;
	local rotator projRotation;

	GetAxes(Rotation,X,Y,Z);

		decision = FRand();
			if ( decision < 0.45 )	ix=0; 
		else	if ( decision < 0.7 )	ix=1;
		else	if ( decision < 0.88 )	ix=2;
		else				ix=3;

	RangedProjectile=altProj[ix];

	if( altProj2Shots[ix]!=0 )
	{
		PlayAnim('Fire');
		projStart = Location - 0.5 * CollisionRadius * Y + CollisionRadius * X + 0.55*CollisionHeight*Z;
		projRotation = AdjustAim(ProjectileSpeed, projStart, 0, bLeadTarget, bWarnTarget); 
		spawnMe(RangedProjectile, projStart,projRotation,-1);
		projStart = Location + 0.5 * CollisionRadius * Y + CollisionRadius * X + 0.55*CollisionHeight*Z;
		projRotation = AdjustAim(ProjectileSpeed, projStart, 0, bLeadTarget, bWarnTarget); 
		spawnMe(RangedProjectile, projStart,projRotation,+1);
	}
	else
	{
		PlayAnim('FlyFire');
		projStart = Location + CollisionRadius * X + 0.55*CollisionHeight*Z;
		projRotation = AdjustAim(ProjectileSpeed, projStart, 0, bLeadTarget, bWarnTarget); 
		spawnMe(RangedProjectile, projStart,projRotation,0);
	}	
	if((RangedProjectile==class'BFGBall')||(RangedProjectile==class'NukeBall'))
		RangedProjectile=altProj[0];
}
function spawnMe(class<actor> ProjClass, vector Start, rotator rot, int PHand)
{
	local vector X,Y,Z;
	local actor proj;
	local ZapperSegS ZS,ZS2;
	local ZapSeekS ZSe;

	proj=spawn(ProjClass ,self,'',Start, rot);

	if(ClassIsChildOf(ProjClass, class'ZapperSegS')) ZS=ZapperSegS(proj);
	else if(ClassIsChildOf(ProjClass, class'ZapSeekS')) ZSe=ZapSeekS(proj);

	if(ZS!=None)
	{
		ZS2=spawn(class'MMZapSSFlare' ,self,'',Start, rot);
		if(PHand==-1) {ZS.bCenter=false;ZS.bRight=false;ZS2.bCenter=false;ZS2.bRight=false;}
		else if(PHand==1) {ZS.bCenter=false;ZS.bRight=true;ZS2.bCenter=false;ZS2.bRight=true;}
	}
	else if(ZSe!=None)
	{
		ZS2=spawn(class'MMZapSSFlare' ,self,'',Start, rot);
		if(PHand==-1) {ZSe.bCenter=false;ZSe.bRight=false;ZS2.bCenter=false;ZS2.bRight=false;}
		else if(PHand==1) {ZSe.bCenter=false;ZSe.bRight=true;ZS2.bCenter=false;ZS2.bRight=true;}
	}

	if(!ClassIsChildOf(ProjClass, class'Rail2Proj')) return;

	GetAxes(rot,X,Y,Z);
	Start += normal(X)*0.925*class'SpirlBlast2S'.Default.BeamSize;
	spawn(class'SpirlBlast2S' ,self,'',Start, rot);
}

defaultproperties
{
      altProj(0)=Class'Gauntlet-10-BetaV4.ZapSeekS'
      altProj(1)=None
      altProj(2)=Class'Gauntlet-10-BetaV4.Rail2Proj'
      altProj(3)=Class'Gauntlet-10-BetaV4.Rail2Proj'
      altProj2Shots(0)=0
      altProj2Shots(1)=1
      altProj2Shots(2)=0
      altProj2Shots(3)=0
      ix=0
      bTeleportWhenHurt=True
      TimeBetweenAttacks=1.500000
      RefireRate=0.250000
      bMovingRangedAttack=False
      bIsBoss=False
      RangedProjectile=None
      GroundSpeed=200.000000
      WaterSpeed=100.000000
      AirSpeed=200.000000
      Health=750
      ReducedDamageType="zapped"
      Texture=Texture'Gauntlet-10-BetaV4.Skins.chr_blus'
      Skin=Texture'Gauntlet-10-BetaV4.Skins.Jangel05B'
      Mesh=Mesh'Gauntlet-10-BetaV4.angel05'
      DrawScale=2.000000
}
