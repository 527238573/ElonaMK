local suit = require "ui/suit"


local effectInfo = require "ui/mainGame/bottom/effectInfo"
--左下坐标

local oneh = 20
local onew = 85
local lineH = c.font_c14:getHeight()
local lineD = math.floor((oneh-lineH)/2)

local function OneEffect(effect,x,y,w,h)
  local rate = effect.remain/math.max(0.001,effect.life +effect.remain)
  suit:registerDraw(function() 
      love.graphics.setColor(effect:getBackColor())
      love.graphics.rectangle("fill",x,y,w,h)
      love.graphics.setColor(0,0,0,0.2)
      love.graphics.rectangle("fill",x,y,w*rate,h)
      
      love.graphics.setColor(effect:getFrontColor())
      love.graphics.setFont(c.font_c14)
      love.graphics.printf(effect:getName(), x,y+lineD,w,"center")
    end)

end



local oneE_h = 36
--左下的坐标，0，y
return function(x,y)

  local elist = p.mc.effects
  local eNum = #elist
  local hoverEffect
  
  for i=1,eNum do
    local cx,cy,cw,ch = x+1,y-(i-1)*oneE_h-oneh,onew,oneh
    local eff = elist[i]
    OneEffect(eff,cx,cy,cw,ch)
    local state = suit:registerHitbox(nil,eff,cx,cy,cw,ch)
    if state =="hovered" then hoverEffect = eff end
  end
  suit:registerDraw(function() 
      love.graphics.setColor(0,0,0)
      for i=1,eNum do
        local cx,cy = x,y-(i-1)*oneE_h
        love.graphics.rectangle("line",cx,cy-oneh-1,onew+2,oneh+2)
      end
    end)
  if hoverEffect then
    effectInfo(hoverEffect,love.mouse.getX(),love.mouse.getY())
  end

end