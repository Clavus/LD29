
local Driller = class("Driller", Entity)
Driller:include(Rotatable)

function Driller:initialize()
	
	Entity.initialize( self )
	
	local img = resource.getImage( FOLDER.ASSETS.."driller_sheet.png" )
	img:setFilter( "linear", "nearest" )
	
	self._sprite = StateAnimatedSprite( SPRITELAYOUT["driller"], FOLDER.ASSETS.."driller_sheet.png", Vector(0,0), Vector(31, 60), Vector(15, 20) )
	self._sprite:setState("default")
	
end

function Driller:update( dt )

	self._sprite:update( dt )

end

function Driller:draw()
	
	local x, y = self:getPos()
	local ang = self:getAngle()
	
	self._sprite:draw(x, y, ang, 2, 2)
	
end

return Driller