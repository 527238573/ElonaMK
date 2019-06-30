-- This file is part of SUIT, copyright (c) 2016 Matthias Richter

local BASE = (...):match('(.-)[^%.]+$')

-- 可兼容  image 或quad
local function defaultDraw(opt,quads,x,y,scalex,scaley)
  local todraw = quads.normal
  if opt.state == "active" then
    todraw = quads.active
  elseif opt.state == "hovered" then
    todraw = quads.hovered
  end
  love.graphics.setColor(1,1,1)
  if todraw:typeOf("Image")  then 
    love.graphics.draw(todraw,x,y,0,scalex,scaley)
  else
    love.graphics.draw(quads.img,todraw,x,y,0,scalex,scaley)
  end
end

local function defaultS9Draw(opt,quads,x,y,w,h,theme)
  local todraw = quads.normal
  if opt.state == "active" then
    todraw = quads.active
  elseif opt.state == "hovered" then
    todraw = quads.hovered
  elseif opt.state == "disable" then
    todraw = quads.disable
  end
  if opt.color then
    love.graphics.setColor(opt.color)
  else
    love.graphics.setColor(1,1,1)
  end
  theme.drawScale9Quad(todraw,x,y,w,h)
  if opt.text then
    if opt.textcolor then love.graphics.setColor(opt.textcolor[1],opt.textcolor[2],opt.textcolor[3]) else love.graphics.setColor(66/255,66/255,66/255) end
    love.graphics.setFont(opt.font)
    y = y + theme.getVerticalOffsetForAlign(opt.valign, opt.font, h-1)
    love.graphics.printf(opt.text, x+2, y, w-4, opt.align or "center")
  end
end




return function(core, quads, ...)
  local opt, x,y,w,h = core.getOptionsAndSize(...)
  quads.normal = quads.normal or quads[1]
  quads.hovered = quads.hovered or quads[2] or quads.normal
  quads.active = quads.active or quads[3] or quads.hovered
  opt.id = opt.id or quads
  assert(quads.normal, "Need at least `normal' state image")

  local f1,f2,imgw,imgh
  local is_s9 = false

  if quads.normal:typeOf("Image")  then 
    imgw = quads.normal:getWidth()
    imgh = quads.normal:getHeight()
  elseif quads.normal:typeOf("Quad") then
    f1,f2,imgw,imgh = quads.normal:getViewport()
  else
    is_s9 = true -- scale9table
    imgw = quads.normal.w
    imgh = quads.normal.h
  end
  w = w or imgw
  h = h or imgh
  opt.state = core:registerHitbox(opt,opt.id, x,y,w,h)
  if is_s9 then
    core:registerDraw(opt.draw or defaultS9Draw, opt, quads,x,y,w,h,core.theme)
  else
    core:registerDraw(opt.draw or defaultDraw, opt, quads,x,y,w/imgw,h/imgh)
  end

  return {
    id = opt.id,
    hit = core:mouseReleasedOn(opt.id),
    active = core:isActive(opt.id),
    hovered = core:isHovered(opt.id) and core:wasHovered(opt.id),
    wasHovered = core:wasHovered(opt.id)
  }
end
