local player_selected = ''
local level_selected = ''

function _SCENARIO_SELECT_LOAD()
	love.keypressed = _SCENARIO_SELECT_KEYBINDINGS

	selected_window = {}
	selected_window.graphics = love.graphics.newImage("resources/selected.png")
	selected_window.lock = function(self)
		selected_window.graphics = love.graphics.newImage("resources/selectedlocked.png")
	end
	selected_window.unlock = function(self)
		selected_window.graphics = love.graphics.newImage("resources/selected.png")
	end

	characters_window = {}
	characters_window.name = "Characters Window"
	characters_window.graphics =  love.graphics.newImage("resources/selectcharacter.png")
	characters_window.x = 0
	characters_window.y = 2
	characters_window.selected = true
	characters_window.trigger = function(self)
		selected_window.lock()
		selected_character.unlock()
		currently_selected = selected_pchar
		currently_selected.selected = true
	end
	level_window = {}
	level_window.graphics =  love.graphics.newImage("resources/selectlevel.png")
	level_window.x = 8
	level_window.y = 2
	level_window.selected = true

	--Menu movement
	characters_window.right = level_window
	level_window.left = characters_window

	selected_character = {}
	selected_character.graphics = love.graphics.newImage("resources/frameselected.png")
	selected_character.lock = function(self)
		selected_character.graphics = love.graphics.newImage("resources/frameselectedlocked.png")
	end
	selected_character.unlock = function(self)
		selected_character.graphics = love.graphics.newImage("resources/frameselected.png")
	end

	background = {}
	background.graphics = love.graphics.newImage("resources/menu/titlebackground.png")

	characters_drawables = {}
	init_x = characters_window.x + 1
	init_y = characters_window.y + 1
	x = init_x
	y = init_y

	list_char = {}

	row = 0
	column = 0
	last_pchar = nil
	for name,value in ipairs(playable) do
		frame = {}
		frame.graphics = love.graphics.newImage("resources/frame.png")
		frame.x = x
		frame.y = y
		frame.adjustX = column * 50
		frame.adjustY = row * 30
		if value ~= "empty" then
			pchar = {}
			pchar.name = value
			pchar.selected = false
			pchar.trigger = function(self)
					selected_character.lock()
					selected_window.unlock()
					selected_pchar = self
					currently_selected = characters_window
					currently_selected.selected = true
			end
			pchar.graphics = love.graphics.newImage("resources/characters/"..value..".png")
			pchar.quad = love.graphics.newQuad(0,0,80,80,pchar.graphics:getDimensions())
			pchar.x = x
			pchar.y = y
			pchar.adjustX = column * 50 + 13
			pchar.adjustY = row * 30 + 4
			if(last_pchar ~= nil) then
				last_pchar.right = pchar
				pchar.left = last_pchar
			else
				pchar.selected = true
				selected_pchar = pchar
			end
			last_pchar = pchar
		end

		x = x + 1
		column = column + 1
		if x > 4 then
			x = init_x
			column = 0
			y = y + 1
			row = row + 1
		end

		table.insert(characters_drawables,frame)
		table.insert(characters_drawables,pchar)

		table.insert(list_char,pchar)

	end

	currently_selected = characters_window

end

function _SCENARIO_SELECT_UPDATE(dt)

end

function _SCENARIO_SELECT_DRAW()

	love.graphics.draw(background.graphics, 0, 0)
	love.graphics.draw(characters_window.graphics, characters_window.x * cellSize, characters_window.y * cellSize)
	if(characters_window.selected) then
			love.graphics.draw(selected_window.graphics, characters_window.x * cellSize, characters_window.y * cellSize)
	elseif(level_window.selected) then
			love.graphics.draw(selected_window.graphics, level_window.x * cellSize, level_window.y * cellSize)
	end
	love.graphics.draw(level_window.graphics, level_window.x * cellSize, level_window.y * cellSize)

	draw_x = init_x * cellSize
	for index,value in ipairs(characters_drawables) do
		if value.quad == nil then
			love.graphics.draw(value.graphics, value.x * cellSize + value.adjustX, value.y * cellSize + value.adjustY)
		else
			love.graphics.draw(value.graphics, value.quad, value.x * cellSize + value.adjustX, value.y * cellSize + value.adjustY)
		end

		if value.selected == true then
			love.graphics.draw(selected_character.graphics, value.x * cellSize + value.adjustX, value.y * cellSize + value.adjustY, 0, 1, 1, 24, 12)
		end

		draw_x = draw_x + 120
	end

end


_SCENARIO_SELECT_KEYBINDINGS = function(key)
	if key == "right" then
		if(currently_selected.right ~= nil) then
			currently_selected.selected = false
			currently_selected = currently_selected.right
			currently_selected.selected = true
		end
	end
	if key == "left" then
		if(currently_selected.left ~= nil) then
			currently_selected.selected = false
			currently_selected = currently_selected.left
			currently_selected.selected = true
		end
	end
	if key == "return" then
		print(currently_selected.name)
		currently_selected:trigger()
	end
	if key == "escape" then
		currently_selected.window.unlock()
	end
end
