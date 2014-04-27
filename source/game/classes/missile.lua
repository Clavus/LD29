
local Missile = class("Missile", Entity)
Missile:include( PhysicsActor )
Missile:include( CollisionResolver )
Missile:include( TerrainMask )
Missile:include( Damager )

local lg = love.graphics
local scale = 2

function Missile:initialize( world )

	Entity.initialize( self )
	Damager.initialize( self, 2 )
	PhysicsActor.initialize( self, world, "dynamic" )
	
	self._sprite = Sprite( SpriteData( FOLDER.ASSETS.."missile_sheet.png", Vector(0,0), Vector(40, 7), Vector(20, 4), 1, 3, 30, true ) )
	
	self._speed = 100
	
	local shape = love.physics.newRectangleShape( self._sprite:getWidth() * scale, self._sprite:getHeight() * scale )
	self._fixture = love.physics.newFixture( self:getBody(), shape )
	
	-- likely that we missed after 10 seconds
	self._removaltimer = timer.add( 10, function()
		print("missile removal service")
		self:remove()
	end)
	
end

function Missile:update( dt )

	self._sprite:update( dt )
	
	self:moveForward( dt * self._speed )

end

function Missile:draw()
	
	local px, py = self:getPos()
	local ang = self:getAngle()
	
	self._sprite:draw(px, py, ang, scale, scale)
	
end

function Missile:drawMask()
	
	lg.setShader(self:getMaskShader())
	
	local px, py = self:getPos()
	local ang = self:getAngle()
	
	self._sprite:draw(px, py, ang, scale, scale)
	
	lg.setShader()
	
end

function Missile:setSpeed( s )

	self._speed = s

end

function Missile:getSpeed()

	return self._speed

end

function Missile:beginContactWith( other, contact, myFixture, otherFixture, selfIsFirst )
	
	contact:setEnabled( false )
	
	if (self._exploded) then return end
	self._exploded = true
	
	timer.cancel( self._removaltimer )
	
	-- emit next frame, because we can't create bodies in collision callbacks
	timer.add(0, function()
		signal.emit("explosion", self, self:getPos())
		self:remove()
	end)
	
end

return Missile