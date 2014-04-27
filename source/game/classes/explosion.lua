
local Explosion = class("Explosion", Entity)
Explosion:include( TerrainMask )

local lg = love.graphics
local scale = 2

function Explosion:initialize( world )

	Entity.initialize( self )
	PhysicsActor.initialize( self, world, "static" )
	
	local img = resource.getImage( FOLDER.ASSETS.."explosion_sheet.png" )
	img:setFilter( "linear", "nearest" )
	
	self._mask = resource.getImage( FOLDER.ASSETS.."explosion_mask.png" )
	img:setFilter( "linear", "nearest" )
	
	self._sprite = Sprite( SpriteData( FOLDER.ASSETS.."explosion_sheet.png", Vector(0,0), Vector(48, 48), Vector(24, 24), 5, 5, 24, false ) )
	
end

function Explosion:update( dt )

	self._sprite:update( dt )
	
	if (self._sprite:hasEnded()) then
		self:remove()
	end
	
end

function Explosion:draw()

	local px, py = self:getPos()
	
	lg.setColor( 255, 255, 255, 180 )
	self._sprite:draw(px, py, 0, scale, scale)
	lg.setColor( 255, 255, 255, 255 )
	
end

function Explosion:drawMask()

	lg.setShader(self:getMaskShader())
		
	local px, py = self:getPos()
	lg.draw( self._mask, px-self._mask:getWidth()/2*scale, py-self._mask:getHeight()/2*scale, 0, scale, scale )
	
	lg.setShader()
	
end

return Explosion