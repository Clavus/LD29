
local TerrainMask = {}

local mask_effect = love.graphics.newShader( [[
   vec4 effect ( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ) {
      // a discarded fragment will fail the stencil test.
      if (Texel(texture, texture_coords).a < 1.0)
         discard;
      return vec4(1.0);
   }
]] )

function TerrainMask:drawMask()

end

function TerrainMask:getMaskShader()
	
	return mask_effect
	
end

return TerrainMask
