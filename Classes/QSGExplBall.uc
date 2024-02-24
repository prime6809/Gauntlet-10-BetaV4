//=============================================================================
// QSGExplBall.
// Revised a little bit by nOs*Wildcard
//=============================================================================
class QSGExplBall expands Effects;

auto state explode
{
	simulated function BeginState()
	{
		DrawScale = 0.1;
		LightRadius = default.LightRadius*u4egauntlet(Level.Game).SafeLightScale;
	}

	simulated function tick(float dtime)
	{
		if ( AmbientGlow > 0 )
			AmbientGlow = 255 * (lifespan/default.lifespan);
		else
			destroy();

		DrawScale = 20 - (20 * (lifespan/default.lifespan));
		LightBrightness = 255 * (lifespan/default.lifespan);
	}
}

defaultproperties
{
      RemoteRole=ROLE_SimulatedProxy
      LifeSpan=2.000000
      DrawType=DT_Mesh
      Style=STY_Translucent
      Texture=WetTexture'Gauntlet-10-BetaV4.QSG_Sphere_Ripple'
      Mesh=LodMesh'Gauntlet-10-BetaV4.Sphere'
      DrawScale=0.100000
      ScaleGlow=0.000000
      AmbientGlow=255
      bUnlit=True
      bMeshEnviroMap=True
      LightType=LT_Steady
      LightEffect=LE_NonIncidence
      LightBrightness=255
      LightHue=170
      LightSaturation=20
      LightRadius=128
}
