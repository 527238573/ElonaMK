-- This file is part of SUIT, copyright (c) 2016 Matthias Richter

local BASE = (...):match('(.-)[^%.]+$')

local function defaultDraw(fraction, opt, x,y,w,h,theme)
	local xb, yb, wb, hb -- size of the progress bar
	local r =  math.min(w,h) / 2.1
	if opt.vertical then
		x, w = x + w*.25, w*.5
		xb, yb, wb, hb = x, y+h*(1-fraction), w, h*fraction
	else
		y, h = y + h*.25, h*.5
		xb, yb, wb, hb = x,y, w*fraction, h
	end
  local bar_res = c.pic["slider_bar"]
	local c = theme.getColorForState(opt)
  love.graphics.setColor(1,1,1)
  theme.drawScale9Quad(bar_res.back,x,y,w,h)
  --theme.drawScale9Quad(bar_res.front,x,y,w,h)
  theme.drawScale9Quad(bar_res.front,xb,yb,wb,hb)
	--theme.drawBox(x,y,w,h, c, opt.cornerRadius)
	--theme.drawBox(xb,yb,wb,hb, {bg=c.fg}, opt.cornerRadius)
  if opt.vertical then
    love.graphics.draw(bar_res.img,bar_res.triangle, x+wb/2, yb,math.pi/2,1,1,16,16)
  else
    love.graphics.draw(bar_res.img,bar_res.triangle, x+wb, yb+hb/2,0,1,1,16,16)
  end
  
	
end

return function(core, info, ...)
	local opt, x,y,w,h = core.getOptionsAndSize(...)

	opt.id = opt.id or info

	info.min = info.min or math.min(info.value, 0)
	info.max = info.max or math.max(info.value, 1)
	info.step = info.step or (info.max - info.min) / 10
	local fraction = (info.value - info.min) / (info.max - info.min)
	local value_changed = false

	opt.state = core:registerHitbox(opt,opt.id, x,y,w,h)

	if core:isActive(opt.id) then
		-- mouse update
		local mx,my = core:getMousePosition()
		if opt.vertical then
			fraction = math.min(1, math.max(0, (y+h - my) / h))
		else
			fraction = math.min(1, math.max(0, (mx - x) / w))
		end
		local v = fraction * (info.max - info.min) + info.min
		if v ~= info.value then
			info.value = v
			value_changed = true
		end
	end
	core:registerDraw(opt.draw or defaultDraw, fraction, opt, x,y,w,h,core.theme)

	return {
		id = opt.id,
		hit = core:mouseReleasedOn(opt.id),
    active = core:isActive(opt.id),
		changed = value_changed,
		hovered = core:isHovered(opt.id) and core:wasHovered(opt.id),
    wasHovered = core:wasHovered(opt.id)
	}
end
