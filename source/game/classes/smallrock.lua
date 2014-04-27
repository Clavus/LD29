
local SmallRock = class("SmallRock", Entity)
SmallRock:include( PhysicsActor )
SmallRock:include( CollisionResolver )
SmallRock:include( Damager )
SmallRock:include( TerrainMask )

local lg = love.graphics
local scale = 2
local rocks = {
	{ path = FOLDER.ASSETS.."smallrock1.png", rect = { x = 3, y = 3, w = 20, h = 11 } },
	{ path = FOLDER.ASSETS.."smallrock2.png", rect = { x = 3, y = 3, w = 19, h = 11 } },
	{ path = FOLDER.ASSETS.."smallrock3.png", rect = { x = 3, y = 3, w = 23, h = 13 } },
}

function SmallRock:initialize( world )
	
	Entity.initialize( self )
	PhysicsActor.initialize( self, world, "static" )
	Damager.initialize( self, 0, 0.8 )
	
	self:build()
	
	self:setAngle( -math.pi / 2 + math.random() * math.pi )
	
	self._center = Vector( self._sprite:getWidth() / 2, self._sprite:getHeight() / 2 ):rotate( self:getAngle() )
	
end

function SmallRock:build( rock )
	
	local rock = table.random( rocks ) 
	
	self._sound = resource.getSound( FOLDER.ASSETS.."hit_rock_small.wav", "static" )
	self._sprite = Sprite( SpriteData( rock.path ) )
	
	local w = rock.rect.w * scale
	local h = rock.rect.h * scale
	local x = rock.rect.x * scale + w / 2
	local y = rock.rect.y * scale + h / 2
	
	local shape = love.physics.newRectangleShape( x, y, w, h )
	self._fixture = love.physics.newFixture( self:getBody(), shape )
	
end

function SmallRock:draw()

	local px, py = self:getPos()
	local ang = self:getAngle()
	self._sprite:draw(px, py, ang, scale, scale)

end

function SmallRock:drawMask()
	
	lg.setShader( self:getMaskShader() )
	self:draw()
	lg.setShader()
	
	self.drawMask = function() end
	
end

function SmallRock:getDestroySound()
	
	return self._sound
	
end

function SmallRock:beginContactWith( other, contact, myFixture, otherFixture, selfIsFirst )
	
	contact:setEnabled( false )
	
	local px, py = self:getPos()
	
	signal.emit("rock_destroy", self, px + self._center.x, py + self._center.y, self._sprite:getWidth() / 3 * scale)
	
	timer.add(0, function()
		self:remove()
	end)
	
end

return SmallRock