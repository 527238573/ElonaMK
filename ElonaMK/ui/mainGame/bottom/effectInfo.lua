local suit = require"ui/suit"

local iteminfo_quad = c.pic.iteminfo_s9



local info_text = love.graphics.newText(c.font_c16)
local length_des
local saved_name
local saved_des
local info_width
local function createSnapshoot(effect)
  local name = effect:getName()
  local des = effect:getDescription()
  if  name ==saved_name and des ==saved_des  then 
    return--无变化，不用修改
  end
  saved_name = name
  saved_des = des
  
  local textWidth = 280--默认文字宽
  local length = 0;
  info_text:clear()
  info_text:addf({{210/255,210/255,210/255},des,},textWidth,"left",0,0)
  length_des = info_text:getHeight()
  info_width = math.min(300,math.max(c.font_c20:getWidth(saved_name)+40,info_text:getWidth() +25))
end

local function draw_effectinfo(x,y)
  love.graphics.setColor(1,1,1)
  suit.theme.drawScale9Quad(iteminfo_quad,x,y,info_width,length_des+40)
  love.graphics.setFont(c.font_c20)
  love.graphics.print(saved_name, x+19, y+9)
  love.graphics.setColor(0.85,0.85,0.85)
  love.graphics.setFont(c.font_c16)
  --love.graphics.printf(effect:getTimeStr(), x+19, y+9,262,"right")
  love.graphics.setColor(0.85,0.85,0.85)
  love.graphics.draw(info_text,x+15,y+31)
end


return function(effect,x,y)
  createSnapshoot(effect)
  suit:registerDraw(draw_effectinfo,x,y)
end
