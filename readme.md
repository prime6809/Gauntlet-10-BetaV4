This is a repack and bugfix of Wildcard's Gauntlet for Unreal Tournament (UT99).

Original is available from : 

https://gauntletwarriors.com/Forums/viewtopic.php?f=25&t=56

To install this update, please download the above file and install as per the 
included instructions. Once this is done, simply copy the Gauntlet-10-BetaV4.u
from the bin directory of this release into your Unreal Tournament's System 
directory (or System64 on Linux x64).

Things fixed in this release :
 
1) Broke out all resources to make easily re-buildable without depending on
   previous versions.
	
2) Fixed some levels (specifically DM-SnowingAngels) not spawning gateways in
   one part of the map. This was caused by u4egauntlet.uc only having 256 level
   nodes, when the level had more. Increased default to 512 and defined as a 
   constant (NoLevelNodes) to allow easy change in future.
	
3) Fixed minor bug introduced in 1) that lead to Mullog being rotated 180deg.

4) Commented out all unused variables to stop compiler bugging about them.

5) Fixed the long standing bug where a round would end prematurely after 
   killing just the gateways. This was happening when a boss monster was 
   killed before all the bosses had been spawned.	
   This was due to the total number of boss monsters not being set until they 
   where all spawned, and so defaulting to 0. But the total was decremented 
   and then checked for being less than zero in the boss' death handler, 
   if <0 then the level ended.
	
6) Hunted down and included code to mitigate as many of the "Access None" 
   occurrences in the code.

7) Mostly stopped crashes on levels with less pathnodes than total gateways.
   The server now tries to adjust the number of gateways down until the total 
   is less than the pathnode count. This will mean that there are less than the
   requested gateway counts but this is better IMHO than a server crash.
	
8) Changed the way that gates are spawned so that we should now never get 
   infinite recursion crashes, these where due to a situation arising where
   all the spawn points where used up, but the code kept trying to spawn gates.
   The code now spawns gates in batches of each type up until it runs out of
   spawn points. 
   This way we will hopefully still get the same ratio of gates even if there 
   are not enough spawn points for all the specified gates.

9) If a level is entered with no botpath points (that are used as gate / boss
   spawn points), then the level is ended as soon as it is started.	This is
   better behavior than entering a level that has no gates and no bosses, 
   especially if the server doesn't have map vote.

If you wish to re-build the release, clone this repository into your Unreal 
Tournament root directory, then from a command or terminal window change to 
the System (or System64) directory and run 

For windows :

..\Gauntlet-10-BetaV4\m.bat
 
 
For Linux :

../Gauntlet-10-BetaV4/m.sh


Note that (currently as of 2024-02) building under Linux will fail, as there is
a bug in the Linux ucc-bin, that causes it to crash, it has been reported to
the OldUnreal team, and will hopefully be being fixed at some point in the 
future.



