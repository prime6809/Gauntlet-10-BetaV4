//=============================================================================
// SpirlBlast2S.
//=============================================================================
class SpirlBlast2S extends SpirlBlast2;

//=============================================================================
// starterbolt.
//=============================================================================

var float AnimTime, rollme;

replication
{
	// Things the server should send to the client.
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	rollme = frand() * 65535;
}
simulated function Tick(float DeltaTime)
{
	local vector X,Y,Z;
	local rotator rot;

	if(ScaleGlow<0.7) AnimTime += DeltaTime;
	if ( AnimTime > 0.1 )
	{
		AnimTime -= 0.1;
		//SpriteFrame++;
		if ( SpriteFrame == ArrayCount(SpriteAnim) )
			SpriteFrame = 4;//0;
		Skin = SpriteAnim[SpriteFrame];
	}

	ScaleGlow -= (DeltaTime*1.00);	

	//drawscale *= (1+0.3*DeltaTime);
	//beamsize *= (1+0.3*DeltaTime);
	
	GetAxes(Rotation,X,Y,Z);
	//SetLocation(location + beamsize*0.3*DeltaTime*X);

	rollme += (100*DeltaTime)*80;
	rot = rotation;
	rot.roll = rollme;
	//SetRotation(rot);

	CheckBeam(X, DeltaTime);
}

defaultproperties
{
      AnimTime=0.000000
      rollme=0.000000
      RemoteRole=ROLE_SimulatedProxy
      Mesh=Mesh'Gauntlet-10-BetaV4.SpirlBlast2S'
      LightType=LT_Steady
      LightEffect=LE_NonIncidence
}
