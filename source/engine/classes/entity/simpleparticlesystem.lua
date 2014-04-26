
local SimpleParticleSystem = class("SimpleParticleSystem", Entity)

local loadPS

function SimpleParticleSystem:initialize( system )
	
	Entity.initialize( self )
	
	self.system = util.readParticleSystem( FOLDER.PARTICLESYSTEMS..system )
	self.system:start()
	
end

function SimpleParticleSystem:update( dt )
	
	self.system:setPosition( self:getPos() )
	self.system:update( dt )
	
end

function SimpleParticleSystem:draw()

	love.graphics.draw(self.system)

end

return SimpleParticleSystem