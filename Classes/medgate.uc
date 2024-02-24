class medgate expands gateways;

function tick(float deltatime)
{
	local int chance;

	Super.tick(deltatime);

	if ( default.critter[2] == Class'GateBoogerIce' )
		{
			chance = Rand(100);
			
			if ( chance <= 20 )
				critter[2] = Class'GateBooger';
			if ( chance >= 30 )
				critter[2] = Class'GateBoogerSlime';
			if ( chance >= 50 )
				critter[2] = Class'GateBoogerIce';
			if ( chance >= 95 )
				critter[2] = Class'GateBoogerFire';
		}
}

function timer()
{
	if ( bFirstSet == true )
		{
			// Choose A Monster From This Gateway
			critnum = Rand(5);

			GateName = critterNickName[critnum];
			log("GOLD: Spawned A"@GateName@"gateway");
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
      timetillnext=4
      maxmonsters=15
      pointworth=0
      Health=2000.000000
      maxhealth=2000.000000
      allowedmonster(0)=1
      allowedmonster(1)=1
      allowedmonster(2)=1
      allowedmonster(3)=1
      allowedmonster(4)=1
      Reward=40
      critter(0)=Class'Gauntlet-10-BetaV4.gateskaarjscout'
      critter(1)=Class'Gauntlet-10-BetaV4.gateCaveManta'
      critter(2)=Class'Gauntlet-10-BetaV4.GateBoogerIce'
      critter(3)=Class'Gauntlet-10-BetaV4.gateKrall'
      critter(4)=Class'Gauntlet-10-BetaV4.gateBrute'
      critterNickName(0)="Skaarj"
      critterNickName(1)="Manta"
      critterNickName(2)="Booger"
      critterNickName(3)="Krail"
      critterNickName(4)="Brute"
      damagedmesh=LodMesh'Gauntlet-10-BetaV4.U.gateway06b'
      damagedmesh2=LodMesh'Gauntlet-10-BetaV4.U.gateway06c'
      Mesh=LodMesh'Gauntlet-10-BetaV4.U.gateway06a'
}
