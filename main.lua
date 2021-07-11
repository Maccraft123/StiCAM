local tove = require "tove"

local input_f = love.filesystem.read("input.svg")
local input = tove.newGraphics(input_f)

local mode = "normal"
local targetId = 1
local temp = ""

local stickers = {}
local stickercount = 0

local files = {}

function openFile()
	print("adding sticker "..stickercount+1)

	files = love.filesystem.getDirectoryItems("")
	mode = "text"
	temp = ""
end

function fileSelected(name)
	for k, file in ipairs(files) do
		if file:match("[^.]+$") == "svg" then
			if file:match("^"..name) ~= nil then
				if love.filesystem.getInfo(file) ~= nil then
					print("found file "..file)
					temp = file
				else
					return
				end
			end
		end
	end

	stickers[stickercount+1] = {}
	stickers[stickercount+1].fd, err = love.filesystem.read(temp)
	if stickers[stickercount+1].fd == nil then
		print("adding sticker \""..temp.."\" failed: "..err)
		return
	end
	stickers[stickercount+1].x = 0
	stickers[stickercount+1].y = 0
	stickers[stickercount+1].img = tove.newGraphics(stickers[stickercount+1].fd)

	stickercount = stickercount + 1
end

function love.keypressed(key, scan, isRepeat)
	if isRepeat == true then return end
	print("key: "..key)
	if mode == "text" then
		if key == "backspace" then
			temp = temp:sub(1, #temp - 1)
		elseif key == "return" then
			mode = "normal"
			fileSelected(temp)
		end
	end
	if mode == "move" then
		if key == "up" then
			stickers[targetId].y = stickers[targetId].y - 10
		elseif key == "down" then
			stickers[targetId].y = stickers[targetId].y + 10
		elseif key == "left" then
			stickers[targetId].x = stickers[targetId].x - 10
		elseif key == "right" then
			stickers[targetId].x = stickers[targetId].x + 10
		end

		if tonumber(key) ~= nil then
			if tonumber(key) < stickercount then
				targetId = tonumber(key)
			end
		end

		if key == "escape" then
			mode = "normal"
		end
	end
	if key == "q" then
		love.event.quit()
	end
end

function love.textinput(t)
	print("text: "..t)
	if mode == "text" then -- special code for textbox input
		temp = temp..t
	else
		-- mode switching
		if t == "o" then
			openFile()
		elseif t == "m" and stickercount > 0 then
			mode = "move"
		end
	end
end

function love.draw()
	local i = 0
	if mode == "text" then
		love.graphics.print(temp, 0, 0)
		i = i + 10
		for k, file in ipairs(files) do
			if file:match("[^.]+$") == "svg" then
				if file:match("^"..temp) ~= nil then
					i = i + 8
					love.graphics.print(file, 0, i)
				end
			end
		end
	elseif mode == "normal" or mode == "move" then
		for k, j in ipairs(stickers) do
			stickers[k].img:draw(stickers[k].x, stickers[k].y)
		end
	end
end
