local suit = require"ui/suit"

local parchment = c.pic.parchment

local function defaultDraw(x,y,w,h,style)
  if style ==1 then
    love.graphics.setColor(0.8,0.8,1)
  elseif style ==2 then
    love.graphics.setColor(1,0.85,0.85)
  else
    love.graphics.setColor(1,1,1)
  end
  suit.theme.drawScale9Quad(parchment,x,y,w,h)
end

return function(id, x,y,w,h,style)
	suit:registerHitbox(nil,id, x,y,w,h)
  suit:registerDraw(defaultDraw,x,y,w,h,style)
	return {
		id = id,
		hit = suit:mouseReleasedOn(id),
    active = suit:isActive(id),
		hovered = suit:isHovered(id) and suit:wasHovered(id),
    wasHovered = suit:wasHovered(id)
	}
end