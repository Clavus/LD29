
local Driller = class("Driller", Entity)
Driller:include( PhysicsActor )
Driller:include( CollisionResolver )
Driller:include( TerrainMask )

local lg = love.graphics
local scale = 2

local turn_speed = math.pi / 3
local max_drillrate= 3
local max_powered_drillrate = 5

function Driller:initialize( world )
	
	Entity.initialize( self )
	PhysicsActor.initialize( self, world )
	self._startsound = resource.getSound( FOLDER.ASSETS.."game_start.wav", "static" )
	
	self._sound = resource.getSound( FOLDER.ASSETS.."digging_loop.wav", "static" )
	self._sound:setLooping( true )
	self._sound:setVolume( 0 )
	
	self._sprite = StateAnimatedSprite( SPRITELAYOUT["driller"], FOLDER.ASSETS.."driller_sheet.png", Vector(0,0), Vector(60, 31), Vector(20, 15) )
	self._sprite:setState("default")
	
	self._psystem = util.readParticleSystem( FOLDER.PARTICLESYSTEMS.."drilling_dirt" )
	self._psystem:start()
	
	self._pemisionrate = self._psystem:getEmissionRate()
	self._speedmin,  self._speedmax = self._psystem:getSpeed()
	
	self._drillpoint = Vector( 38, 0 )
	self._drillrate = 0
	self._topspeed = 100
	
	self._health = 10
	
	self._started = false
	self._incontrol = false
	self._inrecovery = false
	
	local vertices = { -17, 12, -17, -11, 10, -11, 38, 0, 10, 12 }
	for i, v in ipairs( vertices ) do
		vertices[i] = v * scale
	end
	
	local shape = love.physics.newPolygonShape( unpack(vertices) )
	self._fixture = love.physics.newFixture( self:getBody(), shape )
	
end

function Driller:start()
	
	self._drillrate = 5
	self._started = true
	
	self._startsound:play()
	self._sound:play()
	
	timer.add( 0.5, function() self._incontrol = true end)
	
end

function Driller:update( dt )
	
	if not (self._started) then return end
	
	local ang = self:getAngle()
	
	if (self._incontrol) then
		
		if (input:keyIsDown( "down" )) then
			self._drillrate = math.approach( self._drillrate, max_drillrate, dt * 2 )
		else
			self._drillrate = math.approach( self._drillrate, 1, dt * 2 )
		end
		
		if ((input:keyIsDown( "right" ) and ang > math.pi * 0.1) or ang > math.pi * 0.9) then
			self:rotate( -turn_speed * self._drillrate * dt )
		elseif ((input:keyIsDown( "left" ) and ang < math.pi * 0.9) or ang < math.pi * 0.1) then
			self:rotate( turn_speed * self._drillrate * dt )
		end
		
	elseif (self._health <= 0) then
		
		self._drillrate = math.approach( self._drillrate, 0, dt*3 )
		
	end
	
	self._sound:setVolume( math.min( 0.3, self._drillrate * 0.1 ) )
	
	if (self._drillrate > 0) then
		self:moveForward( self._drillrate * self._topspeed * dt )
	end
	
	self._psystem:setDirection( ang + math.pi )
	self._psystem:setEmissionRate( self._drillrate * self._pemisionrate )
	self._psystem:setSpeed( math.min(1, self._drillrate) * self._speedmin,  math.min(1, self._drillrate) * self._speedmax )
	
	self._sprite:setSpeed( self._drillrate )
	
	local x, y = self:getPos()
	local drillpoint = self._drillpoint:getRotated( ang ) * scale
	self._psystem:setPosition( x + drillpoint.x, y + drillpoint.y ) 
	
	self._psystem:update( dt )
	self._sprite:update( dt )

end

function Driller:damage( amount )
	
	self._health = math.max(0, self._health - amount)
	if (self._health <= 0) then
		
		self:explode()
		
	end
	
end

function Driller:getHealth()
	
	return self._health
	
end

function Driller:explode()

	self._incontrol = false
	
	local i = 6
	
	timer.addPeriodic( 0.5, function()
		local pos = Vector( self:getPos() ) + angle.forward( i / 3 * math.pi ) * math.randomRange( 10, 30 )
		signal.emit("explosion", self, pos.x, pos.y)
		
		i = i - 1
		if (i == 0) then
			signal.emit("player_death")
			self:remove()
		end
		
	end, i)

end

function Driller:draw()
	
	local x, y = self:getPos()
	local ang = self:getAngle()
	
	--self:drawMask()
	if ((self._inrecovery or self._health <= 0) and (currentTime() * 10) % 2 > 1) then
		lg.setColor( Color.Red:unpack() )
	end
	
	self._sprite:draw(x, y, ang, scale, scale)
	
	lg.setColor( Color.White:unpack() )
	
	--lg.setBlendMode("additive")
	lg.draw( self._psystem )
	--lg.setBlendMode("alpha")
	
end

function Driller:drawMask()

	lg.setShader(self:getMaskShader())
	
	local x, y = self:getPos()
	local ang = self:getAngle()
	
	self._sprite:draw(x, y, ang, scale, scale)
	
	lg.setShader()
	
end

function Driller:beginContactWith( other, contact, myFixture, otherFixture, selfIsFirst )
	
	--contact:setEnabled( false )
	
	if (other.class:includes( Damager )) then
		
		if (other:getDamage() > 0) then
		
			if (self._inrecovery or self._health <= 0) then return end
			self._inrecovery = true
			
			timer.add( 0.5, function() self._inrecovery = false end)
			
			self:damage( other:getDamage() )
			
		end
		
		self._drillrate = self._drillrate * other:getSlowdownFactor()
		
	end	
	
end

return Driller