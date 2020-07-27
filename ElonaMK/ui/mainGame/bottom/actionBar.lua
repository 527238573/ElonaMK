local suit = require "ui/suit"


local frameimg = love.graphics.newImage("assets/ui/abilityBar.png")
local coverimg = love.graphics.newImage("assets/ui/actionIconCover.png")


local hoverdIndex
local hoverdTime =0
local abilityInfo = require"ui/component/info/abilityInfo"

local shader_cooldown = c.shader_cooldown

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
    local coolrate = entry.val:getCoolRate()
    suit:registerDraw(function() 
        love.graphics.setColor(1,1,1)
        if coolrate>0 then 
          love.graphics.setShader(shader_cooldown)
          shader_cooldown:send('c_rad', 2*math.pi*(coolrate-0.5))
          love.graphics.draw(img,x,y,0,2,2)
          love.graphics.setShader()
        else
          love.graphics.draw(img,x,y,0,2,2)
        end
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
  if suit:isHovered(entry) and suit:wasHovered(entry) then
    hoverdIndex = index
  end
end

local function showActionInfo(entry)
  if entry ==nil then return end
  if entry.etype =="ability" then
    abilityInfo(entry.val,p.mc,love.mouse.getX(),love.mouse.getY(),300,false)
  end
end

return function(x,y)
  
  --悬浮计数
  if hoverdIndex then
    hoverdTime = hoverdTime+love.timer.getDelta()
    hoverdIndex = nil
  else
    hoverdTime =0
  end
  
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
  --悬浮大约0.5秒显示，不同帧率效果不同。
  if hoverdIndex and hoverdTime>0.5 then showActionInfo(mc_bar[hoverdIndex]) end
end