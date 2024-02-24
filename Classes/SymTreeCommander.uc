//=============================================================================
// SymTreeCommander.
// Written By nOs*Wildcard
//=============================================================================
class SymTreeCommander expands Inventory;

exec simulated function Randomize()
{
	local SymTree ST;

	RemoveStuff();

	ForEach AllActors(class'SymTree', ST)
		ST.Randomize();
}

exec simulated function Rotate( int IntAngle )
{
	local SymTree ST;

	RemoveStuff();

	ForEach AllActors(class'SymTree', ST)
		ST.Rotate(IntAngle);
}

exec simulated function PathNodeMethod()
{
	local SymSeed ST;

	RemoveStuff();

	foreach AllActors(class'SymSeed',ST)
		{
			ST.PathNodeMethod();
		}
}

function RemoveStuff()
{
	local TarydiumBarrel TB;

	foreach AllActors(class'TarydiumBarrel',TB)
		TB.Destroy();
}

simulated function PostRender( canvas Canvas )
{
	local float Dist;
	local PlayerStart PST;
	local int XPos, YPos;
	local Vector X,Y,Z, Dir;

	GetAxes(Rotation, X,Y,Z);
	Canvas.Font = Font'TinyRedFont';
	if ( Level.bHighDetailMode )
		Canvas.Style = ERenderStyle.STY_Translucent;
	else
		Canvas.Style = ERenderStyle.STY_Normal;
	foreach RadiusActors(class'PlayerStart', PST, 2000)
	{
		Dir = PST.Location - Location;
		Dist = VSize(Dir);
		Dir = Dir/Dist;
		if ( (Dir Dot X) > 0.7 )
		{
			XPos = 0.5 * Canvas.ClipX * (1 + 1.4 * (Dir Dot Y));
			YPos = 0.5 * Canvas.ClipY * (1 - 1.4 * (Dir Dot Z));
			Canvas.SetPos(XPos - 8, YPos - 8);
			Canvas.DrawIcon(texture'CrossHair6', 1.0);
			Canvas.SetPos(Xpos - 12, YPos + 8);
			Canvas.DrawText(Dist, true);
		}
	}	
}	

defaultproperties
{
}
