local suit = require"ui/suit"

local iteminfo_quad = ui.res.iteminfo_quad --已被通用化

local saved_trait
local info_text = love.graphics.newText(c.font_c16)
local length_des

local function createSnapshoot(tarit)
  if saved_trait == tarit  then 
    return--无变化，不用修改
  end
  saved_trait = tarit
  
  local textWidth = 280--默认文字宽
  local length = 0;
  info_text:clear()
  info_text:addf({{210/255,210/255,210/255},tarit:getDescription(),},textWidth,"left",0,0)
  length_des = info_text:getHeight()
  
end
local function draw_taritinfo(tarit,x,y)
  love.graphics.oldColor(255,255,255)
  suit.theme.drawScale9Quad(iteminfo_quad,x,y,300,length_des+40)
  if tarit:is_good() then
    love.graphics.oldColor(190,255,190)
  else
    love.graphics.oldColor(255,190,190)
  end
  love.graphics.setFont(c.font_c20)
  love.graphics.print(tarit:getName(), x+19, y+9)
  love.graphics.oldColor(225,225,225)
  love.graphics.draw(info_text,x+15,y+31)
end


function ui.traitInfo(tarit,x,y)
  createSnapshoot(tarit)
  suit:registerDraw(draw_taritinfo,tarit,x,y)
  
end
