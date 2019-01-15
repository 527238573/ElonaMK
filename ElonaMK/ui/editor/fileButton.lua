local suit = require "ui/suit"
local btn_img = love.graphics.newImage("assets/ui/editor_filebutton.png")
local quads = 
{
  normal = suit.createS9Table(btn_img,0,0,75,23,3,3,3,3),
  hovered= suit.createS9Table(btn_img,0,23,75,23,3,3,3,3),
  active = suit.createS9Table(btn_img,0,46,75,23,3,3,3,3)
}
local fileicon_img = love.graphics.newImage("assets/ui/editor_folder.png")
local folder_quad = love.graphics.newQuad(0,0,16,16,48,16)
local file_quad = love.graphics.newQuad(16,0,16,16,48,16)
local up_quad = love.graphics.newQuad(32,0,16,16,48,16)

local function defaultDraw(info, opt, x,y,w,h,selected,theme)
  local opstate = opt.state or "normal"
  if selected then opstate = "active" end
  local s9t = quads[opstate] or quads.normal
  local icon
  if info.ftype=="dir" then 
    icon = folder_quad 
  elseif info.ftype=="file" then
    icon = file_quad 
  else
    icon = up_quad 
  end

  
  love.graphics.setColor(1,1,1)
  theme.drawScale9Quad(s9t,x,y,w,h)
  love.graphics.draw(fileicon_img,icon,x+3,y+3,0,1,1)
  
  love.graphics.setColor(66/255,66/255,66/255)
	love.graphics.setFont(c.font_c12)
  y = y + theme.getVerticalOffsetForAlign(opt.valign, c.font_c12, h)
	love.graphics.printf(info.name, x+32, y, w-34, "left")
end


return function (info,...)
  local opt, x,y,w,h,selected = suit.getOptionsAndSize(...)
  --opt = {}
  opt.id = opt.id or info
  

  opt.state = suit:registerHitbox(opt,opt.id, x,y,w,h)
  suit:registerDraw(defaultDraw, info, opt, x,y,w,h, selected,suit.theme)
  return {
    id = opt.id,
    hit = suit:mouseReleasedOn(opt.id),
    active = suit:isActive(opt.id),
    hovered = suit:isHovered(opt.id) and suit:wasHovered(opt.id),
    wasHovered = suit:wasHovered(opt.id)
  }
end