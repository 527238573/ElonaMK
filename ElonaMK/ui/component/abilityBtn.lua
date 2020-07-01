local suit = require"ui/suit"
local quads = c.pic["btn_quads"]
--已启用




local shader_cooldown = c.shader_cooldown


local function defaultDraw(picimg,coolRate, opt, x,y,w,h,theme)
  local opstate = opt.state or "normal"
  local s9t = quads[opstate] or quads.normal

  local pic_size = opt.pic_size or 2
  if opt.disable then
    love.graphics.setColor(160/255,160/255,160/255)
  else
    love.graphics.setColor(1,1,1)
  end
  theme.drawScale9Quad(s9t,x,y,w,h)
  local side = 6
  if coolRate>0 then 
    love.graphics.setShader(shader_cooldown)
    shader_cooldown:send('c_rad', 2*math.pi*(coolRate-0.5))
    love.graphics.draw(picimg,x+side,y+side,0,pic_size,pic_size)
    love.graphics.setShader()
  else
    love.graphics.draw(picimg,x+side,y+side,0,pic_size,pic_size)
  end
end


return function(picimg,coolRate, ...)
  local opt, x,y,w,h = suit.getOptionsAndSize(...)
  assert(opt.id)
  opt.state = suit:registerHitbox(opt,opt.id, x,y,w,h)
  suit:registerDraw(defaultDraw, picimg,coolRate, opt, x,y,w,h,suit.theme)
  return {
    id = opt.id,
    hit = suit:mouseReleasedOn(opt.id) and (not opt.disable),
    active = suit:isActive(opt.id),
    hovered = suit:isHovered(opt.id) and suit:wasHovered(opt.id),
    wasHovered = suit:wasHovered(opt.id)
  }
end