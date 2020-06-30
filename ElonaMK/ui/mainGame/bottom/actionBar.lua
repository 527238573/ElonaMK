local suit = require "ui/suit"


local frameimg = love.graphics.newImage("assets/ui/abilityBar.png")
local coverimg = love.graphics.newImage("assets/ui/actionIconCover.png")


local key_action_id = {}
for idi =1,8 do key_action_id[idi] = string.format("action%d",idi) end
c.key_action_id = key_action_id
--默认48*48
local function OneEntry(index,entry,x,y)
  if entry ==nil then return end
  entry.state = suit:registerHitbox(entry,entry,x,y,48,48)
  local keydown =ui.isDown_Game(key_action_id[index]) and ui.isKeyfocusMainGame()
  
  if entry.etype =="ability" then
    local img = entry.val:getAbilityIcon()
    suit:registerDraw(function() 
        love.graphics.setColor(1,1,1)
        love.graphics.draw(img,x,y,0,2,2)
        if entry.state =="active" or keydown then
          love.graphics.setColor(0.9,0.7,0.3,0.8)
          love.graphics.draw(coverimg,x,y,0,2,2)
        elseif entry.state =="hovered" then
          love.graphics.setColor(0.6,0.6,1,0.8)
          love.graphics.draw(coverimg,x,y,0,2,2)
        end
      end)
  end
  
  if suit:mouseReleasedOn(entry) then
    p:useActionBar(index)
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
    OneEntry(i,mc_bar[i],startX+(i-1)*next_w,startY)
  end

  suit:registerDraw(function() --框
      love.graphics.setColor(1,1,1)
      love.graphics.draw(frameimg,x,y,0,2,2)
    end)
end