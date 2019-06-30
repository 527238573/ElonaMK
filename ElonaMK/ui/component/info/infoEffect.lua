local suit = require"ui/suit"

local iteminfo_quad = ui.res.iteminfo_quad --已被通用化

local saved_effect
local info_text = love.graphics.newText(c.font_c16)
local length_des

local function createSnapshoot(effect)
  if saved_effect == effect  then 
    return--无变化，不用修改
  end
  saved_effect = effect
  
  local textWidth = 280--默认文字宽
  local length = 0;
  info_text:clear()
  info_text:addf({{210/255,210/255,210/255},effect:getDescription(),},textWidth,"left",0,0)
  length_des = info_text:getHeight()
  
end
local function draw_effectinfo(effect,x,y)
  love.graphics.oldColor(255,255,255)
  suit.theme.drawScale9Quad(iteminfo_quad,x,y,300,length_des+40)
  love.graphics.setFont(c.font_c20)
  love.graphics.print(effect:getName(), x+19, y+9)
  love.graphics.oldColor(225,225,225)
  love.graphics.setFont(c.font_c16)
  love.graphics.printf(effect:getTimeStr(), x+19, y+9,262,"right")
  love.graphics.oldColor(225,225,225)
  love.graphics.draw(info_text,x+15,y+31)
end


function ui.effectInfo(effect,x,y)
  createSnapshoot(effect)
  suit:registerDraw(draw_effectinfo,effect,x,y)
end

function ui.clearEffectInfo()
  saved_effect = nil
end