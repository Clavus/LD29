
require("game/game")
require("game/sprite_layouts")

local toload = {
	{ Driller = "game/classes/driller" },
	{ Cloud = "game/classes/cloud" },
	
	{ TerrainMask = "game/classes/mixins/terrainmask" },
}
package.loadSwappable( toload )