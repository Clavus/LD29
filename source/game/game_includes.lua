
require("game/game")
require("game/sprite_layouts")

local toload = {
	
	-- Mixins
	{ TerrainMask 	= "game/classes/mixins/terrainmask" },
	{ Damager 		= "game/classes/mixins/damager" },
	
	-- Classes
	{ Driller 			= "game/classes/driller" },
	{ Cloud 			= "game/classes/cloud" },
	{ Explosion 		= "game/classes/explosion" },
	{ TntBarrel 		= "game/classes/tntbarrel" },
	{ Missile 			= "game/classes/missile" },
	{ SmallRock 		= "game/classes/smallrock" },
	{ Rock 				= "game/classes/rock" },
	{ BurstParticleSystem = "game/classes/burstparticlesystem" },
	
}
package.loadSwappable( toload )