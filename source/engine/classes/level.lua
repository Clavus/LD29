
local Level = class('Level')

function Level:initialize( leveldata, use_physics )

	self._leveldata = leveldata
	self._camera = Camera()
	
	self._physics_enabled = use_physics
	if (use_physics) then
		love.physics.setMeter(leveldata.physics.pixels_per_meter)
		self._physworld = love.physics.newWorld(0, 0, true)
		
		self:initDefaultCollisionCallbacks()
	end
	
	local objects = nil
	if (leveldata) then
		objects = leveldata.objects
	end
	
	self._entManager = EntityManager()
	self._entManager:loadLevelObjects(self, objects)
	
end

function Level:update( dt )

	self._camera:update(dt)
	
	if (self._physics_enabled) then
		self._physworld:update(dt)
	end
	
	self._entManager:update(dt)
	
end

function Level:draw()

	self._camera:attach()
	self._entManager:preDraw()

	local cx, cy = self._camera:getPos()
	local cw, ch = self._camera:getWidth(), self._camera:getHeight()
	local ca = self._camera:getAngle()
	local csx, csy = self._camera:getScale()
	local cbw, cbh = self._camera:getBackgroundQuadWidth(), self._camera:getBackgroundQuadHeight()
	
	for k, layer in ipairs( self._leveldata:getLayers() ) do
		
		love.graphics.setColor(255,255,255,255*layer.opacity)
		
		if (layer.type == LAYER_TYPE.IMAGES) then -- draw image layer (usually background objects)
			
			for i, img in pairs(layer.images) do
				if (img.quad) then
					love.graphics.drawq(img.image, img.quad, img.x, img.y, img.angle, img.scale.x, img.scale.y, img.origin.x, img.origin.y )
				else
					love.graphics.draw(img.image, img.x, img.y, img.angle, img.scale.x, img.scale.y, img.origin.x, img.origin.y )
				end
				
			end
			self._entManager:draw(layer.name) -- draw entities that are to be drawn on this layer
			
		elseif (layer.type == LAYER_TYPE.BATCH) then -- draw spritebatch layer (usually for tiles)
			
			for i, batch in pairs(layer.batches) do
				love.graphics.draw(batch)
			end
			self._entManager:draw(layer.name) -- draw entities that are to be drawn on this layer
			
		elseif (layer.type == LAYER_TYPE.BACKGROUND) then -- draw repeating background layer
			
			-- disable camera transform for this
			self._camera:detach()
			
			-- reconstruct quad if camera scale changes
			if (layer.background_quad == nil or layer.background_cam_diagonal ~= self._camera:getDiagonal()) then
				layer.background_quad = love.graphics.newQuad(0, 0, cbw, cbh, layer.background_view_w, layer.background_view_h)
				background_cam_diagonal = self._camera:getDiagonal()
			end
			
			local image = layer.background_image
			local quad = layer.background_quad
			local x, y, w, h = quad:getViewport()
			local scalar = layer.background_cam_scalar
			local tx, ty = cw/2*csx, ch/2*csy
	
			love.graphics.push()
			love.graphics.translate( tx, ty )
			love.graphics.rotate( ca )
			love.graphics.translate( -tx, -ty )
			
			quad:setViewport((cx + layer.x) * csx * layer.parallax, (cy + layer.y) * csy * layer.parallax, w, h)
			love.graphics.drawq(image, quad, cw*csx, ch*csy, 0, 1, 1, cbw/2, cbh/2)
			
			self._entManager:draw(layer.name) -- draw entities that are to be drawn on this layer
			
			love.graphics.pop()
			
			self._camera:attach()
			
		elseif (layer.type == LAYER_TYPE.CUSTOM) then
			
			love.graphics.push()
			love.graphics.translate(cx*(1-layer.parallax), cy*(1-layer.parallax))
			layer:drawFunc(self._camera)
			love.graphics.pop()
			
		end
		
	end
	
	love.graphics.setColor(255,255,255,255)
	self._entManager:postDraw()
	self._camera:detach()
	
	
end

function Level:getCamera()
	return self._camera
end

function Level:getPhysicsWorld()
	return self._physworld
end

function Level:createEntity( class, ... )
	return self._entManager:createEntity( class, ...)
end

function Level:getEntitiesByClass( class )
	return self._entManager:getEntitiesByClass( class )
end

function Level:getEntitiesByMixin( mixin )
	return self._entManager:getEntitiesByMixin( mixin )
end

function Level:getAllEntities()
	return self._entManager:getAllEntities()
end

function Level:initDefaultCollisionCallbacks()

	if not self._physics_enabled then return end

	local CollisionResolver = CollisionResolver
	
	local beginContact = function(a, b, contact)
		
		local ao = a:getUserData() or a:getBody():getUserData()
		local bo = b:getUserData() or b:getBody():getUserData()
		if (not ao or not bo or not ao.class or not bo.class) then return end
		
		if (ao.class:includes(CollisionResolver)) then
			ao:beginContactWith(bo, contact, a, b, true)
		end

		if (bo.class:includes(CollisionResolver)) then
			bo:beginContactWith(ao, contact, b, a, false)
		end
		
	end

	local endContact = function(a, b, contact)

		local ao = a:getUserData() or a:getBody():getUserData()
		local bo = b:getUserData() or b:getBody():getUserData()
		if (not ao or not bo or not ao.class or not bo.class) then return end
		
		if (ao.class:includes(CollisionResolver)) then
			ao:endContactWith(bo, contact, a, b, true)
		end

		if (bo.class:includes(CollisionResolver)) then
			bo:endContactWith(ao, contact, b, a, false)
		end
		
	end

	local preSolve = function(a, b, contact)

		local ao = a:getUserData() or a:getBody():getUserData()
		local bo = b:getUserData() or b:getBody():getUserData()
		if (not ao or not bo or not ao.class or not bo.class) then return end
		
		if (ao.class:includes(CollisionResolver)) then
			ao:preSolveWith(bo, contact, a, b, true)
		end

		if (bo.class:includes(CollisionResolver)) then
			bo:preSolveWith(ao, contact, b, a, false)
		end
		
	end

	local postSolve = function(a, b, contact)

		local ao = a:getUserData() or a:getBody():getUserData()
		local bo = b:getUserData() or b:getBody():getUserData()
		if (not ao or not bo or not ao.class or not bo.class) then return end
		
		if (ao.class:includes(CollisionResolver)) then
			ao:postSolveWith(bo, contact, a, b, true)
		end

		if (bo.class:includes(CollisionResolver)) then
			bo:postSolveWith(ao, contact, b, a, false)
		end
		
	end
	
	self._physworld:setCallbacks( beginContact, endContact, preSolve, postSolve )
	
end

return Level