
local BASE = (...):match('(.-)[^%.]+$')

local s9util = require(BASE.."s9util")


local btn_img = love.graphics.newImage(BASE.."/assets/button2.png")
local quads = 
{
  --normal = s9util.createS9Table(btn_img,0,0,75,23,2,2,2,2),
  --hovered= s9util.createS9Table(btn_img,0,23,75,23,2,2,2,2),
  --active = s9util.createS9Table(btn_img,0,46,75,23,2,2,2,2)
  
  normal = s9util.createS9Table(btn_img,0,0,28,32,6,10,6,6),
  hovered= s9util.createS9Table(btn_img,0,32,28,32,6,10,6,6),
  active = s9util.createS9Table(btn_img,0,64,28,32,6,10,6,6)
}


local function defaultDraw(text, opt, x,y,w,h,theme)
  local opstate = opt.state or "normal"
  local using_quads = opt.quads or quads
  
  local s9t = using_quads[opstate] or using_quads.normal

  love.graphics.setColor(1,1,1)
	theme.drawScale9Quad(s9t,x,y,w,h)
	love.graphics.setColor(66/255,66/255,66/255)
	love.graphics.setFont(opt.font)

	y = y + theme.getVerticalOffsetForAlign(opt.valign, opt.font, h-5)
	love.graphics.printf(text, x+2, y, w-4, opt.align or "center")
end


local function drawDisable(text, opt, x,y,w,h,theme)
  local opstate = "normal"
  local s9t = quads[opstate] or quads.normal

  love.graphics.setColor(190/255,190/255,190/255)
	theme.drawScale9Quad(s9t,x,y,w,h)
	love.graphics.setColor(90/255,90/255,90/255)
	love.graphics.setFont(opt.font)

	y = y + theme.getVerticalOffsetForAlign(opt.valign, opt.font, h-5)
	love.graphics.printf(text, x+2, y, w-4, opt.align or "center")
end


return function(core, text, ...)
	local opt, x,y,w,h = core.getOptionsAndSize(...)
	opt.id = opt.id or text
	opt.font = opt.font or c.font_c14 

	w = w or opt.font:getWidth(text) + 4
	h = h or opt.font:getHeight() + 4

	opt.state = core:registerHitbox(opt,opt.id, x,y,w,h)
  
  local drawfunc = opt.disable and drawDisable or defaultDraw
	core:registerDraw(opt.draw or drawfunc, text, opt, x,y,w,h,core.theme)

	return {
		id = opt.id,
		hit = core:mouseReleasedOn(opt.id) and (not opt.disable),
    active = core:isActive(opt.id),
		hovered = core:isHovered(opt.id) and core:wasHovered(opt.id),
    wasHovered = core:wasHovered(opt.id)
	}
end