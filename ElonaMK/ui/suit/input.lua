-- This file is part of SUIT, copyright (c) 2016 Matthias Richter

local BASE = (...):match('(.-)[^%.]+$')
local utf8 = require 'utf8'

local function split(str, pos)
	local offset = utf8.offset(str, pos) or 0
	return str:sub(1, offset-1), str:sub(offset)
end



local function defaultDraw(input, opt, x,y,w,h,theme)
	--local utf8 = require 'utf8'
	theme.drawBox(x,y,w,h, (opt.color and opt.color.normal) or theme.color.normal, opt.cornerRadius)
	x = x + 3
	w = w - 6

	local th = opt.font:getHeight()

	-- set scissors
	local sx, sy, sw, sh = love.graphics.getScissor()
	love.graphics.setScissor(x-1,y,w+2,h)
	x = x - input.text_draw_offset

	-- text
	love.graphics.setColor((opt.color and opt.color.normal and opt.color.normal.fg) or theme.color.normal.fg)
	love.graphics.setFont(opt.font)
	love.graphics.print(input.text, x, y+(h-th)/2)

	-- cursor
	if opt.hasKeyboardFocus and (love.timer.getTime() % 1) > .5 then
		love.graphics.setLineWidth(1)
		love.graphics.setLineStyle('rough')
		love.graphics.line(x + opt.cursor_pos, y + (h-th)/2,
		                   x + opt.cursor_pos, y + (h+th)/2)
	end

	-- reset scissor
	love.graphics.setScissor(sx,sy,sw,sh)
end




return function(core, input, ...)
	local opt, x,y,w,h = core.getOptionsAndSize(...)
	opt.id = opt.id or input
	opt.font = opt.font or c.font_c14

	local text_width = opt.font:getWidth(input.text)
	w = w or text_width + 6
	h = h or opt.font:getHeight() + 4

	input.text = input.text or ""
	input.cursor = math.max(1, math.min(utf8.len(input.text)+1, input.cursor or utf8.len(input.text)+1))
	-- cursor is position *before* the character (including EOS) i.e. in "hello":
	--   position 1: |hello
	--   position 2: h|ello
	--   ...
	--   position 6: hello|

	-- get size of text and cursor position
	opt.cursor_pos = 0
	if input.cursor > 1 then
		local s = input.text:sub(1, utf8.offset(input.text, input.cursor)-1)
		opt.cursor_pos = opt.font:getWidth(s)
	end

	-- compute drawing offset
	local wm = w - 6 -- consider margin
	input.text_draw_offset = input.text_draw_offset or 0
	if opt.cursor_pos - input.text_draw_offset < 0 then
		-- cursor left of input box
		input.text_draw_offset = opt.cursor_pos
	end
	if opt.cursor_pos - input.text_draw_offset > wm then
		-- cursor right of input box
		input.text_draw_offset = opt.cursor_pos - wm
	end
	if text_width - input.text_draw_offset < wm and text_width > wm then
		-- text bigger than input box, but does not fill it
		input.text_draw_offset = text_width - wm
	end

	-- user interaction
	opt.state = core:registerHitbox(opt,opt.id, x,y,w,h)
	opt.hasKeyboardFocus = core:grabKeyboardFocus(opt.id)

	if opt.hasKeyboardFocus then
		local keycode,char = core:getPressedKey()
		-- text input
		if char and char ~= "" then
			local a,b = split(input.text, input.cursor)
			input.text = table.concat{a, char, b}
			input.cursor = input.cursor + utf8.len(char)
		end

		-- text editing
		if keycode == 'backspace' then
			local a,b = split(input.text, input.cursor)
			input.text = table.concat{split(a,utf8.len(a)), b}
			input.cursor = math.max(1, input.cursor-1)
		elseif keycode == 'delete' then
			local a,b = split(input.text, input.cursor)
			local _,b = split(b, 2)
			input.text = table.concat{a, b}
		end

		-- cursor movement
		if keycode =='left' then
			input.cursor = math.max(0, input.cursor-1)
		elseif keycode =='right' then -- cursor movement
			input.cursor = math.min(utf8.len(input.text)+1, input.cursor+1)
		elseif keycode =='home' then -- cursor movement
			input.cursor = 1
		elseif keycode =='end' then -- cursor movement
			input.cursor = utf8.len(input.text)+1
		end

		-- move cursor position with mouse when clicked on
		if core:mouseReleasedOn(opt.id) then
			local mx = core:getMousePosition() - x + input.text_draw_offset
			input.cursor = utf8.len(input.text) + 1
			for c = 1,input.cursor do
				local s = input.text:sub(0, utf8.offset(input.text, c)-1)
				if opt.font:getWidth(s) >= mx then
					input.cursor = c-1
					break
				end
			end
		end
	end

	core:registerDraw(opt.draw or defaultDraw, input, opt, x,y,w,h,core.theme)

	return {
		id = opt.id,
		hit = core:mouseReleasedOn(opt.id),
    active = core:isActive(opt.id),
		submitted = core:keyPressedOn(opt.id, "return"),
		hovered = core:isHovered(opt.id) and core:wasHovered(opt.id),
    wasHovered = core:wasHovered(opt.id)
	}
end
