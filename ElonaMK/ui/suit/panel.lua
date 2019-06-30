local BASE = (...):match('(.-)[^%.]+$')
local s9util = require(BASE.."s9util")
local panel_img = love.graphics.newImage(BASE.."/assets/border.png")
local s9table = s9util.createS9Table(panel_img,0,0,50,14,3,3,3,3)


local function defaultDraw(x,y,w,h,theme)
  love.graphics.setColor(1,1,1)
  theme.drawScale9Quad(s9table,x,y,w,h)
end

local panel_img2 = love.graphics.newImage("assets/ui/border2.png")
local quad1 = love.graphics.newQuad(0,0,4,28,panel_img2:getDimensions())
local quad2 = love.graphics.newQuad(4,0,12,28,panel_img2:getDimensions())

local function defaultDraw2(x,y,w,h)
  love.graphics.setColor(1,1,1)
  love.graphics.draw(panel_img2,quad1,x,y,0,1,h/28)
  love.graphics.draw(panel_img2,quad2,x+4,y,0,(w-4)/12,h/28)
end


return function(core, id, x,y,w,h)
	core:registerHitbox(nil,id, x,y,w,h)
  if id.mg then 
    core:registerDraw(defaultDraw2,x,y,w,h,core.theme)
  else
    core:registerDraw(defaultDraw,x,y,w,h,core.theme)
  end
	return {
		id = id,
		hit = core:mouseReleasedOn(id),
    active = core:isActive(id),
		hovered = core:isHovered(id) and core:wasHovered(id),
    wasHovered = core:wasHovered(id)
	}
end