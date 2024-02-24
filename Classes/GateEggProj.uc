//=============================================================================
// GateEggProj.
//=============================================================================
class GateEggProj expands eggproj;

var gateSpinner spider;

function Destroyed()
{
 local Rotator newRot;
 
 newRot = Rotation;    
 newRot.Pitch = 0; 
 newRot.Roll = 0;    
 spider=spawn(class'gateSpinner',,,,newRot);
	super.Destroyed();
}

defaultproperties
{
      spider=None
}
