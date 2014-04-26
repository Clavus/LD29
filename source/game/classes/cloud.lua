
local Cloud = class("Cloud", Entity)

function Cloud:initialize()

	Entity.initialize( self )
	
	self._sprite = StateAnimatedSprite( SPRITELAYOUT["cloud"], FOLDER.ASSETS.."cloud_sheet.png", Vector(0,0), Vector(64, 32), Vector(32, 16) )
	self._sprite:setState("default")

	self._speed = -1 + math.random() * -5
	
end

function Cloud:update( dt )
	
	self:move( -self._speed * dt, 0 )
	
end

function Cloud:draw()

	self._sprite:draw(self:getPos())

end

return Cloud