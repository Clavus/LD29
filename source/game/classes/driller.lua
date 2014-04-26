
local Driller = class("Driller", Entity)
Driller:include(Rotatable)
Driller:include(TerrainMask)

local lg = love.graphics
local scale = 2

local turn_speed = math.pi / 3
local max_drillrate= 3
local max_powered_drillrate = 5

function Driller:initialize()
	
	Entity.initialize( self )
	Rotatable.initialize( self )
	
	local img = resource.getImage( FOLDER.ASSETS.."driller_sheet.png" )
	img:setFilter( "linear", "nearest" )
	
	self._sprite = StateAnimatedSprite( SPRITELAYOUT["driller"], FOLDER.ASSETS.."driller_sheet.png", Vector(0,0), Vector(31, 60), Vector(15, 20) )
	self._sprite:setState("default")
	
	self._psystem = util.readParticleSystem( FOLDER.PARTICLESYSTEMS.."drilling" )
	self._psystem:start()
	
	self._pemisionrate = self._psystem:getEmissionRate()
	self._speedmin,  self._speedmax = self._psystem:getSpeed()
	
	self._drillpoint = Vector( 38, 0 )
	self._drillrate = 0
	self._topspeed = 100
	
	self._started = false
	self._incontrol = false
	
	input:addKeyPressCallback("start_driller", "down", function() self:start() end)
	
end

function Driller:start()
	
	input:removeKeyPressCallback("start_driller")
	
	self._drillrate = 5
	self._started = true
	
	timer.add( 0.5, function() self._incontrol = true end)
	
end

function Driller:update( dt )
	
	if not (self._started) then return end
	
	local ang = self:getAngle()
	
	if (self._incontrol) then
		
		if (input:keyIsDown( "down" )) then
			self._drillrate = math.approach( self._drillrate, max_drillrate, dt )
		else
			self._drillrate = math.approach( self._drillrate, 0, dt )
		end
		
		if (input:keyIsDown( "right" ) and ang > math.pi * 0.1) then
			self:rotate( -turn_speed * self._drillrate * dt )
		elseif (input:keyIsDown( "left" ) and ang < math.pi * 0.9) then
			self:rotate( turn_speed * self._drillrate * dt )
		end
		
	end
	
	if (self._drillrate > 0) then
		self:moveForward( self._drillrate * self._topspeed * dt )
	end
	
	self._psystem:setDirection( ang + math.pi )
	self._psystem:setEmissionRate( self._drillrate * self._pemisionrate )
	self._psystem:setSpeed(  self._drillrate * self._speedmin,  self._drillrate * self._speedmax )
	
	self._sprite:setSpeed( self._drillrate )
	
	local x, y = self:getPos()
	local drillpoint = self._drillpoint:getRotated( ang ) * scale
	self._psystem:setPosition( x + drillpoint.x, y + drillpoint.y ) 
	
	self._psystem:update( dt )
	self._sprite:update( dt )

end

function Driller:draw()
	
	local x, y = self:getPos()
	local ang = self:getAngle() - math.deg2rad( 90 )
	
	--self:drawMask()
	self._sprite:draw(x, y, ang, scale, scale)
	
	love.graphics.setBlendMode("premultiplied")
	lg.draw( self._psystem )
	love.graphics.setBlendMode("alpha")
	
end

local mask_effect = lg.newShader( [[
   vec4 effect ( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ) {
      // a discarded fragment will fail the stencil test.
      if (Texel(texture, texture_coords).a == 0.0)
         discard;
      return vec4(1.0);
   }
]] )

function Driller:drawMask()

	lg.setShader(mask_effect)
	
	local x, y = self:getPos()
	local ang = self:getAngle() - math.deg2rad( 90 )
	
	self._sprite:draw(x, y, ang, scale, scale)
	
	lg.setShader()
	
end

return Driller