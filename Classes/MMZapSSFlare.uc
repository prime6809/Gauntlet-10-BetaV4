//=============================================================================
// MMZapSSFlare.
//=============================================================================
class MMZapSSFlare extends ZapperSegS;

simulated function Tick(float DeltaTime)
{
	local vector X,Y,Z;
	local Pawn P;
	local int PHand;

	AnimTime += DeltaTime;
	if ( AnimTime > 0.05 )
	{
		AnimTime -= 0.05;
		SpriteFrame++;
		if ( SpriteFrame == ArrayCount(SpriteAnim) )
			SpriteFrame = 0;
		Skin = SpriteAnim[SpriteFrame];
	}

	// orient with respect to OWNER!
	P = Pawn(Owner);
	if ( P != None )
	{
		if ( (Level.NetMode == NM_Client) && (!P.IsA('PlayerPawn') || (PlayerPawn(P).Player == None)) )
		{
			SetRotation(AimRotation); 
			P.ViewRotation = AimRotation;
		}
		else 
		{
			AimRotation = P.ViewRotation;
			SetRotation(AimRotation);
		}
		GetAxes(AimRotation,X,Y,Z);
		if(bCenter)PHand=0;
		else if(bRight)PHand=1;
		else PHand=-1;
		SetLocation(P.Location + P.CollisionRadius*X + PHand*0.5*P.CollisionRadius*Y + 0.55*P.CollisionHeight*Z);
	}
	else
		GetAxes(Rotation,X,Y,Z);

	X.X+=(0.2*(0.5-frand()));
	X.Y+=(0.2*(0.5-frand()));
	X.Z+=(0.2*(0.5-frand()));
	X=Normal(X);
	SetRotation(Rotator(X));
//SKIP CHECKBEAM
//	CheckBeam(X, DeltaTime);
}

defaultproperties
{
      SpriteAnim(0)=Texture'Botpack.FlareFX.utflare5'
      SpriteAnim(1)=Texture'Botpack.FlareFX.utflare5'
      SpriteAnim(2)=Texture'Botpack.FlareFX.utflare5'
      SpriteAnim(3)=Texture'Botpack.FlareFX.utflare5'
      SpriteAnim(4)=Texture'Botpack.FlareFX.utflare5'
      bRight=False
      bCenter=True
      LifeSpan=0.800000
      Skin=Texture'Botpack.FlareFX.utflare5'
      Mesh=Mesh'Gauntlet-10-BetaV4.MzFlX'
      DrawScale=1.000000
}
