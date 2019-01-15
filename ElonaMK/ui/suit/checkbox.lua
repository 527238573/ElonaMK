-- This file is part of SUIT, copyright (c) 2016 Matthias Richter

local BASE = (...):match('(.-)[^%.]+$')



local function defaultDraw(chk, opt, x,y,w,h,theme)
	local c = theme.getColorForState(opt)
	local th = opt.font:getHeight()

	theme.drawBox(x+h/10,y+h/10,h*.8,h*.8, c, opt.cornerRadius)
	--love.graphics.setColor(c.fg)
  love.graphics.setColor(66/255, 66/255, 66/255)
	if chk.checked then
		love.graphics.setLineStyle('smooth')
		love.graphics.setLineWidth(5)
		love.graphics.setLineJoin("bevel")
		love.graphics.line(x+h*.2,y+h*.55, x+h*.45,y+h*.75, x+h*.8,y+h*.2)
	end

	if chk.text then
		love.graphics.setFont(opt.font)
		y = y + theme.getVerticalOffsetForAlign(opt.valign, opt.font, h)
		love.graphics.printf(chk.text, x + h, y, w - h, opt.align or "left")
	end
end


return function(core, checkbox, ...)
	local opt, x,y,w,h = core.getOptionsAndSize(...)
	opt.id = opt.id or checkbox
	opt.font = opt.font or c.font_c14

	w = w or (opt.font:getWidth(checkbox.text) + opt.font:getHeight() + 4)
	h = h or opt.font:getHeight() + 4

	opt.state = core:registerHitbox(opt,opt.id, x,y,w,h)
  local change = false
	local hit = core:mouseReleasedOn(opt.id) 
	if hit then
		checkbox.checked = not checkbox.checked
    change = true
	end
	core:registerDraw(opt.draw or defaultDraw, checkbox, opt, x,y,w,h,core.theme)

	return {
		id = opt.id,
		hit = hit,
    active = core:isActive(opt.id),
		hovered = core:isHovered(opt.id) and core:wasHovered(opt.id),
    wasHovered = core:wasHovered(opt.id),
    change = change
	}
end
