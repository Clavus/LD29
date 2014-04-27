
local Cloud = class("Cloud", Entity)

local lg = love.graphics
local scale = 2

function Cloud:initialize()

	Entity.initialize( self )
	
	self._sprite = Sprite( SpriteData( FOLDER.ASSETS.."cloud_sheet.png", Vector(0,0), Vector(64, 32), Vector(32, 16), 4, 8, 0, false ) )
	self._sprite:setFrame( math.random(1, self._sprite:getFrameCount()) )
	
	self._speed = 0
	
end

function Cloud:update( dt )
	
	self:move( -self._speed * dt, 0 )
	
end

function Cloud:draw()

	local px, py = self:getPos()
	
	lg.setColor( 255, 255, 255, 180 )
	self._sprite:draw(px, py, 0, scale, scale)
	lg.setColor( 255, 255, 255, 255 )
	
end

function Cloud:setScrollSpeed( x )
	
	self._speed = x
	
end

return Cloud