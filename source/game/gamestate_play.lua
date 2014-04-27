
local play = gamestate.new("play")
local gui, level, world, player
local lg = love.graphics

local background, background_quad, surfacebackground, surfacebkg_pos
local foreground, foreground_hscale, foreground_vscale
local hp_hud, hp_bar, start_instructions, death_instructions
local font
local player_canvas_coord
local bkg_canvas_size = 700
local bkg_canvas_grid = {}
local bkg_scale = 2
local hud_scale = 2

local next_event_y = 0
local screen_shake = { x = 0, y = 0 }
local snd_explosion

local pixels_per_meter = 30
local dig_target = 1000
local progress = 0
local start_time = 0
local game_ended = false

local DRAW_PHYSICS_WORLD = false

function play:init()
	
	lg.setDefaultFilter( "linear", "nearest" )
	
	gui = GUI()
	
	level = Level(LevelData(), true)
	world = level:getPhysicsWorld()
	
	player = level:createEntity("Driller", world)
	player:setPos( 0, 0 )
	player:setAngle( math.pi / 2 )
	
	player_canvas_coord = Vector(-1000, -1000) -- force it to update
	
	progress = 0
	
	font = lg.newFont( FOLDER.ASSETS.."PressStart2P.ttf", 16 )
	lg.setFont( font )
	
	background = resource.getImage(FOLDER.ASSETS.."dirt.png", "repeat")
	background_quad = lg.newQuad( 0, 0, screen.getRenderWidth() / bkg_scale, screen.getRenderHeight() / bkg_scale, background:getWidth(), background:getHeight())
	
	surfacebackground = resource.getImage(FOLDER.ASSETS.."surface_background.png")
	surfacebkg_pos = Vector( -surfacebackground:getWidth() / 2 * bkg_scale, (-surfacebackground:getHeight() + 10 ) * bkg_scale )
	
	foreground = resource.getImage(FOLDER.ASSETS.."flames.png")
	foreground_hscale = screen.getRenderWidth() / foreground:getWidth() 
	foreground_vscale = 0

	hp_hud = resource.getImage(FOLDER.ASSETS.."hp_interface.png")
	hp_bar = resource.getImage(FOLDER.ASSETS.."hp_bar.png")
	
	start_instructions = resource.getImage(FOLDER.ASSETS.."start_instructions.png")
	death_instructions = resource.getImage(FOLDER.ASSETS.."died_instructions.png")
	
	next_event_y = 1000 -- next y-coordinate for the player to reach for the game to populate the next area
	screen_shake.x = 0
	screen_shake.y = 0
	
	game_ended = false
	
	-- create some clouds
	for i = 1, 20 do
		
		local cloud = level:createEntity( "Cloud" )
		local speed = -1 + math.random() * -10
		cloud:setPos( surfacebkg_pos.x + (i * 100) + (40 * math.random()), surfacebkg_pos.y + 100 + speed * 8 )
		cloud:setScrollSpeed( speed )
		
	end
	
	-- register signals
	snd_explosion = resource.getSound( FOLDER.ASSETS.."explosion.wav", "static" )
	
	signal.register("explosion", function( cause, x, y )
	
		local explo = level:createEntity( "Explosion", world )
		explo:setPos( x, y )
		
		if (level:getCamera():isEntityVisible( explo )) then
			snd_explosion:stop()
			snd_explosion:play()
		end
		
		timer.do_for(0.1, function()
			screen_shake.x = math.randomRange( -10, 10 )
			screen_shake.y = math.randomRange( -10, 10 )
		end, function()
			screen_shake.x = 0
			screen_shake.y = 0
		end)
		
	end)
	
	signal.register("player_death", function()
		
		gui:addSimpleElement( "death_instructions", 0, screen.getRenderWidth() / 2 - start_instructions:getWidth() / 2, 
																		screen.getRenderHeight() / 2 - start_instructions:getHeight() / 2, death_instructions )
		
	end)
	
	signal.register("rock_destroy", function( rock, x, y, spread )
		
		local effect = level:createEntity("BurstParticleSystem", "breakrock")
		effect:setPos( x, y )
		effect:getSystem():setAreaSpread( "uniform", spread, spread )
		
		if (rock:isInstanceOf( Rock )) then
			effect:burst( 40 )
		else
			effect:burst( 10 )
		end
		
		local snd = rock:getDestroySound()
		snd:play()
		
		-- TODO: particles
		
	end)
	
	-- GUI stuff
	gui:addDynamicElement( "health_hud", 0, 10, 10, function()
		
		lg.draw( hp_bar, 33 * hud_scale, 3 * hud_scale, 0, hud_scale * player:getHealth(), hud_scale )
		lg.draw( hp_hud, 0, 0, 0, hud_scale, hud_scale )
		
	end)
	
	local maxw = 0
	local maxdepth = 0
	
	gui:addDynamicElement( "depth", 0, 0, 0, function()
		
		if (Entity.isValid( player )) then
		
			local px, py = player:getPos()
			local depthm = math.max(maxdepth, math.round(py / pixels_per_meter))
			maxdepth = depthm
			
		end
		
		local line = "Drilling depth "..maxdepth.."m"
		local w = math.max( maxw, font:getWidth( line ) )
		maxw = w
		
		lg.print(line, screen.getRenderWidth() - maxw - 10, 10)
		
	end)
	
	gui:addSimpleElement( "start_instructions", 0, screen.getRenderWidth() / 2 - start_instructions:getWidth() / 2, 
																		screen.getRenderHeight() / 2 - start_instructions:getHeight() / 2, start_instructions )
	
	-- register starting key
	input:addKeyPressCallback("start_driller", "down", function() 
		
		start_time = currentTime()
		
		gui:removeElement( "start_instructions" )
		input:removeKeyPressCallback("start_driller")
		player:start()
		
		timer.addPeriodic(0.1, function() self:gameThink() end)
		
		end)
	
	
