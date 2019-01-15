local suit = require "ui/suit"
local quads = c.pic["editor_btn_quads"]

local function defaultDraw(info, opt, x,y,w,h,selected,img,theme)
  --local quads = c.pic.editor_btn_quads
  local opstate = opt.state or "normal"
  local s9t = quads[opstate] or quads.normal
  if opstate == "active" then 
    love.graphics.setColor(255/255,127/255,39/255)
  elseif selected then 
    love.graphics.setColor(225/255,107/255,29/255)
  else
    love.graphics.setColor(1,1,1)
  end
  theme.drawS9Border(s9t,x,y,w,h)
  love.graphics.setColor(1,1,1)
  
  img = img or info.img

  if info[1] then 
    local f1,f2,imgw,imgh = info[1]:getViewport()
    local sx = 32/imgw
    local sy = 32/imgh
    love.graphics.draw(img,info[1],x+3,y+3,0,sx,sy)
  else
    local sx = 32/info.img:getWidth()
    local sy = 32/info.img:getHeight()
    love.graphics.draw(info.img,x+3,y+3,0,sx,sy)
  end
end


return function (info,...)
  local opt, x,y,selected,img= suit.getOptionsAndSize(...)
  opt.id = opt.id or info
  local w,h = 38,38

  opt.state = suit:registerHitbox(opt,opt.id, x,y,w,h)
  suit:registerDraw(defaultDraw, info, opt, x,y,w,h, selected,img,suit.theme)
  return {
    id = opt.id,
    hit = suit:mouseReleasedOn(opt.id),
    active = suit:isActive(opt.id),
    hovered = suit:isHovered(opt.id) and suit:wasHovered(opt.id),
    wasHovered = suit:wasHovered(opt.id)
  }

end