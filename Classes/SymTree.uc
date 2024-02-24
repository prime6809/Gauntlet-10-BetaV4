//=============================================================================
// SymTree.
// Written By nOs*Wildcard
//=============================================================================
class SymTree expands Actor;

// Editor Settings
var() bool Disable;

// Tree Specifications
var rotator TreeDirection;
var float TreeHeight;
var float TrunkHeight;
var float TrunkSegments;
var float BranchSegments;
var float BranchRadius;

// Final Result
var Vector VectorList[16];
var float VectorTrunkSegment[arraycount(VectorList)];
var float VectorLength[arraycount(VectorList)];
var rotator VectorAngle[arraycount(VectorList)];

// Tree Structure
var vector Trunk[arraycount(VectorList)];
var vector Branch[arraycount(VectorList)];

var class<Actor> SpawnClass;

// Miscellaneous
var Vector NullVector;
var int VectorIndex;

// Base
var FlagBase RedBase, Bluebase, GreenBase, YellowBase;

function CloneTree( SymTree inTree )
{
	local int i;
//	local vector TempVect;

	for ( i = 0; i < arraycount(VectorList); i++ )
		{
/*
			TempVect = Location;
			TempVect.z = inTree.Trunk[i].z;

			Spawn(class'WarHeadLauncher',,,TempVect);
*/
			log("Trunk["$i$"]:"@Trunk[i]);
			inTree.ArrayAssign(0,i,string(Trunk[i]));
		}

	for ( i = 0; i < arraycount(VectorList); i++ )
		inTree.ArrayAssign(1,i,string(VectorLength[i]));

	for ( i = 0; i < arraycount(VectorList); i++ )
		inTree.ArrayAssign(1,i,string(VectorAngle[i]));

	inTree.ConstructClone();
}

function ArrayAssign( int ArrayID, int Element, string Value )
{
	// Trunk
	if ( ArrayID == 0 )
		{
			Trunk[Element] = Vector(Value);
			Spawn(class'WarHeadLauncher',,,Trunk[Element]);
		}
	// Length
	if ( ArrayID == 1 )
		VectorLength[Element] = float(Value);
	// Angle
	if ( ArrayID == 2 )
		VectorAngle[Element] = rotator(Value);

	if ( Element == 17 || Element == 32 || Element == 7 || Element == 97 )
		{
			log("");
			log("Trunk[Element] ="@Trunk[Element]);
			log("VectorLength[Element] ="@VectorLength[Element]);
			log("VectorAngle[Element] ="@VectorAngle[Element]);	
		}
}

function FindFlagBases()
{
	local FlagBase FB;

	foreach AllActors(class'FlagBase',FB)
		{
			if ( FB.Team == 0 )
				RedBase = FB;
			if ( FB.Team == 1 )
				BlueBase = FB;
			if ( FB.Team == 2 )
				GreenBase = FB;
			if ( FB.Team == 3 )
				YellowBase = FB;
		}
}

event PostBeginPlay()
{
	if ( Disable == true )
		return;

	SpawnClass = class'TarydiumBarrel';

	FindFlagBases();

	// Tree Parameters
	TrunkSegments = 32;
	TrunkHeight = 2048;
	TrunkSegments = min(TrunkSegments,arraycount(Trunk));

	TreeHeight = TrunkHeight * TrunkSegments;

	BranchSegments = 256;
	BranchRadius = 4096;
	TrunkSegments = min(TrunkSegments,arraycount(Trunk));

	// Build The Tree
/*
	BuildTree();
	SpawnOnSymTree();
*/
}

function Rotate( int IntAngle )
{
	local int i;
	local rotator Angle;
	local vector TempVect;

	for ( i = 0; VectorList[i] != NullVector && i < arraycount(VectorList) ; i++ )
		{
			// Build At Level Of Trunk
			TempVect = Trunk[0];
			TempVect.z = VectorList[i].z;

			// Rotate
			Angle = VectorAngle[i];
			Angle.Yaw += IntAngle;
			//Angle.Yaw += (65536/360) * IntAngle;

			VectorList[i] = ( TempVect + Vector(Angle) * VectorLength[i] );
		}

	SpawnOnSymTree();
}

function Randomize()
{
	BuildTree();
	SpawnOnSymTree();
}

function BuildTree()
{
	BuildTrunk();

	// Only when were done/
	VectorIndex = 0;
}

function BuildTrunk()
{
	local int i;
	local float progress;

	for ( i = 0; i != TrunkSegments; i++ )
		{
			progress = i / TrunkSegments;
			progress *= TrunkHeight;

			Trunk[i].x = location.x;
			Trunk[i].y = location.y;
			Trunk[i].z = ((location.z - TrunkHeight ) + progress * 2);
			BuildBranch(i);
		}
}

