--显示effect状态

local suit = require"ui/suit"



local function drawOneEffect(effect,x,y,w,h)
  love.graphics.setFont(c.font_c14)
  local color = effect:get_color()
  love.graphics.oldColor(255,255,255)
  love.graphics.rectangle("fill",x,y,w,h)
  love.graphics.oldColor(color[1],color[2],color[3])
  love.graphics.printf(effect:getName(), x,y,w,"center")
end



local function effect_view()
  
  local effect_list = player.effect_list
  if #effect_list ==0 then return end
  
  local startx,starty =0,c.win_H - 50
  local font = c.font_c14
  local hoverEffect
  
  for i=1,#effect_list do
    local eff = effect_list[i]
    local name = eff:getName()
    local width = math.max(60,font:getWidth(name)+6)
    local x,y,w,h = startx,starty-i*30,width,16
    suit:registerDraw(drawOneEffect,eff,x,y,w,h)
    local state = suit:registerHitbox(nil,eff,x,y,w,h)--用type做id，防止和底层的effectview冲突
    if state =="hovered" then hoverEffect = eff end
    
  end
  if hoverEffect then
    ui.effectInfo(hoverEffect,love.mouse.getX(),love.mouse.getY())
  end
  
end

return effect_view