end

function play:gameThink()
	
	if not (Entity.isValid( player )) then return end
	
	local px, py = player:getPos()
	local cx, cy = level:getCamera():getPos()
	
	math.randomseed( os.time() + py ) -- for some reason the random pool reset :/
	
	if (py > next_event_y) then
		
		next_event_y = next_event_y + 1000
		
		-- obstacle functions
		
		local function barrelLayer( y, y_spread )
			for i = 1, 40 do
				
				local barrel = level:createEntity("TntBarrel", world)
				barrel:setPos( px - 4100 + i * 200 + math.random() * 100, y + math.random() * y_spread )
				
			end
		end
		
		local function missile( speed )
			
			local mv = util.choose( 
				Vector( cx - screen.getRenderWidth() / 2 - 100, py - 200 + math.random() * 600 ),
				Vector( cx + screen.getRenderWidth() / 2 + 100, py - 200 + math.random() * 600 ))
			local pv = Vector( px, py )
			local pdir = angle.forward( player:getAngle() )
			
			local dir =  ((pv + pdir * speed) - mv):normalize()
			
			local missile = level:createEntity("Missile", world)
			missile:setPos( mv.x, mv.y )
			missile:setAngle( dir:angle() )
			missile:setSpeed( speed )
			
		end
		
		local function smallRockLayer( y, y_spread )
			for i = 1, 40 do
				
				local rock = level:createEntity("SmallRock", world)
				rock:setPos( px - 4100 + i * 200 + math.random() * 100, y + math.random() * y_spread )
				
			end
		end
		
		local function rockLayer( y, y_spread )
			for i = 1, 40 do
				
				local rock = level:createEntity("Rock", world)
				rock:setPos( px - 4100 + i * 200 + math.random() * 100, y + math.random() * y_spread )
				
			end
		end
		
		-- spawn next set of obstacles
		
		barrelLayer( py + 1000, 100 )
		smallRockLayer( py + 1200, 100 )
		rockLayer( py + 1400, 300 )
		
		missile( 500 )
		
		-- remove all entities that are far above the camera
		table.forEach( level:getAllEntities(), function(k, ent)
			local ex, ey = ent:getPos()
			if (ey < cy - 1000) then
				ent:remove()
			end
			
		end)
	
	end
	
end

function play:enter()

end

function play:leave()

end

