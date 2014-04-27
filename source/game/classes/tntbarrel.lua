
local TntBarrel = class("TntBarrel", Entity)
TntBarrel:include( PhysicsActor )
TntBarrel:include( CollisionResolver )
TntBarrel:include( Damager )

local scale = 2

function TntBarrel:initialize( world )

	Entity.initialize( self )
	Damager.initialize( self, 2 )
	PhysicsActor.initialize( self, world, "static" )
	
	self._sprite = Sprite( SpriteData( FOLDER.ASSETS.."tnt.png", Vector(0,0), Vector(33, 37), Vector(16, 18), 1, 1, 0, false ) )
	
	local circle = love.physics.newCircleShape( self._sprite:getWidth() / 2 * scale )
	self._fixture = love.physics.newFixture( self:getBody(), circle )

end

function TntBarrel:update( dt )
	
end

function TntBarrel:draw()
	
	local px, py = self:getPos()
	
	self._sprite:draw(px, py, 0, scale, scale)
	
end

function TntBarrel:beginContactWith( other, contact, myFixture, otherFixture, selfIsFirst )
	
	contact:setEnabled( false )

	if (self._exploded) then return end
	self._exploded = true
	
	-- emit next frame, because we can't create bodies in collision callbacks
	timer.add(0, function()
		signal.emit("explosion", self, self:getPos())
		self:remove()
	end)
	
end


return TntBarrel