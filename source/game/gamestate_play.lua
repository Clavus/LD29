
local play = gamestate.new("play")
local gui, level, player, background, background_quad
local lg = love.graphics

local player_canvas_coord
local bkg_canvas_size = 600
local bkg_canvas_grid = {}
local bkg_scale = 2

function play:init()

	gui = GUI()
	
	level = Level(LevelData(), true)
	
	player = level:createEntity("Driller")
	player:setPos( 0, 0 )
	player:setAngle( math.pi / 2 )
	
	player_canvas_coord = Vector(-1000, -1000) -- force it to update
	
	background = resource.getImage(FOLDER.ASSETS.."dirt.png", "repeat")
	background:setFilter("linear", "nearest")
	background_quad = lg.newQuad( 0, 0, screen.getRenderWidth() / bkg_scale, screen.getRenderHeight() / bkg_scale, background:getWidth(), background:getHeight())
	
end

function play:enter()

end

function play:leave()

end

function play:update( dt )
	
	local px, py = player:getPos()
	level:getCamera():setPos( px, py + screen.getRenderHeight() / 4 )
	
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
	
	level:update( dt )
	gui:update( dt )
	
end

local bkg_stencil = function()
	player:drawMask()
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
	for xi, v in pairs( bkg_canvas_grid ) do
		for yi, canvas in pairs( v ) do
			lg.draw( canvas, xi * bkg_canvas_size, yi * bkg_canvas_size )
			--print("drawing canvas at "..xi * bkg_canvas_size..", "..yi * bkg_canvas_size)
		end
	end
	level:getCamera():detach()
	
	level:draw()
	gui:draw()
	
end

return play