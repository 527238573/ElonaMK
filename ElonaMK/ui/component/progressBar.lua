local suit = require"ui/suit"



local function defaultDraw(value,style,x,y,w,h)
  local pb = c.pic.progressBar
	local xb, yb, wb, hb -- size of the progress bar
	if opt.vertical then
		x, w = x + w*.25, w*1.5
		xb, yb, wb, hb = x, y+h*(1-value), w, h*value
	else
		y, h = y + h*.25, h*1.5
		xb, yb, wb, hb = x,y, w*value, h
	end
  love.graphics.setColor(1,1,1)
  suit.theme.drawScale9Quad(pb[1],x,y,w,h)
  suit.theme.drawScale9Quad(pb[style],xb,yb,wb,hb)
end

return function(opt,x,y,w,h)
  
	opt.id = opt.id or opt
	opt.value = math.max(math.min(opt.value, 1), 0)
	opt.state = suit:registerHitbox(opt,opt.id,x,y,w,h)
	suit:registerDraw(defaultDraw,opt,x,y,w,h)

	return {
		id = opt.id,
		hit = suit:mouseReleasedOn(opt.id),
    active = suit:isActive(opt.id),
		hovered = suit:isHovered(opt.id) and suit:wasHovered(opt.id),
    wasHovered = suit:wasHovered(opt.id)
	}
end