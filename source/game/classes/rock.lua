
local Rock = class("Rock", SmallRock)

local scale = 2
local rocks = {
	{ path = FOLDER.ASSETS.."rock1.png", rect = { x = 6, y = 3, w = 26, h = 46 } },
	{ path = FOLDER.ASSETS.."rock2.png", rect = { x = 6, y = 3, w = 46, h = 21 } },
	{ path = FOLDER.ASSETS.."rock3.png", rect = { x = 3, y = 4, w = 46, h = 19 } },
}

function Rock:initialize( world )

	SmallRock.initialize( self, world )
	
	self:setDamageOnImpact( 2 )
	self:setSlowdownFactor( 0.5 )

end

function Rock:build()

	local rock = table.random( rocks ) 
	
	self._sound = resource.getSound( FOLDER.ASSETS.."hit_rock.wav", "static" )
	self._sprite = Sprite( SpriteData( rock.path ) )
	
	local w = rock.rect.w * scale
	local h = rock.rect.h * scale
	local x = rock.rect.x * scale + w / 2
	local y = rock.rect.y * scale + h / 2
	
	local shape = love.physics.newRectangleShape( x, y, w, h )
	self._fixture = love.physics.newFixture( self:getBody(), shape )
	
end

return Rock