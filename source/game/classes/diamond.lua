
local Diamond = class("Diamond", Entity)
Diamond:include( Rotatable )

local scale = 2

function Diamond:initialize( world )

	Entity.initialize( self )
	Rotatable.initialize( self )
	
	self._sprite = Sprite( SpriteData( FOLDER.ASSETS.."diamond.png" ) )
	
	self:setAngle( -math.pi / 4 + math.random() * math.pi / 2 )
	
end

function Diamond:update( dt )
	
end

function Diamond:draw()
	
	local px, py = self:getPos()
	local ang = self:getAngle()
	self._sprite:draw(px, py, ang, scale, scale)
	
end

return Diamond