local suit = require"ui/suit"
local btn_img = love.graphics.newImage("ui/suit/assets/button.png")
local quads = 
{
  --normal = s9util.createS9Table(btn_img,0,0,75,23,2,2,2,2),
  --hovered= s9util.createS9Table(btn_img,0,23,75,23,2,2,2,2),
  --active = s9util.createS9Table(btn_img,0,46,75,23,2,2,2,2)
  
  normal = suit.createS9Table(btn_img,0,0,28,32,6,10,6,6),
  hovered= suit.createS9Table(btn_img,0,32,28,32,6,10,6,6),
  active = suit.createS9Table(btn_img,0,64,28,32,6,10,6,6)
}


local function defaultDraw(picquad,picimg, opt, x,y,w,h,theme)
  local opstate = opt.state or "normal"
  local s9t = quads[opstate] or quads.normal

  local pic_size = opt.pic_size or 2
  love.graphics.oldColor(255,255,255)
	theme.drawScale9Quad(s9t,x,y,w,h)
  local side = 6
  if opt.noside then side =0 end
  love.graphics.draw(picimg,picquad,x+side,y+side,0,pic_size,pic_size)
end

local function drawDisable(picquad,picimg, opt, x,y,w,h,theme)
  local opstate = "normal"
  local s9t = quads[opstate] or quads.normal

  local pic_size = opt.pic_size or 2
  love.graphics.oldColor(160,160,160)
	theme.drawScale9Quad(s9t,x,y,w,h)
  local side = 6
  if opt.noside then side =0 end
  love.graphics.draw(picimg,picquad,x+side,y+side,0,pic_size,pic_size)
end



return function(picquad,picimg, ...)
	local opt, x,y,w,h = suit.getOptionsAndSize(...)
	opt.id = opt.id or picquad
	opt.state = suit:registerHitbox(opt,opt.id, x,y,w,h)
  
  local drawfunc = opt.disable and drawDisable or defaultDraw
  
	suit:registerDraw(drawfunc, picquad,picimg, opt, x,y,w,h,suit.theme)

	return {
		id = opt.id,
		hit = suit:mouseReleasedOn(opt.id) and (not opt.disable),
    active = suit:isActive(opt.id),
		hovered = suit:isHovered(opt.id) and suit:wasHovered(opt.id),
    wasHovered = suit:wasHovered(opt.id)
	}
end