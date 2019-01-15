local suit = require"ui/suit"




local default_width = 200
local function defaultDraw(str)
  local x,y = love.mouse.getX(),love.mouse.getY()
  local mfont = c.font_c14
  local width,warpt = mfont:getWrap(str,default_width)
  local lineHeight = mfont:getHeight()+2
  
  if x+width>c.win_W then x = x-width end
  
  love.graphics.oldColor(20,20,20,158)
  love.graphics.rectangle("fill",x,y,width+4,lineHeight*#warpt+2)
  love.graphics.oldColor(225,225,225)
  love.graphics.setFont(mfont)
  for i=1,#warpt do
    love.graphics.print(warpt[i], x+2, y+(i-1)*lineHeight+2)
  end
end






return function(str)
  suit:registerDraw(defaultDraw,str)
end