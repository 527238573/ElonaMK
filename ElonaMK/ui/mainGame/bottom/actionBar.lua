local suit = require "ui/suit"


local frameimg = love.graphics.newImage("assets/ui/abilityBar.png")

--默认48*48
local function OneEntry(entry,x,y)
  local img,quad
  if entry ==nil then return end
  if entry.etype =="ability" then
    img,quad = entry.val:getImgAndQuad()
    suit:registerDraw(function() 
        love.graphics.setColor(1,1,1)
        love.graphics.draw(img,x,y,0,2,2)
      end)
  end

end


return function(x,y)
  local mc_bar = p.mc.actionBar

  local startX = x+8
  local startY = y+8
  local next_w = 54
  suit:registerDraw(function() --紫色的底
      love.graphics.setColor(34/255,32/255,54/355)
      love.graphics.rectangle("fill",startX,startY,next_w*7+48,48)
    end)

  for i=1,8 do
    OneEntry(mc_bar[i],startX+(i-1)*next_w,startY)
  end

  suit:registerDraw(function() --框
      love.graphics.setColor(1,1,1)
      love.graphics.draw(frameimg,x,y,0,2,2)
    end)
end