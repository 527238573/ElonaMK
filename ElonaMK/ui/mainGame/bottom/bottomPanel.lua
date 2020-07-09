local suit = require "ui/suit"
--虚拟的panel，没有

local win_width = love.graphics.getWidth()
local win_height = love.graphics.getHeight()


local ammoCounter=  require"ui/mainGame/bottom/ammoCounter"
local selectInfo=  require"ui/mainGame/bottom/selectInfo"
local actionBar=  require"ui/mainGame/bottom/actionBar"
local effectList=  require"ui/mainGame/bottom/effectList"

local drawBar = ui.drawBar


local function drawLifeMana(x,y)
  x = x -372
  local mc = p.mc
  local exp = mc:getExpRate()
  drawBar(mc:getHPRate(),3,x+6, y,180,22,4)
  drawBar(mc:getMPRate(),4,x+188, y,180,22,4)
  drawBar(exp,2,x-178, y,180,22,4)
  love.graphics.setColor(1,1,1)
  love.graphics.setFont(c.font_c18)
  love.graphics.printf(string.format("%d/%d",math.floor(mc.hp),mc.max_hp), x+6, y+1,180,"center")
  love.graphics.printf(string.format("%d/%d",math.floor(mc.mp),mc.max_mp), x+188, y+1,180,"center")
  love.graphics.printf(string.format("%.2f%%",exp*100), x-178, y+2,180,"center")
end


return function()
  local x,y,w,h = win_width-300,0,300,win_height
  actionBar(win_width-738,win_height-58)
  local ammoh =ammoCounter(10,win_height-3)
  selectInfo(win_width-500,win_height-56,200)
  suit:registerDraw(drawLifeMana,win_width-738,win_height-21)
  effectList(0,math.min(win_height-100,win_height-ammoh-53))
end