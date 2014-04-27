
local BurstParticleSystem = class("BurstParticleSystem", Entity)

local lg = love.graphics

function BurstParticleSystem:initialize( name )
	
	Entity.initialize( self )
	
	self._system = util.readParticleSystem( FOLDER.PARTICLESYSTEMS..name )
	
	--self._system:pause()
	
end

function BurstParticleSystem:burst( amount )
	
	self._system:setBufferSize( amount )
	self._system:setEmissionRate( 100000 )
	
	timer.add(0.1, function()
		self._system:pause()
	end)
	--self._system:start()
	--self._system:emit( amount )
	
end

function BurstParticleSystem:getSystem()
	
	return self._system
	
end

function BurstParticleSystem:update( dt )
	
	local px, py = self:getPos()
	self._system:setPosition( px, py )
	self._system:update( dt )
	
end

function BurstParticleSystem:draw()
	
	local px, py = self:getPos()
	lg.draw( self._system )
	
end

return BurstParticleSystem