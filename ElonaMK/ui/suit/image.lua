local BASE = (...):match('(.-)[^%.]+$')


local function defaultDraw(opt,todraw,x,y,scalex,scaley)
  love.graphics.setColor(1,1,1)
  if todraw:typeOf("Image")  then 
    love.graphics.draw(todraw,x,y,0,scalex,scaley)
  else
    love.graphics.draw(opt.img,todraw,x,y,0,scalex,scaley)
  end
end

local function defaultS9Draw(todraw,x,y,w,h,theme)
  love.graphics.setColor(1,1,1)
  theme.drawScale9Quad(todraw,x,y,w,h)
end

return function(core, todraw, ...)
	local opt, x,y,w,h = core.getOptionsAndSize(...)
	opt.id = opt.id or todraw
  
  local f1,f2,imgw,imgh
  local is_s9 = false
  if todraw:typeOf("Image")  then 
    imgw = todraw:getWidth()
    imgh = todraw:getHeight()
  elseif todraw:typeOf("Quad") then
    f1,f2,imgw,imgh = todraw:getViewport()
    assert(opt.img,"opt.img must be set to draw Image")
  else
    is_s9 = true -- scale9table
    imgw = todraw.w
    imgh = todraw.h
  end
  w = w or imgw
  h = h or imgh
  
	opt.state = core:registerHitbox(opt,opt.id, x,y,w,h)
  if is_s9 then
    core:registerDraw(opt.draw or defaultS9Draw,todraw,x,y,w,h,core.theme)
  else
    core:registerDraw(opt.draw or defaultDraw, opt, todraw,x,y,w/imgw,h/imgh)
  end

	return {
		id = opt.id,
		hit = core:mouseReleasedOn(opt.id),
    active = core:isActive(opt.id),
		hovered = core:isHovered(opt.id) and core:wasHovered(opt.id),
    wasHovered = core:wasHovered(opt.id)
	}
end