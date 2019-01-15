
local suit = require"ui/suit"
local panel_img = love.graphics.newImage("assets/ui/border.png")
local quad1 = love.graphics.newQuad(0,0,4,28,panel_img:getDimensions())
local quad2 = love.graphics.newQuad(4,0,12,28,panel_img:getDimensions())

local function defaultDraw(x,y,w,h)
  love.graphics.oldColor(255,255,255)
  love.graphics.draw(panel_img,quad1,x,y,0,1,h/28)
  love.graphics.draw(panel_img,quad2,x+4,y,0,(w-4)/12,h/28)
end

return function(id, x,y,w,h)
	
	suit:registerHitbox(nil,id, x,y,w,h)
  suit:registerDraw(defaultDraw,x,y,w,h)
	return {
		id = id,
		hit = suit:mouseReleasedOn(id),
    active = suit:isActive(id),
		hovered = suit:isHovered(id) and suit:wasHovered(id),
    wasHovered = suit:wasHovered(id)
	}
end