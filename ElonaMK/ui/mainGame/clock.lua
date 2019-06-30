local suit = require "ui/suit"


local clockimg = love.graphics.newImage("assets/ui/clock.png")

local panelquad = love.graphics.newQuad(0,0,320,128,clockimg:getWidth(),clockimg:getHeight())
local iconQuad = {
    love.graphics.newQuad(0,4*32,32,32,clockimg:getWidth(),clockimg:getHeight()),
    love.graphics.newQuad(1*32,4*32,32,32,clockimg:getWidth(),clockimg:getHeight()),
    love.graphics.newQuad(2*32,4*32,32,32,clockimg:getWidth(),clockimg:getHeight()),
    love.graphics.newQuad(3*32,4*32,32,32,clockimg:getWidth(),clockimg:getHeight()),
  }

local minute_hand = love.graphics.newQuad(320,74,10,54,clockimg:getWidth(),clockimg:getHeight())
local hour_pointer = love.graphics.newQuad(168*2,47*2,10,34,clockimg:getWidth(),clockimg:getHeight())

local function getIcon()
  local hour = p.calendar.hour
  local icon = 1
  if hour>=5 and hour<=8 then 
    icon = 1 
  elseif hour>8 and hour<17 then 
    icon = 2
  elseif hour>=17 and hour<=20 then
    icon = 3
  else
    icon = 4
  end
  return icon
end


local function drawClock(x,y,timeStr)
  love.graphics.setColor(1,1,1)
  love.graphics.draw(clockimg,panelquad,x,y,0,1,1)
  local minute = (p.calendar.minute)/30*math.pi
  local hour = (p.calendar.hour+p.calendar.minute/60)%12*math.pi/6
  
  love.graphics.draw(clockimg,hour_pointer,x+64,y+64,hour,1,1,5,29)
  love.graphics.draw(clockimg,minute_hand,x+64,y+64,minute,1,1,5,47)
  
  
  local index = getIcon()
  love.graphics.draw(clockimg,iconQuad[index],x+270,y+25,0,1,1)
  
  love.graphics.setColor(0,0,0)
  love.graphics.setFont(c.font_c20)
  love.graphics.printf(timeStr,x+96,y+30,208,"center")
end


return function()
  
  local timeStr = p.calendar:getTimeStr()
  suit:registerDraw(drawClock,15,5,timeStr)
end