function BuildBranch( int TrunkSegment )
{
	local int i;
	local float progress;
	local Rotator Angle;
	local float Chance, Distribution;
	local float BranchDistance;
	local float BaseYaw;

	// We Want Branches, Not Spokes
	BaseYaw = Rand(65536);

	for ( i = 0; i != BranchSegments; i++ )
		{
			progress = i / BranchSegments;

			Angle.Pitch = 0;
			Angle.Roll = 0;
			Angle.Yaw = BaseYaw + (65536 * progress);

			Angle += Rotator(Location - RedBase.Location);

			BranchDistance = BranchRadius * FRand();
			Branch[i] = ( Trunk[TrunkSegment] + Vector(Angle) * BranchDistance );

			// Temp Stuff For Testing
			Chance = (TrunkSegments * BranchSegments) / arraycount(VectorList);

			Distribution = (BranchDistance / BranchRadius) * 100;

			if ( Rand(Chance) == 0 && VectorIndex != (arraycount(VectorList)-1)*0.2
			&& Rand(Distribution) >= 5  )
				{
					VectorTrunkSegment[VectorIndex] = TrunkSegment; 
					VectorAngle[VectorIndex] = Angle;
					VectorLength[VectorIndex] = BranchDistance;
					DropVine(Branch[i]);
				}
		}
}

function ConstructClone()
{
	local int i;

	for ( i = 0; i < arraycount(VectorList); i++ )
		{
			Branch[i] = ( Trunk[VectorTrunkSegment[i]] + Vector(VectorAngle[i]) * VectorLength[i] );
			DropVine(Branch[i]);
		}
}

function DropVine( Vector InVect )
{
//	local Actor TraceActor;
	local Vector Vine;
	local Vector VineNormal;
	local Vector VineStart;
	local Vector VineEnd;

	VineStart = InVect;
	VineEnd = VineStart;
	VineEnd.z = VineStart.z - TreeHeight*8;
	
	// Drop The Vine Via Trace
	Trace(Vine,VineNormal,VineEnd,VineStart);

	VectorList[VectorIndex] = Vine;
	VectorIndex ++;
}

function SpawnOnSymTree()
{
	local int i;

	for ( i = 0; VectorList[i] != NullVector; i++ )
		{
			Spawn(SpawnClass,,,VectorList[i]);
		}
}

function vector GetSpot()
{
	local int i;

	for ( i = 0; VectorList[i] != NullVector; i++ )
		{
			return VectorList[i];
		}
}

