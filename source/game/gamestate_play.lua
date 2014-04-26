
local play = gamestate.new("play")
local gui, level, player, world

function play:init()

	gui = GUI()
	
	level = Level(LevelData(), true)
	
end

function play:enter()

end

function play:leave()

end

function play:update( dt )
	
	level:update( dt )
	gui:update( dt )
	
end

function play:draw()
	
	level:draw()
	gui:draw()
	
end

return play