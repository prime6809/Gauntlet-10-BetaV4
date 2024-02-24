class biggate expands gateways;

function timer()
{
	if ( bFirstSet == true )
		{
			// Choose A Monster From This Gateway
			critnum = Rand(5);

			GateName = critterNickName[critnum];
			log("PURPLE: Spawned A"@GateName@"gateway");
			log("critnum:"@critnum);

			if ( allowedmonster[critnum] == 0 )
				log("The "@GateName@" gateway had been DISABLED!");

			if ( emergencykill() == true )
				{
					takedamage(health,none,location,location,'');
					return;
				}

 /* OK THIS HAS GOT TO GO :@
			do
				{
					if ( allowedmonster[critnum] != 1 )
						{
							if ( critnum == 4 )
								critnum = 0;
							else
								critnum++;
						}
				}
			until ( allowedmonster[critnum] == 1 );
*/
                
			spawncritter();
			spiffer = spawn(class'spiffyhole',,,location,(rotation+rot(0,0,6400)));
			spiffer.howbig = HoleSize;
			spiffer.setbase(self);
			setphysics(phys_falling);
			bFirstSet = false;
		}

	spawncritter();
	settimer(timetillnext,true);
}

defaultproperties
{
      timetillnext=5
      maxmonsters=10
      pointworth=60
      Health=3000.000000
      maxhealth=3000.000000
      allowedmonster(0)=1
      allowedmonster(1)=1
      allowedmonster(2)=1
      allowedmonster(3)=1
      allowedmonster(4)=1
      Reward=60
      critter(0)=Class'Gauntlet-10-BetaV4.gateNormalMercenary'
      critter(1)=Class'Gauntlet-10-BetaV4.gatehank'
      critter(2)=Class'Gauntlet-10-BetaV4.gateKrallElite'
      critter(3)=Class'Gauntlet-10-BetaV4.GateGasbagGiant'
      critter(4)=Class'Gauntlet-10-BetaV4.gatebruteyeti'
      critterNickName(0)="Mercenary"
      critterNickName(1)="Hank"
      critterNickName(2)="Krall Elite"
      critterNickName(3)="Giant Gasbag"
      critterNickName(4)="Yeti"
      damagedmesh=LodMesh'Gauntlet-10-BetaV4.U.gate3dama'
      damagedmesh2=LodMesh'Gauntlet-10-BetaV4.U.gateway03c'
      GateName="Big"
      Texture=Texture'Gauntlet-10-BetaV4.Skins.JG4ePurple'
      Mesh=LodMesh'Gauntlet-10-BetaV4.U.gate3'
      DrawScale=2.200000
      CollisionRadius=40.000000
}