defaultproperties
{
      Disable=False
      TreeDirection=(Pitch=0,Yaw=0,Roll=0)
      TreeHeight=0.000000
      TrunkHeight=0.000000
      TrunkSegments=0.000000
      BranchSegments=0.000000
      BranchRadius=0.000000
      VectorList(0)=(X=0.000000,Y=0.000000,Z=0.000000)
      VectorList(1)=(X=0.000000,Y=0.000000,Z=0.000000)
      VectorList(2)=(X=0.000000,Y=0.000000,Z=0.000000)
      VectorList(3)=(X=0.000000,Y=0.000000,Z=0.000000)
      VectorList(4)=(X=0.000000,Y=0.000000,Z=0.000000)
      VectorList(5)=(X=0.000000,Y=0.000000,Z=0.000000)
      VectorList(6)=(X=0.000000,Y=0.000000,Z=0.000000)
      VectorList(7)=(X=0.000000,Y=0.000000,Z=0.000000)
      VectorList(8)=(X=0.000000,Y=0.000000,Z=0.000000)
      VectorList(9)=(X=0.000000,Y=0.000000,Z=0.000000)
      VectorList(10)=(X=0.000000,Y=0.000000,Z=0.000000)
      VectorList(11)=(X=0.000000,Y=0.000000,Z=0.000000)
      VectorList(12)=(X=0.000000,Y=0.000000,Z=0.000000)
      VectorList(13)=(X=0.000000,Y=0.000000,Z=0.000000)
      VectorList(14)=(X=0.000000,Y=0.000000,Z=0.000000)
      VectorList(15)=(X=0.000000,Y=0.000000,Z=0.000000)
      VectorTrunkSegment(0)=0.000000
      VectorTrunkSegment(1)=0.000000
      VectorTrunkSegment(2)=0.000000
      VectorTrunkSegment(3)=0.000000
      VectorTrunkSegment(4)=0.000000
      VectorTrunkSegment(5)=0.000000
      VectorTrunkSegment(6)=0.000000
      VectorTrunkSegment(7)=0.000000
      VectorTrunkSegment(8)=0.000000
      VectorTrunkSegment(9)=0.000000
      VectorTrunkSegment(10)=0.000000
      VectorTrunkSegment(11)=0.000000
      VectorTrunkSegment(12)=0.000000
      VectorTrunkSegment(13)=0.000000
      VectorTrunkSegment(14)=0.000000
      VectorTrunkSegment(15)=0.000000
      VectorLength(0)=0.000000
      VectorLength(1)=0.000000
      VectorLength(2)=0.000000
      VectorLength(3)=0.000000
      VectorLength(4)=0.000000
      VectorLength(5)=0.000000
      VectorLength(6)=0.000000
      VectorLength(7)=0.000000
      VectorLength(8)=0.000000
      VectorLength(9)=0.000000
      VectorLength(10)=0.000000
      VectorLength(11)=0.000000
      VectorLength(12)=0.000000
      VectorLength(13)=0.000000
      VectorLength(14)=0.000000
      VectorLength(15)=0.000000
      VectorAngle(0)=(Pitch=0,Yaw=0,Roll=0)
      VectorAngle(1)=(Pitch=0,Yaw=0,Roll=0)
      VectorAngle(2)=(Pitch=0,Yaw=0,Roll=0)
      VectorAngle(3)=(Pitch=0,Yaw=0,Roll=0)
      VectorAngle(4)=(Pitch=0,Yaw=0,Roll=0)
      VectorAngle(5)=(Pitch=0,Yaw=0,Roll=0)
      VectorAngle(6)=(Pitch=0,Yaw=0,Roll=0)
      VectorAngle(7)=(Pitch=0,Yaw=0,Roll=0)
      VectorAngle(8)=(Pitch=0,Yaw=0,Roll=0)
      VectorAngle(9)=(Pitch=0,Yaw=0,Roll=0)
      VectorAngle(10)=(Pitch=0,Yaw=0,Roll=0)
      VectorAngle(11)=(Pitch=0,Yaw=0,Roll=0)
      VectorAngle(12)=(Pitch=0,Yaw=0,Roll=0)
      VectorAngle(13)=(Pitch=0,Yaw=0,Roll=0)
      VectorAngle(14)=(Pitch=0,Yaw=0,Roll=0)
      VectorAngle(15)=(Pitch=0,Yaw=0,Roll=0)
      Trunk(0)=(X=0.000000,Y=0.000000,Z=0.000000)
      Trunk(1)=(X=0.000000,Y=0.000000,Z=0.000000)
      Trunk(2)=(X=0.000000,Y=0.000000,Z=0.000000)
      Trunk(3)=(X=0.000000,Y=0.000000,Z=0.000000)
      Trunk(4)=(X=0.000000,Y=0.000000,Z=0.000000)
      Trunk(5)=(X=0.000000,Y=0.000000,Z=0.000000)
      Trunk(6)=(X=0.000000,Y=0.000000,Z=0.000000)
      Trunk(7)=(X=0.000000,Y=0.000000,Z=0.000000)
      Trunk(8)=(X=0.000000,Y=0.000000,Z=0.000000)
      Trunk(9)=(X=0.000000,Y=0.000000,Z=0.000000)
      Trunk(10)=(X=0.000000,Y=0.000000,Z=0.000000)
      Trunk(11)=(X=0.000000,Y=0.000000,Z=0.000000)
      Trunk(12)=(X=0.000000,Y=0.000000,Z=0.000000)
      Trunk(13)=(X=0.000000,Y=0.000000,Z=0.000000)
      Trunk(14)=(X=0.000000,Y=0.000000,Z=0.000000)
      Trunk(15)=(X=0.000000,Y=0.000000,Z=0.000000)
      Branch(0)=(X=0.000000,Y=0.000000,Z=0.000000)
      Branch(1)=(X=0.000000,Y=0.000000,Z=0.000000)
      Branch(2)=(X=0.000000,Y=0.000000,Z=0.000000)
      Branch(3)=(X=0.000000,Y=0.000000,Z=0.000000)
      Branch(4)=(X=0.000000,Y=0.000000,Z=0.000000)
      Branch(5)=(X=0.000000,Y=0.000000,Z=0.000000)
      Branch(6)=(X=0.000000,Y=0.000000,Z=0.000000)
      Branch(7)=(X=0.000000,Y=0.000000,Z=0.000000)
      Branch(8)=(X=0.000000,Y=0.000000,Z=0.000000)
      Branch(9)=(X=0.000000,Y=0.000000,Z=0.000000)
      Branch(10)=(X=0.000000,Y=0.000000,Z=0.000000)
      Branch(11)=(X=0.000000,Y=0.000000,Z=0.000000)
      Branch(12)=(X=0.000000,Y=0.000000,Z=0.000000)
      Branch(13)=(X=0.000000,Y=0.000000,Z=0.000000)
      Branch(14)=(X=0.000000,Y=0.000000,Z=0.000000)
      Branch(15)=(X=0.000000,Y=0.000000,Z=0.000000)
      SpawnClass=None
      NullVector=(X=0.000000,Y=0.000000,Z=0.000000)
      VectorIndex=0
      RedBase=None
      Bluebase=None
      GreenBase=None
      YellowBase=None
      Style=STY_Translucent
      Sprite=Texture'Gauntlet-10-BetaV4.RuParticle'
      Texture=Texture'Gauntlet-10-BetaV4.RuParticle'
}
