local suit = require"ui/suit"


local blockScreen_id = newid()
local back_id = newid()
local line_h = 20
local function defaultDraw(info,x,y,w,h)
  love.graphics.oldColor(255,255,255)
  suit.theme.drawScale9Quad(ui.res.common_menuS9,x,y,w,h)
  for i=1,#info do
    local opt = info[i]
    if opt.state =="hovered" then
      love.graphics.oldColor(173,173,173)
      love.graphics.rectangle("fill",x+4,y+4+(i-1)*line_h,w-8,line_h)
    elseif opt.state =="active" then
      love.graphics.oldColor(213,213,213)
      love.graphics.rectangle("fill",x+4,y+4+(i-1)*line_h,w-8,line_h)
    end
    love.graphics.oldColor(11,11,11)
    love.graphics.setFont(c.font_c16)
    love.graphics.print(opt.name,x+6,y+6+(i-1)*line_h)
  end
end

return function(info,x,y,width)
  local w = width or 150
  suit:registerHitFullScreen(nil,blockScreen_id)--全屏遮挡
  
  local h = 8+math.max(1,#info)*line_h
  for i=1,#info do
    local opt = info[i]
    opt.state = suit:registerHitbox(opt,opt.id, x,y+4+(i-1)*line_h,w,line_h)
  end
  --suit:registerHitbox(nil,back_id, x,y,w,h)
  suit:registerDraw(defaultDraw,info,x,y,w,h)
  if suit:isActive(blockScreen_id) or suit:isActiveR(blockScreen_id) then
    return "quit"
  end
  
  for i=1,#info do
    if suit:mouseReleasedOn(info[i].id) then return info[i].id end
  end
end