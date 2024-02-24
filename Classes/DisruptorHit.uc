//=============================================================================
// DisruptorHit.
//=============================================================================
class DisruptorHit extends UT_ShieldBeltEffect;

simulated function PostBeginPlay()
{
	ScaleGlow=1.0;
	if ( !Level.bHighDetailMode && ((Level.NetMode == NM_Standalone) || (Level.NetMode == NM_Client)) )
	{
		Timer();
		bHidden = true;
		SetTimer(1.0, true);
	}
}

simulated function Timer()
{
	bHidden = true;
	Owner.SetDisplayProperties(Owner.Style, LowDetailTexture, false, true);
}

simulated function Tick(float DeltaTime)
{
	if ( Owner != None )
	{
		if ( (bHidden != Owner.bHidden) && (Level.NetMode != NM_DedicatedServer) )
			bHidden = Owner.bHidden;
	}
	else destroy();

	if ( Level.NetMode != NM_DedicatedServer )
	{
		Fatness = 255-(Lifespan/Default.Lifespan)*128;
		ScaleGlow = (Lifespan/Default.Lifespan)*1.0;
		AmbientGlow = ScaleGlow * 255;		
//		DrawScale = (Lifespan/Default.Lifespan)*Default.DrawScale;
	}
}

defaultproperties
{
      bOwnerNoSee=False
      LifeSpan=0.350000
      MultiSkins(0)=Texture'Botpack.FlareFX.utflare1'
      MultiSkins(1)=Texture'Botpack.FlareFX.utflare2'
      MultiSkins(2)=Texture'Botpack.FlareFX.utflare3'
      MultiSkins(3)=Texture'Botpack.FlareFX.utflare4'
      MultiSkins(4)=Texture'Botpack.FlareFX.utflare5'
      MultiSkins(5)=Texture'Botpack.FlareFX.utflare6'
      MultiSkins(6)=Texture'Botpack.FlareFX.utflare7'
      MultiSkins(7)=Texture'Botpack.FlareFX.utflare8'
}
