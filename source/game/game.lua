
local playState, menuState

function game.load()
	
	playState = require("game/gamestate_play")
	menuState = require("game/gamestate_menu")
	
	screen.setScaleType( SCREEN_SCALE.CENTER )

	gamestate.set( playState )
	
end

function game.update( dt )
	
	if (input:keyIsPressed("escape")) then love.event.quit() return end
	if (input:keyIsPressed("r")) then game.restart() return end
	
	gamestate.update( dt )
	
end

function game.draw()
	
	love.graphics.setBackgroundColor( 30, 30, 40 )
	love.graphics.clear()
	gamestate.drawStack()
	
end

function game.handleTrigger( trigger, other, contact, trigger_type, ...)
	
	-- function called by Trigger entities upon triggering. Return true to disable the trigger.
	return gamestate.handleTrigger( trigger, other, contact, trigger_type, ...)
	
end

function game.restart()

	package.loaded["game/gamestate_play"] = nil
	package.loaded["game/gamestate_menu"] = nil
	game.load()	

end