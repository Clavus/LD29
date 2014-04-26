
require("game/game")
require("game/sprite_layouts")

local toload = {
	
	-- Mixins
	{ TerrainMask = "game/classes/mixins/terrainmask" },
	
	-- Classes
	{ Driller = "game/classes/driller" },
	{ Cloud = "game/classes/cloud" },
	{ Explosion = "game/classes/explosion" },
	
}
package.loadSwappable( toload )