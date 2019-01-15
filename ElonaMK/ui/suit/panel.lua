local BASE = (...):match('(.-)[^%.]+$')
local s9util = require(BASE.."s9util")
local panel_img = love.graphics.newImage(BASE.."/assets/border.png")
local s9table = s9util.createS9Table(panel_img,0,0,50,14,3,3,3,3)


local function defaultDraw(x,y,w,h,theme)
  love.graphics.setColor(1,1,1)
  theme.drawScale9Quad(s9table,x,y,w,h)
end

return function(core, id, x,y,w,h)
	
	core:registerHitbox(nil,id, x,y,w,h)
  core:registerDraw(defaultDraw,x,y,w,h,core.theme)
	return {
		id = id,
		hit = core:mouseReleasedOn(id),
    active = core:isActive(id),
		hovered = core:isHovered(id) and core:wasHovered(id),
    wasHovered = core:wasHovered(id)
	}
end