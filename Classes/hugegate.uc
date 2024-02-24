class hugegate expands gateways;

function tick(float deltatime)
{
	Super.tick(deltatime);

	if ( default.critter[0] == Class'GateAngelGod' )
		{
			switch( Rand(6) )
				{
					case 0:
						critter[0] = Class'GateAngelLesser';
						break;
					case 1:
						critter[0] = Class'GateAngel';
						break;
					case 2:
						critter[0] = Class'GateAngelBattle';
						break;
					case 3:
						critter[0] = Class'GateAngelWar';
						break;
					case 4:
						critter[0] = Class'GateAngelArch';
						break;
					case 5:
						critter[0] = Class'GateAngelGod';
						break;
				}
		}
}

function timer()
{
	if ( bFirstSet == true )
		{
			// Choose A Monster From This Gateway
			critnum = Rand(5);

			GateName = critterNickName[critnum];
			log("WHITE: Spawned A"@GateName@"gateway");
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
      maxmonsters=5
      pointworth=60
      Health=4000.000000
      maxhealth=4000.000000
      Reward=120
      critter(0)=Class'Gauntlet-10-BetaV4.gateangelgod'
      critter(1)=Class'Gauntlet-10-BetaV4.gateMaiden'
      critter(2)=Class'Gauntlet-10-BetaV4.GateSpiritMAX'
      critter(3)=Class'Gauntlet-10-BetaV4.gateWarLord'
      critter(4)=Class'Gauntlet-10-BetaV4.GateTorchurer'
      critterNickName(0)="Angel"
      critterNickName(1)="Maiden"
      critterNickName(2)="MAX"
      critterNickName(3)="WarLord"
      critterNickName(4)="Torchurer"
      damagedmesh=LodMesh'Gauntlet-10-BetaV4.U.gate5dama'
      damagedmesh2=LodMesh'Gauntlet-10-BetaV4.U.gateway05c'
      GateName="Huge"
      Texture=FireTexture'Gauntlet-10-BetaV4.U.GatewaySkins.hugegatessource'
      Mesh=LodMesh'Gauntlet-10-BetaV4.U.gate4'
      DrawScale=2.200000
      CollisionRadius=40.000000
}