function play:update( dt )
	
	if (Entity.isValid( player )) then
	
		local px, py = player:getPos()
		
		level:getCamera():setPos( math.round(px) + screen_shake.x, math.round(py + screen.getRenderHeight() / 4) + screen_shake.y )
		
		progress = math.clamp( py / pixels_per_meter / dig_target, 0, 1 )
		foreground_vscale = progress
		
		if (progress >= 1 and not game_ended) then
			self:endGame()
		end
		
		-- handle active canvases
		local pcx, pcy = math.floor(px / bkg_canvas_size), math.floor(py / bkg_canvas_size)
		local old_pcx, old_pcy = player_canvas_coord:unpack()
		
		local new_grid = {}
		
		if ((old_pcx ~= pcx or old_pcy ~= pcy) and lg.isSupported("canvas")) then
			
			--print("Updating player canvas pos to "..pcx..", "..pcy)
			
			-- create canvas grid
			for xi = -1, 1 do
				new_grid[pcx+xi] = {}
				
				for yi = -1, 1 do
					if not bkg_canvas_grid[pcx+xi] or not bkg_canvas_grid[pcx+xi][pcy+yi] then
						new_grid[pcx+xi][pcy+yi] = lg.newCanvas( bkg_canvas_size, bkg_canvas_size )
					else
						new_grid[pcx+xi][pcy+yi] = bkg_canvas_grid[pcx+xi][pcy+yi]
					end
				end			
			end
			
			player_canvas_coord.x = pcx
			player_canvas_coord.y = pcy
			
			--print("New canvas grid: \n"..table.toString( new_grid, "grid", true ))
			bkg_canvas_grid = new_grid
			
		end
		
	end
	
	if (not game_ended) then
	
		level:update( dt )
		
	end
	
	gui:update( dt )
	
end

function play:endGame()

	
	game_ended = true

end

local function bkg_stencil()

	for k, v in pairs( level:getEntitiesByMixin( TerrainMask ) ) do
		v:drawMask()
	end
	
end

function play:draw()
	
	for xi, v in pairs( bkg_canvas_grid ) do
		for yi, canvas in pairs( v ) do
			
			lg.setCanvas( canvas )
				lg.push()
				lg.translate( xi * -bkg_canvas_size, yi * -bkg_canvas_size )
				lg.setStencil( bkg_stencil )
				lg.setColor(60, 25, 0, 200)
				lg.pop()
				lg.rectangle("fill", 0, 0, bkg_canvas_size, bkg_canvas_size)
				lg.setColor(255, 255, 255, 255)
				lg.setStencil()
				--lg.rectangle("line", 0, 0, bkg_canvas_size, bkg_canvas_size) -- debug draws canvas boundries
			lg.setCanvas()
			
		end
	end
	
	local cx, cy = level:getCamera():getPos()
	background_quad:setViewport( cx / bkg_scale, cy / bkg_scale, screen.getRenderWidth() / bkg_scale, screen.getRenderHeight() / bkg_scale )
	
	lg.draw( background, background_quad, 0, 0, 0, bkg_scale, bkg_scale )
	
	level:getCamera():attach()
	
	for xi, v in pairs( bkg_canvas_grid ) do -- draw all the digging trail canvases
		for yi, canvas in pairs( v ) do
			lg.draw( canvas, xi * bkg_canvas_size, yi * bkg_canvas_size )
			--print("drawing canvas at "..xi * bkg_canvas_size..", "..yi * bkg_canvas_size)
		end
	end
	
	if (cy < 1000) then -- draw surface background at start
		local bx, by = surfacebkg_pos:unpack()
		lg.draw( surfacebackground, bx, by, 0, bkg_scale, bkg_scale )
	end
	
	level:getCamera():detach()
	
	level:draw()
	
	lg.setColor( 255, 255, 255, progress * 255 )
	lg.draw( foreground, 0, screen.getRenderHeight(), 0, foreground_hscale, -foreground_vscale )
	lg.setColor( Color.White:unpack() )
	
	gui:draw()
	
	if (DRAW_PHYSICS_WORLD) then
		level:getCamera():attach()
		debug.drawPhysicsWorld( world )
		level:getCamera():detach()
	end
	
end

return play