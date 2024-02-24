//=============================================================================
// gateEggs.
//=============================================================================
class gateEggs expands EGGS;

var float speed;

function Destroyed()
{
  local Rotator newRot;

 newRot = Rotation;    
 newRot.Pitch = 0; 
 newRot.Roll = 0;
 spawn(class'gateSpinner',,,,newRot);
 bPushSoundPlaying = false;	
	super.Destroyed();
}

function Trigger( actor Other, pawn EventInstigator )
{
	if(EventInstigator!=none)
	Instigator = EventInstigator;
 bOnlyTriggerable=false;
	Birth();
}

function Birth()
{
  local splash2 sp;
  local GreenBloodPuff GBP;
 
  GBP=spawn(class'GreenBloodPuff');
  if(GBP!=none)
   GBP.drawscale=2.0;
  PlaySound(hatchsound);
  sp=spawn(class'splash2');
  spawn(class'GreenGelPuff');
  skinnedFrag(class'Fragment1', texture'Jseed1', location, Fragsize, FragChunks);   
}

auto State Active
{  

	function HitWall (vector HitNormal, actor Wall)
	{
		local float speed;

		Velocity = 0.5*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity); 
  speed = VSize(Velocity);

		RotationRate.Yaw = RotationRate.Yaw*0.75;
		RotationRate.Roll = RotationRate.Roll*0.75;
		RotationRate.Pitch = RotationRate.Pitch*0.75;

	 if (speed < 30)
			bBounce = False;
	}	

 function timer()
 {
  local Pawn p;
  local float dist;
  local vector Dir;
   
  if ( bOnlyTriggerable )
		return;
  for (p=level.pawnlist;p!=none;p=p.nextpawn)    
		{
		 if(p.IsA('PlayerPawn') && PlayerPawn(p).bCollideWorld 
     && PlayerPawn(p).PlayerReplicationInfo!=none 
     && !PlayerPawn(p).PlayerReplicationInfo.bIsSpectator )
   {
    Dir = p.Location - Location;
 	  dist = VSize(Dir);
 	  if ( (dist < Range) )
    {
     Birth();
     disable('timer');
 	 	 break;
    } 
   }
		}
	} 

	function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, name damageType)
	{
		Instigator = InstigatedBy;
		if (Health<=0) Return;
		if ( Instigator != None )
			MakeNoise(1.0);
  if ( !bOnlyTriggerable )
		Health -= NDamage;
		if (Health <=0 )
  	Birth();
  else
		{
			SetPhysics(PHYS_Falling);     
   Momentum.Z = 2000;
   Velocity = Velocity+Momentum*0.016;
   speed = VSize(Velocity);

			if (speed>200)
   {
		 	DesiredRotation = RotRand();
	 	 RotationRate.Yaw = 200000*FRand() - 100000;
		  RotationRate.Pitch = 200000*FRand() - 100000;
		  RotationRate.Roll = 200000*FRand() - 100000;
    bFixedRotationDir=True;
    bBounce = True;
			}  
		}
	}
Begin:
if ( !bOnlyTriggerable )
 {
 settimer(0.3,true);
 if (bUseHatchtimer )//force spawn
  {
  sleep(hatchtime);
	 Birth();
  }
 } 
}

singular function Bump( actor Other )
{
	local float speed, oldZ;
	if( bPushable && (Pawn(Other)!=None) && (Other.Mass > 40) )
	{
		bBobbing = false;
		oldZ = Velocity.Z;
		speed = VSize(Other.Velocity);
		Velocity = Other.Velocity * FMin(120.0, 20 + speed)/speed;
		if ( Physics == PHYS_None ) {
			Velocity.Z = 25; 
	}
	else
		 	Velocity.Z = oldZ;
		SetPhysics(PHYS_Falling);
  if ( bOnlyTriggerable )
  SetTimer(0.3,False);
		Instigator = Pawn(Other);
	}                        
}

defaultproperties
{
      speed=0.000000
}
