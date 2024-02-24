class smallgate expands gateways;

function spawncritter()
{
        local actor c;
        local int bob;
        local scriptedpawn sp;
        foreach radiusactors(critter[critnum],c,1000)
        {
                bob++;
                if (bob>MaxMonsters)
                        return;
        }
        sp=spawn(critter[critnum],,,location,rotation);
        if (sp==none)
                return;
        sp.teamleader=sp;
        sp.team=0;
        sp.lifespan=400;
        sp.setphysics(phys_falling);
}

defaultproperties
{
      timetillnext=1
      pointworth=0
      Health=1000.000000
      maxhealth=1000.000000
      allowedmonster(0)=1
      allowedmonster(1)=1
      allowedmonster(2)=1
      allowedmonster(3)=1
      allowedmonster(4)=1
      Reward=20
      critter(0)=Class'Gauntlet-10-BetaV4.gategasbag'
      critter(1)=Class'Gauntlet-10-BetaV4.gateFly'
      critter(2)=Class'Gauntlet-10-BetaV4.gatePupae'
      critter(3)=Class'Gauntlet-10-BetaV4.GateMullog'
      critter(4)=Class'Gauntlet-10-BetaV4.gatemerc'
      critterNickName(0)="Gasbag"
      critterNickName(1)="Fly"
      critterNickName(2)="Pupae"
      critterNickName(3)="Mullog"
      critterNickName(4)="Mercenary"
      damagedmesh=LodMesh'Gauntlet-10-BetaV4.U.gate2dama'
      damagedmesh2=LodMesh'Gauntlet-10-BetaV4.U.gateway02c'
      GateName="Small"
      Texture=FireTexture'UnrealShare.CFLAM.cflame'
      Mesh=LodMesh'Gauntlet-10-BetaV4.U.gate2'
      DrawScale=1.800000
      CollisionRadius=25.000000
      CollisionHeight=60.000000
      LightEffect=LE_Shock
      LightBrightness=255
      LightHue=255
      LightSaturation=127
      LightRadius=50
}
