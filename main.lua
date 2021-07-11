local tove = require "tove"

local input_f = love.filesystem.read("input.svg")
local input = tove.newGraphics(input_f)

local mode = "normal"
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
	stickers[stickercount+1].img = tove.newGraphics(stickers[stickercount+1].fd)

	stickercount = stickercount + 1
end

function love.keypressed(key, scan, isRepeat)
	if isRepeat == true then return end
	if mode == "text" then
		if key == "backspace" then
			temp = temp:sub(1, #temp - 1)
		elseif key == "return" then
			mode = "normal"
			fileSelected(temp)
		end
	end
end

function love.textinput(t)
	if mode == "text" then
		temp = temp..t
	elseif mode == "normal" then
		if t == "o" then
			openFile()
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
	elseif mode == "normal" then
		for k, j in ipairs(stickers) do
			stickers[k].img:draw()
		end
	end
end
