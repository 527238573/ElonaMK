-- This file is part of SUIT, copyright (c) 2016 Matthias Richter

local BASE = (...):match('(.-)[^%.]+$')


local function defaultDraw(text, opt, x,y,w,h,theme)
	y = y + theme.getVerticalOffsetForAlign(opt.valign, opt.font, h)

	love.graphics.setColor( opt.color  or theme.color.normal.fg)
	love.graphics.setFont(opt.font)
	love.graphics.printf(text, x+2, y, w-4, opt.align or "center")
end


return function(core, text, ...)
	local opt, x,y,w,h = core.getOptionsAndSize(...)
	opt.font = opt.font or c.font_c14

	w = w or opt.font:getWidth(text) + 4
	h = h or opt.font:getHeight() + 4
  
  core:registerDraw(opt.draw or defaultDraw, text, opt, x,y,w,h,core.theme)-- 先绘制，绘制无影响

	if opt.block then 
    opt.id = opt.id or text
    opt.state = core:registerHitbox(opt,opt.id, x,y,w,h) 
    return {
		id = opt.id,
		hit = core:mouseReleasedOn(opt.id),
    active = core:isActive(opt.id),
		hovered = core:isHovered(opt.id) and core:wasHovered(opt.id),
    wasHovered = core:wasHovered(opt.id)
	}
  end --一般情况下文字无遮挡

end
