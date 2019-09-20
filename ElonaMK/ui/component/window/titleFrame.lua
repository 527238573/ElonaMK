local suit = require"ui/suit"

local kuang = c.pic.titleKuang
local list = c.pic["uiIcon"]
local img = list.img

local function defaultDraw(str,x,y,w,h,icon_index)
  love.graphics.setColor(1,1,1)
  suit.theme.drawScale9Quad(kuang,x,y,w,h)
  local dx = 50
  if icon_index>0 then
    love.graphics.draw(img,list[icon_index],x+4,y-32,0,2,2)
  else
    dx = 0
  end
  love.graphics.setColor(0.7,0.7,0.7)
	love.graphics.setFont(c.font_c20)
	love.graphics.printf(str,x+dx,y+8, w-dx, "center")
end

return function(id,str, x,y,w,h ,icon_index)
	suit:registerHitbox(nil,id,x,y,w,h)
  suit:registerDraw(defaultDraw,str,x,y,w,h,icon_index)
	return {
		id = id,
		hit = suit:mouseReleasedOn(id),
    active = suit:isActive(id),
		hovered = suit:isHovered(id) and suit:wasHovered(id),
    wasHovered = suit:wasHovered(id)
	}
end